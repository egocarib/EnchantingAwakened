#pragma once

#include "[PluginLibrary]/SerializeForm.h"
#include "skse/GameExtraData.h"
#include "skse/GameRTTI.h"
#include <utility> //std::pair
#include <set>


extern	const std::string	EQUIP_ENCHANTMENT_EVENT_NAME;


namespace ExtraEnchantmentInfo
{

typedef  std::set<EnchantmentItem*>							ActiveEnchantmentSetT;
typedef  std::pair<ActiveEnchantmentSetT::iterator, bool>	ActiveEnchantmentInsertPairT;


class ActiveEnchantmentEffectMonitor
{
private:
	ActiveEnchantmentSetT	activeEnchantments;

public:
	ActiveEnchantmentEffectMonitor() : activeEnchantments() {}
	void ProcessEquipped(bool processAll = false);
	void ProcessUnequipped();
	bool IsEmpty() { return activeEnchantments.empty(); }

	template <typename SerializeInterface_T>
	void Serialize(SerializeInterface_T* const intfc)
	{
		UInt32 numberTracked = activeEnchantments.size();
		intfc->WriteRecordData(&numberTracked, sizeof(UInt32)); //Number of entries to follow
		for (ActiveEnchantmentSetT::iterator it = activeEnchantments.begin(); it != activeEnchantments.end(); it++)
		{
			SerialFormData activeEnchantment(*it);
			intfc->WriteRecordData(&activeEnchantment, sizeof(SerialFormData));
		}
	}

	template <typename SerializeInterface_T>
	void Deserialize(SerializeInterface_T* const intfc, UInt32* const sizeRead, UInt32* const sizeExpected)
	{
		(*sizeRead) = (*sizeExpected) = 0;

		UInt32 numberTracked;
		(*sizeRead) += intfc->ReadRecordData(&numberTracked, sizeof(UInt32));
		(*sizeExpected) += sizeof(UInt32);
		if (*sizeRead != *sizeExpected)
			return;

		for (UInt32 i = 0; i < numberTracked; i++)
		{
			SerialFormData	thisEnchantmentData;

			(*sizeRead) += intfc->ReadRecordData(&thisEnchantmentData, sizeof(SerialFormData));
			(*sizeExpected) += sizeof(SerialFormData);
			if (*sizeRead != *sizeExpected)
				return;

			TESForm* thisForm;
			UInt32 result = thisEnchantmentData.Deserialize(&thisForm);
			if (result != SerialFormData::kResult_Succeeded)
				SerialFormData::OutputError(result);
			else
			{
				EnchantmentItem* thisEnchantment = DYNAMIC_CAST(thisForm, TESForm, EnchantmentItem);
				activeEnchantments.insert(thisEnchantment);
			}
		}
	}
};




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

EquipData			ResolveEquippedObject(Actor* actor, UInt32 weaponSlot, UInt32 slotMask = 0 /*0 == weapon*/);
EnchantmentItem*	ResolveEquippedEnchantment(BaseExtraList* extraData);
EnchantmentItem*	GetActorSourceEnchantment(Actor* actor, UInt32 sourceType);


};



extern	ExtraEnchantmentInfo::ActiveEnchantmentEffectMonitor	g_activeEnchantEffects;