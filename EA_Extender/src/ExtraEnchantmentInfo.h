#pragma once

#include "skse/GameForms.h"
#include "skse/GameFormComponents.h"
#include "skse/GameObjects.h"
#include "skse/GameExtraData.h"
#include "skse/GameBSExtraData.h"
#include "skse/GameRTTI.h"


//Adapted from skse/PapyrusWornObject.cpp (thanks SKSE team!)
namespace ExtraEnchantmentInfo
{

enum
{
	kSource_LeftHand,
	kSource_RightHand
};

class MatchByEquipSlot : public FormMatcher
{
	UInt32 m_mask;
	UInt32 m_hand;
	Actor* m_actor;
public:
	MatchByEquipSlot(Actor* actor, UInt32 hand, UInt32 slot) : 
	  m_hand(hand),
	  m_mask(slot),
	  m_actor(actor)
	  {

	  }

	  enum
	  {
		  kSlotID_Left = 0,
		  kSlotID_Right
	  };

	  bool Matches(TESForm* pForm) const {
		  if (pForm) {
			  if(pForm->formType != TESObjectWEAP::kTypeID) { // If not a weapon use mask
				  BGSBipedObjectForm* pBip = DYNAMIC_CAST(pForm, TESForm, BGSBipedObjectForm);
				  if (pBip)
					  return (pBip->data.parts & m_mask) != 0;
			  } else if(m_mask == 0) { // Use hand if no mask specified
				  TESForm * equippedForm = m_actor->GetEquippedObject(m_hand == kSlotID_Left);
				  return (equippedForm && equippedForm == pForm);
			  }
		  }
		  return false;
	  }
};

//0 = left hand, 1 = right. Use 0 slotmask for weapon
EquipData ResolveEquippedObject(Actor* actor, UInt32 weaponSlot, UInt32 slotMask)
{
	EquipData foundData;
	foundData.pForm = NULL;
	foundData.pExtraData = NULL;
	if(!actor)
		return foundData;

	MatchByEquipSlot matcher(actor, weaponSlot, slotMask);
	ExtraContainerChanges* pContainerChanges = static_cast<ExtraContainerChanges*>(actor->extraData.GetByType(kExtraData_ContainerChanges));
	if (pContainerChanges) {
		foundData = pContainerChanges->FindEquipped(matcher, weaponSlot == MatchByEquipSlot::kSlotID_Right || slotMask != 0, weaponSlot == MatchByEquipSlot::kSlotID_Left);
		return foundData;
	}

	return foundData;
}

EnchantmentItem* ResolveEquippedEnchantment(BaseExtraList* extraData)
{
	if (!extraData)
		return NULL;
	ExtraEnchantment* extraEnchant = static_cast<ExtraEnchantment*>(extraData->GetByType(kExtraData_Enchantment));
	return extraEnchant ? extraEnchant->enchant : NULL;
}

EnchantmentItem* GetActorSourceEnchantment(Actor* actor, UInt32 sourceType)
{
	if (sourceType != ExtraEnchantmentInfo::kSource_LeftHand)
		sourceType = ExtraEnchantmentInfo::kSource_RightHand; //correct other ActorMagicCaster source types
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





//things to consider ---->
//
//     player made enchantment will have to be looked up by its effects
//
//     staff enchantments? do they do anything?