#include "skse/GameForms.h"
#include "skse/GameObjects.h"
#include "skse/GameExtraData.h"
#include "skse/GameData.h"
#include "skse/GameRTTI.h"
#include "skse/PapyrusPerk.h"
#include <map>
#include <vector>

#include "Ini.h"
#include "Papyrus.h"
#include "Events.h"
#include "Learning.h"
#include "DataHandler.h"
#include "ExtraEnchantmentInfo.h"


//For unpacking VMArray of various form types
template <typename T>
void UnpackValue(VMArray<T*>* dst, VMValue* src)
{
	UnpackArray(dst, src, GetTypeIDFromFormTypeID(T::kTypeID, (*g_skyrimVM)->GetClassRegistry()) | VMValue::kType_Identifier);
}


class MagicSkillStrings //I think I can singleton these from 0x0106B4EC to 0x0106B4FC [same order as below, no null string of course]
{
public:
	static MagicSkillStrings& Instance()
	{
		static MagicSkillStrings instance;
		return instance;
	}

	BSFixedString LookupSkillString(UInt32 skillNumber)
	{
		switch(skillNumber)
		{
			case 18:	return Alteration;
			case 19:	return Conjuration;
			case 20:	return Destruction;
			case 21:	return Illusion;
			case 22:	return Restoration;
			default:	return NullString;
		}
	}

	BSFixedString Alteration;
	BSFixedString Conjuration;
	BSFixedString Destruction;
	BSFixedString Illusion;
	BSFixedString Restoration;
	BSFixedString NullString;

private:
	MagicSkillStrings() :
		Alteration("Alteration"),
		Conjuration("Conjuration"),
		Destruction("Destruction"),
		Illusion("Illusion"),
		Restoration("Restoration"),
		NullString("") {}
};

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



class ExtraContainerEnchantedItemExtractor
{
private:
	struct FormEnchantmentPair
	{
		TESForm*			form;
		EnchantmentItem*	enchantment;
		FormEnchantmentPair(TESForm* f, EnchantmentItem* e) : form(f), enchantment(e) {}
	};

	typedef std::vector<FormEnchantmentPair> FormEnchantmentVec;
	
	ExtraContainerChanges::EntryDataList*	containerList;
	FormEnchantmentVec						enchantedItemVec;

public:
	ExtraContainerEnchantedItemExtractor(TESObjectREFR* reference) : enchantedItemVec()
	{
		enchantedItemVec.clear();
		ExtraContainerChanges* pXContainerChanges = static_cast<ExtraContainerChanges*>(reference->extraData.GetByType(kExtraData_ContainerChanges));
		containerList = (pXContainerChanges) ? pXContainerChanges->data->objList : NULL;
	}

	bool GetExtraEnchantedForms(VMArray<TESForm*>* fillForms, VMArray<EnchantmentItem*>* fillEnchantments, UInt32 startIndex, bool excludePlayerEnchants, bool excludeDisallowEnchanting)
	{
		if (!containerList)
			return false;

		if (enchantedItemVec.size() == 0)
			containerList->Visit(*this);

		FormEnchantmentVec::iterator it = enchantedItemVec.begin();
		for (UInt32 i = startIndex; (i < fillForms->Length()) && (it != enchantedItemVec.end()); ++it)
		{
			if (excludeDisallowEnchanting && FormHasMagicDisallowEnchanting(it->form)) continue;
			if (excludePlayerEnchants && IsPlayerCraftedEnchantment(it->enchantment)) continue;

			for (UInt32 limit = 3; it->enchantment->data.baseEnchantment && (limit > 0); limit--)
				it->enchantment = it->enchantment->data.baseEnchantment;

			fillForms->Set(&it->form, i);
			fillEnchantments->Set(&it->enchantment, i);

			++i;
		}

		return true;
	}

	bool Accept(ExtraContainerChanges::EntryData* data) 
	{
		if (data && (data->countDelta > 0))
		{
			TESForm* dataForm = data->type;

			if (TESObjectARMO* dataArmor = DYNAMIC_CAST(dataForm, TESForm, TESObjectARMO))
			{
				if (dataArmor->enchantable.enchantment)
					enchantedItemVec.push_back(FormEnchantmentPair(dataForm, dataArmor->enchantable.enchantment));
			}
			else if (TESObjectWEAP* dataWeapon = DYNAMIC_CAST(dataForm, TESForm, TESObjectWEAP))
			{
				if (dataWeapon->enchantable.enchantment)
					enchantedItemVec.push_back(FormEnchantmentPair(dataForm, dataWeapon->enchantable.enchantment));
			}
		}
		return true;
	}
};




namespace PapyrusEAExtender
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


	UInt32 GetEnchantmentMagicEffects(StaticFunctionTag* base, EnchantmentItem* enchantment, VMArray<EffectSetting*> outputMGEFs)
	{
		MagicItem* mi = DYNAMIC_CAST(enchantment, EnchantmentItem, MagicItem);
		if (mi)
		{
			UInt32 max = (mi->effectItemList.count < outputMGEFs.Length()) ? mi->effectItemList.count : outputMGEFs.Length();
			for (UInt32 n = 0; n < max; n++)
			{
				MagicItem::EffectItem* ei = NULL;
				mi->effectItemList.GetNthItem(n, ei);
				outputMGEFs.Set(&ei->mgef, n);
			}
			return max;
		}
		return 0;
	}


	//Returns number of normal (not player-created) known enchantments, and inserts them all into outputKnown array.
	//Returns -1 if no enchantments are known by the player.
	// UInt32 GetPlayerKnownEnchantments(StaticFunctionTag* base, VMArray<EnchantmentItem*> outputKnown)
	// {
	// 	DataHandler* dh = DataHandler::GetSingleton();
	// 	std::vector<EnchantmentItem*> knownEnchants;
	// 	knownEnchants.clear();

	// 	for(UInt32 i = 0; i < dh->enchantments.count; i++)
	// 	{
	// 		EnchantmentItem* ench = NULL;
	// 		dh->enchantments.GetNthItem(i, ench);
	// 		if (ench && (ench->flags & TESForm::kFlagPlayerKnows))
	// 			knownEnchants.push_back(ench); //player knows
	// 	}

	// 	UInt32 knownSize = knownEnchants.size();
	// 	if (outputKnown.Length() < knownSize)
	// 	{
	// 		_MESSAGE("Error: GetPlayerKnownEnchantments Overflow: Known(%u), OutputCapacity(%u)", knownSize, outputKnown.Length());
	// 		knownSize = outputKnown.Length();
	// 	}

	// 	for (UInt32 i = 0; i < knownSize; i++)
	// 		outputKnown.Set(&knownEnchants[i], i);

	// 	return knownSize;
	// }


	BSFixedString GetLearnEventName(StaticFunctionTag* base)
	{
		return BSFixedString(LEARN_EVENT_NAME.c_str());
	}

	void FillFormlistWithChildrenOfBaseEnchantments(StaticFunctionTag* base, BGSListForm* formlist, VMArray<EnchantmentItem*> baseEnchantments, bool terminateWhenNull)
	{
		BaseEnchantmentUseResearcher* research = BaseEnchantmentUseResearcher::GetSingleton();

		for (UInt32 i = 0; i < baseEnchantments.Length(); i++)
		{
			EnchantmentItem* thisBase = NULL;
			baseEnchantments.Get(&thisBase, i);
			if (!thisBase && terminateWhenNull)
				return;
			research->AddChildrenToList(thisBase, formlist);
		}
	}

	void FillFormlistWithChildrenOfBaseEnchantmentsList(StaticFunctionTag* base, BGSListForm* formlist, BGSListForm* baseEnchantments)
	{
		DerivedEnchantmentListProcessor children(formlist);
		baseEnchantments->Visit(children);
	}

	void SetPerkEntryValues(StaticFunctionTag* base, VMArray<BGSPerk*> perks, VMArray<float> newVals, UInt32 epIndex)
	{
		UInt32 maxIndex = (perks.Length() > newVals.Length()) ? newVals.Length() : perks.Length();

		for (UInt32 i = 0; i < maxIndex; i++)
		{
			BGSPerk* thisPerk = NULL;
			perks.Get(&thisPerk, i);
			float thisValue = 0.0;
			newVals.Get(&thisValue, i);
			papyrusPerk::SetNthEntryValue(thisPerk, epIndex, 0, thisValue);
		}
		// papyrusPerk::SetNthEntryValue(BGSPerk * perk, UInt32 n, UInt32 i, float value);
	}

	void GetIniPerkPowerVals(StaticFunctionTag* base, VMArray<float> basePowers, VMArray<float> learnPowers)
	{
		if (basePowers.Length() < 12 || learnPowers.Length() < 12)
			return;

		EnchantingAwakenedINIManager::Instance.GetIniPerkPowerVals(basePowers, learnPowers);
	}

	void SetOffensiveEnchantmentLearnExperienceMult(StaticFunctionTag* base, float newMultiplier)
	{
		Learning::kLearnExperienceMultiplier = newMultiplier;
	}

	void SetOffensiveEnchantmentLearnLevelThresholds(StaticFunctionTag* base, VMArray<float> thresholds)
	{
		for (UInt32 i = 0; i < thresholds.Length(); i++)
		{
			float thisValue;
			thresholds.Get(&thisValue, i);
			if (thisValue >= 1.0) //skip 0
				Learning::LearnLevelThresholds.insert(thisValue);
		}
	}

	BSFixedString GetArmorEnchantmentEquipEventName(StaticFunctionTag* base)
	{
		return BSFixedString(EQUIP_ENCHANTMENT_EVENT_NAME.c_str());
	}




	// void DumpSpellsAndEffects(StaticFunctionTag* base)
	// {
	// 	Actor* pActor = (*g_thePlayer);

	// 	_MESSAGE("\n\nActor Spells:");
	// 	for(int i = 0; i < pActor->addedSpells.Length(); i++)
	// 	{
	// 		SpellItem* s = pActor->addedSpells.Get(i);
	// 		_MESSAGE("    %u  -  0x%08X  [%s]", i, s->formID, (DYNAMIC_CAST(s, SpellItem, TESFullName))->name.data);
	// 	}

	// 	tList<ActiveEffect> * effects = pActor->magicTarget.GetActiveEffects();
	// 	if(effects)
	// 	{
	// 		_MESSAGE("\n\nActor ActiveEffects:");
	// 		for(int i = 0; i < effects->Count(); i++)
	// 		{
	// 			ActiveEffect * pEffect = effects->GetNthItem(i);
	// 			_MESSAGE("  ITEM %u", i);
	// 			EnchantmentItem* ei = DYNAMIC_CAST(pEffect->item, MagicItem, EnchantmentItem);
	// 			SpellItem* si = DYNAMIC_CAST(pEffect->item, MagicItem, SpellItem);
	// 			_MESSAGE("    enchantment: %08X [%s]", (ei) ? ei->formID : 0, (ei) ? (DYNAMIC_CAST(ei, EnchantmentItem, TESFullName))->name.data : "NONE");
	// 			_MESSAGE("    spell:       %08X [%s]", (si) ? si->formID : 0, (si) ? (DYNAMIC_CAST(si, SpellItem, TESFullName))->name.data : "NONE");
	// 			ei = DYNAMIC_CAST(pEffect->sourceItem, TESForm, EnchantmentItem);
	// 			si = DYNAMIC_CAST(pEffect->sourceItem, TESForm, SpellItem);
	// 			_MESSAGE("    source     : %08X [%s]", (pEffect->sourceItem) ? pEffect->sourceItem->formID : 0, (pEffect->sourceItem) ? (DYNAMIC_CAST(pEffect->sourceItem, TESForm, TESFullName))->name.data : "NONE");
	// 			_MESSAGE("    effectItem mgef:    %08X [%s]", (pEffect->effect->mgef) ? pEffect->effect->mgef->formID : 0, (pEffect->effect->mgef) ? (DYNAMIC_CAST(pEffect->effect->mgef, EffectSetting, TESFullName))->name.data : "NONE");
	// 			_MESSAGE("    data  -  elapsed: %g duration: %g magnitude: %g inactive: %s", pEffect->elapsed, pEffect->duration, pEffect->magnitude,
	// 			 				((pEffect->flags & ActiveEffect::kFlag_Inactive) == ActiveEffect::kFlag_Inactive) ? "TRUE" : "FALSE");

	// 		}
	// 	}
	// }

	void ApplyIniMultModifiers(StaticFunctionTag* base, VMArray<float> multsToModify)
	{
		if (multsToModify.Length() < 36)
			return;
		EnchantingAwakenedINIManager::Instance.ApplyIniMultModifiers(multsToModify);
	}


	void DumpLearningDataInternal(VMArray<EnchantmentItem*> &ench, VMArray<float> &enchXP, VMArray<UInt32> &enchLvl, std::map<UInt32, std::string> &modNames)
	{
		for(UInt32 i = 0; i < ench.Length(); i++)
		{
			EnchantmentItem* e = NULL;
			float xp = NULL;
			UInt32 lvl = NULL;
			ench.Get(&e, i);
			enchXP.Get(&xp, i);
			enchLvl.Get(&lvl, i);

			int formIndex = (e) ? e->formID & 0xFF000000 : 0;
			if (modNames.find(formIndex) == modNames.end())
			{
				char modName[0x104];
				DataHandler* pData = DataHandler::GetSingleton();
				ModInfo* mInfo = (pData) ? pData->modList.modInfoList.GetNthItem(formIndex) : NULL;
				strcpy_s(modName, (mInfo) ? mInfo->name : "");
				std::string modStr = modName;
				modNames[formIndex] = modStr;
			}

			_MESSAGE("[0x%08X] %-40s xp: %10g lvl: %4d   (src mod: %s)"
				, (e) ? e->formID & 0x00FFFFFF : 0
				, (e) ? (DYNAMIC_CAST(e, EnchantmentItem, TESFullName))->name.data : "NULL"
				, xp
				, lvl
				, (e) ? modNames[e->formID & 0xFF000000].c_str() : "NULL");
		}
	}

	void DumpLearningData(StaticFunctionTag* base, VMArray<EnchantmentItem*> dEnch, VMArray<float> dEnchXP, VMArray<UInt32> dEnchLvl, VMArray<EnchantmentItem*> oEnch, VMArray<float> oEnchXP, VMArray<UInt32> oEnchLvl)
	{
		std::map<UInt32, std::string> modNames;

		_MESSAGE("\n\nDUMPING CURRENT LEARNING PROGRESS:");
		gLog.Indent();
		_MESSAGE("\nWeapon Enchantments ---->");
		gLog.Indent();

		DumpLearningDataInternal(oEnch, oEnchXP, oEnchLvl, modNames);

		gLog.Outdent();
		_MESSAGE("\nArmor Enchantments ---->");
		gLog.Indent();

		DumpLearningDataInternal(dEnch, dEnchXP, dEnchLvl, modNames);
	}
}


bool RegisterPapyrusEAExtender(VMClassRegistry* registry)
{
	registry->RegisterFunction(
		new NativeFunction2<StaticFunctionTag, UInt32, EnchantmentItem*, VMArray<EffectSetting*>>("GetEnchantmentMagicEffects", "EA_Extender", PapyrusEAExtender::GetEnchantmentMagicEffects, registry));
	registry->RegisterFunction(
		new NativeFunction1<StaticFunctionTag, UInt32, SpellItem*>("GetSpellSkillNumber", "EA_Extender", PapyrusEAExtender::GetSpellSkillNumber, registry));
	registry->RegisterFunction(
		new NativeFunction1<StaticFunctionTag, BSFixedString, SpellItem*>("GetSpellSkillString", "EA_Extender", PapyrusEAExtender::GetSpellSkillString, registry));
	registry->RegisterFunction(
		new NativeFunction2<StaticFunctionTag, bool, SpellItem*, BSFixedString>("IsSpellSkillType", "EA_Extender", PapyrusEAExtender::IsSpellSkillType, registry));
	registry->RegisterFunction(
		new NativeFunction2<StaticFunctionTag, void, VMArray<TESForm*>, VMArray<BSFixedString>>("GetFormNames", "EA_Extender", PapyrusEAExtender::GetFormNames, registry));

	registry->RegisterFunction(
		new NativeFunction2<StaticFunctionTag, bool, TESForm*, VMArray<TESForm*>>("CheckFormForEnchantment", "EA_Extender", PapyrusEAExtender::CheckFormForEnchantment, registry));
	registry->RegisterFunction(
		new NativeFunction3<StaticFunctionTag, void, VMArray<TESForm*>, UInt32, VMArray<BGSKeyword*>>("GetFormArrayNthKeywords", "EA_Extender", PapyrusEAExtender::GetFormArrayNthKeywords, registry));
	registry->RegisterFunction(
		new NativeFunction5<StaticFunctionTag, bool, TESObjectREFR*, VMArray<TESForm*>, VMArray<EnchantmentItem*>, bool, bool>("GetEnchantedForms", "EA_Extender", PapyrusEAExtender::GetEnchantedForms, registry));

	registry->RegisterFunction(
		new NativeFunction3<StaticFunctionTag, void, TESForm*, UInt32, BGSKeyword*>("SetNthKeyword", "EA_Extender", PapyrusEAExtender::SetNthKeyword, registry));
	registry->RegisterFunction(
		new NativeFunction3<StaticFunctionTag, void, VMArray<TESForm*>, UInt32, BGSKeyword*>("SetFormArrayNthKeyword", "EA_Extender", PapyrusEAExtender::SetFormArrayNthKeyword, registry));
	registry->RegisterFunction(
		new NativeFunction3<StaticFunctionTag, void, VMArray<TESForm*>, UInt32, VMArray<BGSKeyword*>>("SetFormArrayNthKeywordArray", "EA_Extender", PapyrusEAExtender::SetFormArrayNthKeywordArray, registry));
	registry->RegisterFunction(
		new NativeFunction0<StaticFunctionTag, BSFixedString>("GetLearnEventName", "EA_Extender", PapyrusEAExtender::GetLearnEventName, registry));
	registry->RegisterFunction(
		new NativeFunction3<StaticFunctionTag, void, BGSListForm*, VMArray<EnchantmentItem*>, bool>("FillFormlistWithChildrenOfBaseEnchantments", "EA_Extender", PapyrusEAExtender::FillFormlistWithChildrenOfBaseEnchantments, registry));
	registry->RegisterFunction(
		new NativeFunction2<StaticFunctionTag, void, BGSListForm*, BGSListForm*>("FillFormlistWithChildrenOfBaseEnchantmentsList", "EA_Extender", PapyrusEAExtender::FillFormlistWithChildrenOfBaseEnchantmentsList, registry));
	registry->RegisterFunction(
		new NativeFunction3<StaticFunctionTag, void, VMArray<BGSPerk*>, VMArray<float>, UInt32>("SetPerkEntryValues", "EA_Extender", PapyrusEAExtender::SetPerkEntryValues, registry));
	registry->RegisterFunction(
		new NativeFunction1<StaticFunctionTag, void, float>("SetOffensiveEnchantmentLearnExperienceMult", "EA_Extender", PapyrusEAExtender::SetOffensiveEnchantmentLearnExperienceMult, registry));
	registry->RegisterFunction(
		new NativeFunction1<StaticFunctionTag, void, VMArray<float>>("SetOffensiveEnchantmentLearnLevelThresholds", "EA_Extender", PapyrusEAExtender::SetOffensiveEnchantmentLearnLevelThresholds, registry));
	// registry->RegisterFunction(
	// 	new NativeFunction0<StaticFunctionTag, void>("DumpSpellsAndEffects", "EA_Extender", PapyrusEAExtender::DumpSpellsAndEffects, registry));
	registry->RegisterFunction(
		new NativeFunction0<StaticFunctionTag, BSFixedString>("GetArmorEnchantmentEquipEventName", "EA_Extender", PapyrusEAExtender::GetArmorEnchantmentEquipEventName, registry));
	registry->RegisterFunction(
		new NativeFunction1<StaticFunctionTag, void, VMArray<float>>("ApplyIniMultModifiers", "EA_Extender", PapyrusEAExtender::ApplyIniMultModifiers, registry));
	registry->RegisterFunction(
		new NativeFunction2<StaticFunctionTag, void, VMArray<float>, VMArray<float>>("GetIniPerkPowerVals", "EA_Extender", PapyrusEAExtender::GetIniPerkPowerVals, registry));

	registry->RegisterFunction(
		new NativeFunction6<StaticFunctionTag, void, VMArray<EnchantmentItem*>, VMArray<float>, VMArray<UInt32>, VMArray<EnchantmentItem*>, VMArray<float>, VMArray<UInt32>>("DumpLearningData", "EA_Extender", PapyrusEAExtender::DumpLearningData, registry));

	registry->SetFunctionFlags("EA_Extender", "GetEnchantmentMagicEffects", VMClassRegistry::kFunctionFlag_NoWait);
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

	registry->SetFunctionFlags("EA_Extender", "FillFormlistWithChildrenOfBaseEnchantments", VMClassRegistry::kFunctionFlag_NoWait);
	registry->SetFunctionFlags("EA_Extender", "FillFormlistWithChildrenOfBaseEnchantmentsList", VMClassRegistry::kFunctionFlag_NoWait);
	registry->SetFunctionFlags("EA_Extender", "SetPerkEntryValues", VMClassRegistry::kFunctionFlag_NoWait);
	registry->SetFunctionFlags("EA_Extender", "ApplyIniMultModifiers", VMClassRegistry::kFunctionFlag_NoWait);
	registry->SetFunctionFlags("EA_Extender", "GetIniPerkPowerVals", VMClassRegistry::kFunctionFlag_NoWait);

	return true;
}