#include "ExtraEnchantmentInfo.h"
#include "skse/GameRTTI.h"


//Adapted from skse/PapyrusWornObject.cpp (thanks SKSE team!)
namespace ExtraEnchantmentInfo
{

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


EquipData ResolveEquippedObject(Actor* actor, UInt32 weaponSlot /* 0=left, 1=right */, UInt32 slotMask /* weapon=0 */)
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
	
	EquipData sourceEquipped = ResolveEquippedObject(actor, sourceType, 0);
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