#include "Papyrus.h"


//For unpacking VMArray of various form types
template <typename T>
void UnpackValue(VMArray<T*>* dst, VMValue* src)
{
	UnpackArray(dst, src, GetTypeIDFromFormTypeID(T::kTypeID, (*g_skyrimVM)->GetClassRegistry()) | VMValue::kType_Identifier);
}


MagicSkillStrings magicSkillStrings = MagicSkillStrings::Instance();



bool KeyListHasMagicDisallowEnchanting(BGSKeywordForm* keywords)
{
	if (!keywords)
		return false;

	static BGSKeyword* magicDisallowEnchanting = DYNAMIC_CAST(LookupFormByID(0x000C27BD), TESForm, BGSKeyword);

	for(UInt32 k = 0; k < keywords->numKeywords; ++k)
		if (keywords->keywords[k] == magicDisallowEnchanting)
			return true;
	return false;
}

bool FormHasMagicDisallowEnchanting(TESForm* form)
{
	BGSKeywordForm* keywords = DYNAMIC_CAST(form, TESForm, BGSKeywordForm);
	return KeyListHasMagicDisallowEnchanting(keywords);
}

inline bool IsPlayerCraftedEnchantment(EnchantmentItem* enchantment)
{
	return (enchantment) ? (enchantment->formID >= 0xFF000000) : false;
}








namespace papyrusEAExtender
{
	void SetNthKeyword(StaticFunctionTag* base, TESForm* thisForm, UInt32 index, BGSKeyword* newKeywordToSet)
	{
		if (!thisForm)
			return;

		BGSKeywordForm* pKeywords = DYNAMIC_CAST(thisForm, TESForm, BGSKeywordForm);
		if (pKeywords && index < pKeywords->numKeywords)
			pKeywords->keywords[index] = newKeywordToSet;
	}

	void SetFormArrayNthKeyword(StaticFunctionTag* base, VMArray<TESForm*> inputForms, UInt32 index, BGSKeyword* newKeywordToSet)
	{
		for(UInt32 i = 0; i < inputForms.Length(); i++)
		{
			TESForm* thisForm = NULL;
			inputForms.Get(&thisForm, i);
			if (!thisForm) //ternminate function when NULL entry is found (should signal end of array contents)
				return;

			BGSKeywordForm* pKeywords = DYNAMIC_CAST(thisForm, TESForm, BGSKeywordForm);
			if (pKeywords && index < pKeywords->numKeywords)
				pKeywords->keywords[index] = newKeywordToSet;
		}
	}

	void SetFormArrayNthKeywordArray(StaticFunctionTag* base, VMArray<TESForm*> inputForms, UInt32 index, VMArray<BGSKeyword*> newKeywordsToSet)
	{
		if(inputForms.Length() > newKeywordsToSet.Length()) //only process if we've got enough keywords
			return;

		for(UInt32 i = 0; i < inputForms.Length(); i++)
		{
			TESForm* thisForm = NULL;
			inputForms.Get(&thisForm, i);
			if (!thisForm) //End of array
				return;

			BGSKeywordForm* pKeywords = DYNAMIC_CAST(thisForm, TESForm, BGSKeywordForm);
			if (pKeywords && index < pKeywords->numKeywords)
			{
				BGSKeyword* newKeyword = NULL;
				newKeywordsToSet.Get(&newKeyword, i);
				if (newKeyword)
					pKeywords->keywords[index] = newKeyword;
			}
		}
	}

	// void DumpEnchantmentValues(EnchantmentItem* pEnch); //forward declaration
	void GetFormArrayNthKeywords(StaticFunctionTag* base, VMArray<TESForm*> inputForms, UInt32 index, VMArray<BGSKeyword*> fillKeys)
	{
		if (inputForms.Length() > fillKeys.Length())
			return;

		for (UInt32 i = 0; i < inputForms.Length(); ++i)
		{
			TESForm* thisForm = NULL;
			inputForms.Get(&thisForm, i);
			if (!thisForm) //End of array
				return;

			BGSKeywordForm* pKeywords = DYNAMIC_CAST(thisForm, TESForm, BGSKeywordForm);
			BGSKeyword* setKey = (pKeywords && index < pKeywords->numKeywords) ? pKeywords->keywords[index] : NULL;
			fillKeys.Set(&setKey, i);
		}
	}

	//locates all enchanted forms in pContainerRef and fills the corresponding form/enchantment arrays
	bool GetEnchantedForms(StaticFunctionTag* base, TESObjectREFR* pContainerRef, VMArray<TESForm*> forms, VMArray<EnchantmentItem*> enchantments, bool excludePlayerEnchants, bool excludeDisallowEnchanting)
	{
		if (!pContainerRef || forms.Length() != enchantments.Length())
			return false;

		TESContainer* pContainer = NULL;
		TESForm* pBaseForm = pContainerRef->baseForm;
		pContainer = (pBaseForm) ? DYNAMIC_CAST(pBaseForm, TESForm, TESContainer) : NULL;
		if (!pContainer)
			return false;

		UInt32 fillIndex = 0;

		if (pContainer)
		{
			for (UInt32 i = 0; i < pContainer->numEntries; ++i)
			{
				TESForm* thisForm = (pContainer->entries[i]->count) ? pContainer->entries[i]->form : NULL;
				if (!thisForm)
					continue;

				EnchantmentItem* thisEnchantment = NULL;
				TESObjectARMO* thisArmor = DYNAMIC_CAST(thisForm, TESForm, TESObjectARMO);
				if (thisArmor)
					thisEnchantment = thisArmor->enchantable.enchantment;
				else
				{
					TESObjectWEAP* thisWeapon = DYNAMIC_CAST(thisForm, TESForm, TESObjectWEAP);
					if (thisWeapon)
						thisEnchantment = thisWeapon->enchantable.enchantment;
				}

				if (!thisEnchantment) continue;
				if (excludeDisallowEnchanting && FormHasMagicDisallowEnchanting(thisForm)) continue;
				if (excludePlayerEnchants && IsPlayerCraftedEnchantment(thisEnchantment)) continue;

				for (UInt32 limit = 3; thisEnchantment->data.baseEnchantment && (limit > 0); limit--)
					thisEnchantment = thisEnchantment->data.baseEnchantment;

				forms.Set(&thisForm, fillIndex);
				enchantments.Set(&thisEnchantment, fillIndex);
				++fillIndex;
			}
		}

		//Check the extra data too (I don't think this is really necessary for player inventory, but just in case)
		ExtraContainerEnchantedItemExtractor extraEnchantedItems(pContainerRef);
		extraEnchantedItems.GetExtraEnchantedForms(&forms, &enchantments, fillIndex, excludePlayerEnchants, excludeDisallowEnchanting);
		return true;
	}


	//Enchanting Awakened function to check if form is enchanted, and return specific data about it.
	bool CheckFormForEnchantment(StaticFunctionTag* base, TESForm* form, VMArray<TESForm*> returnData)
	{
		EnchantmentItem* enchantment = NULL;

		if (TESObjectARMO* armor = DYNAMIC_CAST(form, TESForm, TESObjectARMO))
			enchantment = armor->enchantable.enchantment;
		else if (TESObjectWEAP* weapon = DYNAMIC_CAST(form, TESForm, TESObjectWEAP))
			enchantment = weapon->enchantable.enchantment;

		if (!enchantment || IsPlayerCraftedEnchantment(enchantment) || returnData.Length() < 3)
			return false;

		BGSKeywordForm* keys = DYNAMIC_CAST(form, TESForm, BGSKeywordForm);
		if (!keys || keys->numKeywords < 1)
			return false;

		if (KeyListHasMagicDisallowEnchanting(keys))
			return false;

		for (UInt32 limit = 3; enchantment->data.baseEnchantment && (limit > 0); limit--)
			enchantment = enchantment->data.baseEnchantment;

		TESForm* enchantmentForm = DYNAMIC_CAST(enchantment, EnchantmentItem, TESForm);
		TESForm* keywordForm = keys->keywords[0];

		returnData.Set(&form, 0);
		returnData.Set(&enchantmentForm, 1);
		returnData.Set(&keywordForm, 2);
		return true;
	}


	void GetFormNames(StaticFunctionTag* base, VMArray<TESForm*> inputForms, VMArray<BSFixedString> returnStrings)
	{
		if (returnStrings.Length() < inputForms.Length())
			return;

		for (UInt32 i = 0; i < inputForms.Length(); ++i)
		{
			TESForm* thisForm = NULL;
			inputForms.Get(&thisForm, i);
			if (!thisForm) //terminate when NULL entry is found (should signal end of array)
				return;

			TESFullName* thisName = DYNAMIC_CAST(thisForm, TESForm, TESFullName);
			if (!thisName)
			{
				_MESSAGE("ERROR: Couldn't process name data for form 0x%08X", thisForm->formID);
				return;
			}

			returnStrings.Set(&thisName->name, i);
		}
	}


	bool IsSpellSkillType(StaticFunctionTag* base, SpellItem* spell, BSFixedString skillType)
	{
		if (!skillType.data)
			return false;

		UInt32 school = LookupActorValueByName(skillType.data);
		if (!spell || spell->data.type != 0x00 || school < 18 || school > 22) //0x00 == "Spell" (ignore voice/ability/disease/etc)
			return false;

		for (UInt32 i = 0; i < spell->effectItemList.count; ++i)
		{
			MagicItem::EffectItem* effect = NULL;
			spell->effectItemList.GetNthItem(i, effect);
			if (effect && effect->mgef->properties.school == school)
				return true;
		}
		return false;
	}


	BSFixedString GetSpellSkillString(StaticFunctionTag* base, SpellItem* spell)
	{
		if (!spell || spell->data.type != 0x00) //0x00 == "Spell" (ignore voice/ability/disease/etc)
			return magicSkillStrings.NullString;

		for (UInt32 i = 0; i < spell->effectItemList.count; ++i)
		{
			MagicItem::EffectItem* effect = NULL;
			spell->effectItemList.GetNthItem(i, effect);
			if (effect && effect->mgef->properties.school >= 18 && effect->mgef->properties.school <= 22)
				return magicSkillStrings.LookupSkillString(effect->mgef->properties.school);
		}
		return magicSkillStrings.NullString;
	}

	UInt32 GetSpellSkillNumber(StaticFunctionTag* base, SpellItem* spell)
	{
		if (!spell || spell->data.type != 0x00) //0x00 == "Spell" (ignore voice/ability/disease/etc)
			return 0xFFFFFFFF;

		for (UInt32 i = 0; i < spell->effectItemList.count; ++i)
		{
			MagicItem::EffectItem* effect = NULL;
			spell->effectItemList.GetNthItem(i, effect);
			if (effect)
			{
				UInt32 skillNum = effect->mgef->properties.school - 18;
				if (skillNum < 5)
					return skillNum;
			}
		}
		return 0xFFFFFFFF;
	}

	//Returns number of normal (not player-created) known enchantments, and inserts them all into outputKnown array.
	//Returns -1 if no enchantments are known by the player.
	UInt32 GetPlayerKnownEnchantments(StaticFunctionTag* base, VMArray<EnchantmentItem*> outputKnown)
	{
		DataHandler* dh = DataHandler::GetSingleton();
		std::vector<EnchantmentItem*> knownEnchants;
		knownEnchants.clear();

		for(UInt32 i = 0; i < dh->enchantments.count; i++)
		{
			EnchantmentItem* ench = NULL;
			dh->enchantments.GetNthItem(i, ench);
			if (ench && (ench->flags & TESForm::kFlagPlayerKnows))
				knownEnchants.push_back(ench); //player knows
		}

		if (outputKnown.Length() < knownEnchants.size())
		{
			_MESSAGE("GetPlayerKnownEnchantments overflow error: known(%u), outputCapacity(%u)", knownEnchants.size(), outputKnown.Length());
			return 0xFFFFFFFF;
		}

		for (UInt32 i = 0; i < knownEnchants.size(); i++)
			outputKnown.Set(&knownEnchants[i], i);

		return knownEnchants.size();
	}


}




// template <> void UnpackValue(VMArray<TESForm*> * dst, VMValue * src)
// {
// 	UnpackArray(dst, src, GetTypeIDFromFormTypeID(TESForm::kTypeID, (*g_skyrimVM)->GetClassRegistry()) | VMValue::kType_Identifier);
// }

// template <> void UnpackValue(VMArray<BGSKeyword*> * dst, VMValue * src)
// {
// 	UnpackArray(dst, src, GetTypeIDFromFormTypeID(BGSKeyword::kTypeID, (*g_skyrimVM)->GetClassRegistry()) | VMValue::kType_Identifier);
// }



bool RegisterPapyrusEAExtender(VMClassRegistry* registry)
{
	registry->RegisterFunction(
		new NativeFunction1<StaticFunctionTag, UInt32, SpellItem*>("GetSpellSkillNumber", "EA_Extender", papyrusEAExtender::GetSpellSkillNumber, registry));
	registry->RegisterFunction(
		new NativeFunction1<StaticFunctionTag, BSFixedString, SpellItem*>("GetSpellSkillString", "EA_Extender", papyrusEAExtender::GetSpellSkillString, registry));
	registry->RegisterFunction(
		new NativeFunction2<StaticFunctionTag, bool, SpellItem*, BSFixedString>("IsSpellSkillType", "EA_Extender", papyrusEAExtender::IsSpellSkillType, registry));
	registry->RegisterFunction(
		new NativeFunction2<StaticFunctionTag, void, VMArray<TESForm*>, VMArray<BSFixedString>>("GetFormNames", "EA_Extender", papyrusEAExtender::GetFormNames, registry));

	registry->RegisterFunction(
		new NativeFunction2<StaticFunctionTag, bool, TESForm*, VMArray<TESForm*>>("CheckFormForEnchantment", "EA_Extender", papyrusEAExtender::CheckFormForEnchantment, registry));
	registry->RegisterFunction(
		new NativeFunction3<StaticFunctionTag, void, VMArray<TESForm*>, UInt32, VMArray<BGSKeyword*>>("GetFormArrayNthKeywords", "EA_Extender", papyrusEAExtender::GetFormArrayNthKeywords, registry));
	registry->RegisterFunction(
		new NativeFunction5<StaticFunctionTag, bool, TESObjectREFR*, VMArray<TESForm*>, VMArray<EnchantmentItem*>, bool, bool>("GetEnchantedForms", "EA_Extender", papyrusEAExtender::GetEnchantedForms, registry));

	registry->RegisterFunction(
		new NativeFunction3<StaticFunctionTag, void, TESForm*, UInt32, BGSKeyword*>("SetNthKeyword", "EA_Extender", papyrusEAExtender::SetNthKeyword, registry));
	registry->RegisterFunction(
		new NativeFunction3<StaticFunctionTag, void, VMArray<TESForm*>, UInt32, BGSKeyword*>("SetFormArrayNthKeyword", "EA_Extender", papyrusEAExtender::SetFormArrayNthKeyword, registry));
	registry->RegisterFunction(
		new NativeFunction3<StaticFunctionTag, void, VMArray<TESForm*>, UInt32, VMArray<BGSKeyword*>>("SetFormArrayNthKeywordArray", "EA_Extender", papyrusEAExtender::SetFormArrayNthKeywordArray, registry));


	registry->SetFunctionFlags("EA_Extender", "GetSpellSkillNumber", VMClassRegistry::kFunctionFlag_NoWait);
	registry->SetFunctionFlags("EA_Extender", "GetSpellSkillString", VMClassRegistry::kFunctionFlag_NoWait);
	registry->SetFunctionFlags("EA_Extender", "IsSpellSkillType", VMClassRegistry::kFunctionFlag_NoWait);
	registry->SetFunctionFlags("EA_Extender", "GetFormNames", VMClassRegistry::kFunctionFlag_NoWait);

	registry->SetFunctionFlags("EA_Extender", "CheckFormForEnchantment", VMClassRegistry::kFunctionFlag_NoWait);
	registry->SetFunctionFlags("EA_Extender", "GetFormArrayNthKeywords", VMClassRegistry::kFunctionFlag_NoWait);
	registry->SetFunctionFlags("EA_Extender", "GetEnchantedForms", VMClassRegistry::kFunctionFlag_NoWait);

	registry->SetFunctionFlags("EA_Extender", "SetNthKeyword", VMClassRegistry::kFunctionFlag_NoWait);
	registry->SetFunctionFlags("EA_Extender", "SetFormArrayNthKeyword", VMClassRegistry::kFunctionFlag_NoWait);
	registry->SetFunctionFlags("EA_Extender", "SetFormArrayNthKeywordArray", VMClassRegistry::kFunctionFlag_NoWait);

	return true;
}