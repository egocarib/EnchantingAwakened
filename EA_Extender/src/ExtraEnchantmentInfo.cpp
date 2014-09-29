#include "ExtraEnchantmentInfo.h"
#include "EnchantingAwakenedData.h"
#include "common/ICriticalSection.h"
#include "skse/GameRTTI.h"
#include "Events.h"
#include <utility> //std::pair


ExtraEnchantmentInfo::ActiveEnchantmentEffectMonitor	g_activeEnchantEffects;
const std::string 										EQUIP_ENCHANTMENT_EVENT_NAME("EA_EquippedEnchantmentEvent");


//Adapted from skse/PapyrusWornObject.cpp (thanks SKSE team!)
namespace ExtraEnchantmentInfo
{

const float			kEventType_IsEquipping = 1.0;
const float			kEventType_IsUnequipping = 0.0;
ICriticalSection	s_activeEffectListLock;

void SendEquipEnchantmentEvent(EnchantmentItem* e, float isEquipping)
{
	if (g_userExclusions.IsExcluded(e))
		return;

	BSFixedString equipEventName(EQUIP_ENCHANTMENT_EVENT_NAME.c_str());

	SKSEModCallbackEvent evn(equipEventName, "", isEquipping, e);
	g_skseModEventDispatcher->SendEvent(&evn);
}

//maybe add a check to see if enchantment is coming from kFormType_Armor and that the armor has "Playable" flag checked or something... (worried about stuff like werewolf skin armor...? not sure if there would be weird exceptions)

void ActiveEnchantmentEffectMonitor::ProcessEquipped(bool processAll)
{
	s_activeEffectListLock.Enter();

	if (tList<ActiveEffect>* effects = (*g_thePlayer)->magicTarget.GetActiveEffects())
		for (SInt32 n = (effects->Count() - 1); n >= 0; n--) //start at the end, most likely place to find new things
			if (ActiveEffect* aEff = effects->GetNthItem(n))
				if (aEff->item->formType == kFormType_Enchantment)
					if (!g_userExclusions.IsExcluded(aEff->sourceItem)) //Ignore enchantments on user-excluded items
					{
						EnchantmentItem* e = DYNAMIC_CAST(aEff->item, MagicItem, EnchantmentItem);
						if (e->data.baseEnchantment)
							e = e->data.baseEnchantment; //set to base
						ActiveEnchantmentInsertPairT insertResult = activeEnchantments.insert(e);
						if (insertResult.second == true) //new element
						{
							SendEquipEnchantmentEvent(e, kEventType_IsEquipping);
							_MESSAGE("Equipped enchantment: %s [%08X]", (DYNAMIC_CAST(e, EnchantmentItem, TESFullName))->name.data, e->formID);
							if (!processAll)
								break; //besides initial load check, should only ever get one new enchant at a time here
						}
					}

	s_activeEffectListLock.Leave();
}

void ActiveEnchantmentEffectMonitor::ProcessUnequipped()
{
	//although we could simply send the unequipped form to this function from the equip event, it is
	//better to walk the effect list in case duplicate enchantments are also equipped. We don't want
	//to remove from set or send event until all instances are completely gone

	//hopefully this works... I'm assuming effects will be removed before this unequip event is triggered...

	ActiveEnchantmentSetT	newEnchList;

	s_activeEffectListLock.Enter();

	if(tList<ActiveEffect>* effects = (*g_thePlayer)->magicTarget.GetActiveEffects())
	{
		//Get all current active enchantments
		for (UInt32 n = 0; n < effects->Count(); n++)
			if (ActiveEffect* aEff = effects->GetNthItem(n))
				if (aEff->item->formType == kFormType_Enchantment)
				{
					EnchantmentItem* e = DYNAMIC_CAST(aEff->item, MagicItem, EnchantmentItem);
					if (e->data.baseEnchantment)
						e = e->data.baseEnchantment;
					newEnchList.insert(e);
				}

		//Compare to most recent list to determine what has been removed, and send event
		for (ActiveEnchantmentSetT::iterator it = activeEnchantments.begin(); it != activeEnchantments.end(); it++)
			if (!newEnchList.erase(*it))
			{
				SendEquipEnchantmentEvent((*it), kEventType_IsUnequipping);
				_MESSAGE("Unequipped enchantment: %s [%08X]", (DYNAMIC_CAST((*it), EnchantmentItem, TESFullName))->name.data, (*it)->formID);
				activeEnchantments.erase(it);
				break;
			}
	}

	s_activeEffectListLock.Leave();
}


bool MatchByEquipSlot::Matches(TESForm* form) const
{
	if (form)
	{
		if (form->formType != TESObjectWEAP::kTypeID) // If not a weapon use mask
		{
			BGSBipedObjectForm* pBip = DYNAMIC_CAST(form, TESForm, BGSBipedObjectForm);
			if (pBip)
				return (pBip->data.parts & m_mask) != 0;
		}
		else if (m_mask == 0) // Use hand if no mask specified
		{
			TESForm * equippedForm = m_actor->GetEquippedObject(m_hand == kSource_LeftHand);
			return (equippedForm && equippedForm == form);
		}
	}
	return false;
}


EquipData ResolveEquippedObject(Actor* actor, UInt32 weaponSlot, UInt32 slotMask /* = 0 (weapon)*/)
{
	EquipData foundData;
	foundData.pForm = NULL;
	foundData.pExtraData = NULL;

	if (!actor)
		return foundData;

	MatchByEquipSlot matcher(actor, weaponSlot, slotMask);
	ExtraContainerChanges* pContainerChanges = static_cast<ExtraContainerChanges*>(actor->extraData.GetByType(kExtraData_ContainerChanges));
	if (pContainerChanges)
		foundData = pContainerChanges->FindEquipped(matcher, weaponSlot == kSource_RightHand || slotMask != 0, weaponSlot == kSource_LeftHand);

	return foundData;
}

EnchantmentItem* ResolveEquippedEnchantment(BaseExtraList* extraData)
{
	if (!extraData)
		return NULL;
	ExtraEnchantment* extraEnchant = static_cast<ExtraEnchantment*>(extraData->GetByType(kExtraData_Enchantment));
	return (extraEnchant) ? extraEnchant->enchant : NULL;
}

EnchantmentItem* GetActorSourceEnchantment(Actor* actor, UInt32 sourceType)
{
	if (sourceType != kSource_LeftHand)
		sourceType = kSource_RightHand; //correct other ActorMagicCaster source types
	
	EquipData sourceEquipped = ResolveEquippedObject(actor, sourceType);
	if (sourceEquipped.pForm)
	{
		TESObjectWEAP* thisWeapon = DYNAMIC_CAST(sourceEquipped.pForm, TESForm, TESObjectWEAP);
		if (thisWeapon)
		{
			EnchantmentItem* thisEnchant = thisWeapon->enchantable.enchantment; //Pre-enchanted?
			if (!thisEnchant)
				thisEnchant = ResolveEquippedEnchantment(sourceEquipped.pExtraData); //Player-enchanted?

			return thisEnchant;
		}
	}
	return NULL;
}


};