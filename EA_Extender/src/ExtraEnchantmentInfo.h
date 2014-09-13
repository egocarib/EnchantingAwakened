#pragma once

#include "skse/GameExtraData.h"


namespace ExtraEnchantmentInfo
{

enum
{
	kSource_LeftHand,
	kSource_RightHand
};

class MatchByEquipSlot : public FormMatcher
{
private:
	UInt32 m_mask;
	UInt32 m_hand;
	Actor* m_actor;

public:
	MatchByEquipSlot(Actor* actor, UInt32 hand, UInt32 slot) : m_hand(hand), m_mask(slot), m_actor(actor) {}

	bool Matches(TESForm* form) const;

};

EquipData			ResolveEquippedObject(Actor* actor, UInt32 weaponSlot, UInt32 slotMask);
EnchantmentItem*	ResolveEquippedEnchantment(BaseExtraList* extraData);
EnchantmentItem*	GetActorSourceEnchantment(Actor* actor, UInt32 sourceType);

};





//things to consider ---->
//
//     player made enchantment will have to be looked up by its effects
//
//     staff enchantments? do they do anything?