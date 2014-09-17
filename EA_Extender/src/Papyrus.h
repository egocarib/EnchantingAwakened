#pragma once

#include "skse/PapyrusNativeFunctions.h"

class BGSKeyword;
//class BSFixedString;
class EnchantmentItem;
class SpellItem;
class TESForm;
class TESObjectREFR;

namespace PapyrusEAExtender
{
	void SetNthKeyword(StaticFunctionTag* base, TESForm* thisForm, UInt32 index, BGSKeyword* newKeywordToSet);

	void SetFormArrayNthKeyword(StaticFunctionTag* base, VMArray<TESForm*> inputForms, UInt32 index, BGSKeyword* newKeywordToSet);

	void SetFormArrayNthKeywordArray(StaticFunctionTag* base, VMArray<TESForm*> inputForms, UInt32 index, VMArray<BGSKeyword*> newKeywordsToSet);

	void GetFormArrayNthKeywords(StaticFunctionTag* base, VMArray<TESForm*> inputForms, UInt32 index, VMArray<BGSKeyword*> fillKeys);

	//locates all enchanted forms in pContainerRef and fills the corresponding form/enchantment arrays
	bool GetEnchantedForms(StaticFunctionTag* base, TESObjectREFR* pContainerRef, VMArray<TESForm*> forms, VMArray<EnchantmentItem*> enchantments, bool excludePlayerEnchants, bool excludeDisallowEnchanting);

	//Enchanting Awakened function to check if form is enchanted, and return specific data about it.
	bool CheckFormForEnchantment(StaticFunctionTag* base, TESForm* form, VMArray<TESForm*> returnData);

	void GetFormNames(StaticFunctionTag* base, VMArray<TESForm*> inputForms, VMArray<BSFixedString> returnStrings);

	bool IsSpellSkillType(StaticFunctionTag* base, SpellItem* spell, BSFixedString skillType);

	BSFixedString GetSpellSkillString(StaticFunctionTag* base, SpellItem* spell);

	UInt32 GetSpellSkillNumber(StaticFunctionTag* base, SpellItem* spell);

	//Returns number of normal (not player-created) known enchantments, and inserts them all into outputKnown array.
	//Returns -1 if no enchantments are known by the player.
	UInt32 GetPlayerKnownEnchantments(StaticFunctionTag* base, VMArray<EnchantmentItem*> outputKnown);

	BSFixedString GetLearnEventName(StaticFunctionTag* base);
}

bool RegisterPapyrusEAExtender(VMClassRegistry* registry);