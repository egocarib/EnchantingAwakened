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

	UInt32 GetMagicItemMagicEffects(StaticFunctionTag* base, VMArray<EffectSetting*>);

	//Returns number of normal (not player-created) known enchantments, and inserts them all into outputKnown array.
	//Returns -1 if no enchantments are known by the player.
	// UInt32 GetPlayerKnownEnchantments(StaticFunctionTag* base, VMArray<EnchantmentItem*> outputKnown);

	BSFixedString GetLearnEventName(StaticFunctionTag* base);

	//adds to formlist all loaded enchantments that have any member of baseEnchantments as their base enchantment.
	void FillFormlistWithChildrenOfBaseEnchantments(StaticFunctionTag* base, BGSListForm* formlist, VMArray<EnchantmentItem*> baseEnchantments, bool terminateWhenNull);

	//same thing but input a list instead of an array
	void FillFormlistWithChildrenOfBaseEnchantmentsList(StaticFunctionTag* base, BGSListForm* formlist, BGSListForm* inputForms);

	//modify the entry point numeric value for EP at epIndex for each of perks, replacing with newVals
	void SetPerkEntryValues(StaticFunctionTag* base, VMArray<BGSPerk*> perks, VMArray<float> newVals, UInt32 epIndex);

	//set the internal constant for offensive enchant learning (each hit with enchanted weapon will be worth this much "experience"
	void SetOffensiveEnchantmentLearnExperienceMult(StaticFunctionTag* base, float newMultiplier);

	//set the learn thresholds. Each time a new threshold is met by offensive enchantment use, a new learn event will be sent from internal plugin for that enchantment.
	void SetOffensiveEnchantmentLearnLevelThresholds(StaticFunctionTag* base, VMArray<float> thresholds);
}

bool RegisterPapyrusEAExtender(VMClassRegistry* registry);