#include "skse/PluginAPI.h"
#include "skse/skse_version.h"
#include "skse/ScaleformCallbacks.h"
#include "skse/ScaleformMovie.h"
#include "skse/GameAPI.h"
//#include "skse/SafeWrite.h"

#include "skse/GameForms.h"
#include "skse/GameObjects.h"
#include "skse/GameFormComponents.h"
#include "skse/GameExtraData.h"
#include "skse/GameBSExtraData.h"
#include "skse/GameRTTI.h"
#include "skse/GameData.h"

#include "skse/PapyrusArgs.h"
#include "skse/GameObjects.h"
#include "skse/GameRTTI.h"
#include "skse/PapyrusVM.h"
#include "skse/PapyrusNativeFunctions.h"

#include <shlobj.h>
#include <vector>


IDebugLog						gLog;
const char*						kLogPath = "\\My Games\\Skyrim\\Logs\\EA_Extender.log";

PluginHandle	g_pluginHandle = kPluginHandle_Invalid;

SKSEScaleformInterface		* g_scaleform = NULL;
SKSESerializationInterface	* g_serialization = NULL;
SKSEPapyrusInterface   *g_papyrus = NULL;

class VMClassRegistry;
class VMValue;
struct StaticFunctionTag;



class MagicSkillStrings
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



char* GetFunctionName(UInt32 functionID);


class MatchByEquipSlot : public FormMatcher
{
	UInt32 m_mask;
	UInt32 m_hand;
	Actor * m_actor;
public:
	MatchByEquipSlot(Actor * actor, UInt32 hand, UInt32 slot) : 
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

namespace utilFuncs
{
	BSFixedString GetDisplayName(TESForm* baseForm, BaseExtraList* extraData)
	{
		return (baseForm && extraData) ? extraData->GetDisplayName(baseForm) : "";
	}

	EquipData ResolveEquippedObject(Actor * actor, UInt32 weaponSlot, UInt32 slotMask)
	{
		EquipData foundData;
		foundData.pForm = NULL;
		foundData.pExtraData = NULL;
		if(!actor)
			return foundData;

		MatchByEquipSlot matcher(actor, weaponSlot, slotMask);
		ExtraContainerChanges* pContainerChanges = static_cast<ExtraContainerChanges*>(actor->extraData.GetByType(kExtraData_ContainerChanges));
		if (pContainerChanges) {
			foundData = pContainerChanges->FindEquipped(matcher, weaponSlot == MatchByEquipSlot::kSlotID_Right, weaponSlot == MatchByEquipSlot::kSlotID_Left);
			return foundData;
		}

		return foundData;
	}

	EnchantmentItem* GetEnchantment(BaseExtraList * extraData)
	{
		if (!extraData)
			return NULL;

		ExtraEnchantment* extraEnchant = static_cast<ExtraEnchantment*>(extraData->GetByType(kExtraData_Enchantment));
		return extraEnchant ? extraEnchant->enchant : NULL;
	}

	EnchantmentItem* GetExtraEnchantment(Actor* actor, TESObjectWEAP* pWeap)
	{
		if (!actor || !pWeap)
			return NULL;

		TESForm* eqForm = DYNAMIC_CAST(pWeap, TESObjectWEAP, TESForm);
		UInt32 equipSlot = ((actor->GetEquippedObject(false)) == eqForm) ? 1 : 0; //find slot eqForm was equipped into
		UInt32 wornSlot = 0;

		EquipData equipData = ResolveEquippedObject(actor, equipSlot, wornSlot);
		if(equipData.pForm && equipData.pExtraData)
			return GetEnchantment(equipData.pExtraData);

		return NULL;
	}

	UInt32 CalcMagicItemCost(MagicItem* magItem)
	{
		if (!magItem)
			return 0;

		UInt32 totalCost = 0;
		for (UInt32 i = 0; i < magItem->effectItemList.count; i++)
		{
			MagicItem::EffectItem* pEffectItem = NULL;
			magItem->effectItemList.GetNthItem(i, pEffectItem);
			if (pEffectItem)
				totalCost += (UInt32)pEffectItem->cost;
		}
		return totalCost;
	}
}


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




struct FormEnchantmentPair
{
	TESForm*			form;
	EnchantmentItem*	enchantment;
	FormEnchantmentPair(TESForm* f, EnchantmentItem* e) : form(f), enchantment(e) {}
};

typedef std::vector<FormEnchantmentPair> FormEnchantmentVec;

class ExtraContainerEnchantedItemExtractor
{
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

private:
	ExtraContainerChanges::EntryDataList*	containerList;
	FormEnchantmentVec						enchantedItemVec;
};



// class KeywordCollection
// {
// public:
// 	KeywordCollection(VMArray<TESForm*>& forms, UInt32 num) : keys()
// 	{
// 		for(UInt32 i = 0; i < forms->Length(); i++)
// 		{
// 			TESForm* thisForm = NULL;
// 			forms->Get(&thisForm, i);
// 			if (!thisForm) //terminate function when NULL entry is found (should signal end of array contents)
// 				break;

// 			BGSKeywordForm* pKeywords = DYNAMIC_CAST(thisForm, TESForm, BGSKeywordForm);
// 			if (pKeywords && num < pKeywords->numKeywords)
// 				keys.push_back(pKeywords->keywords[num]);
// 		}
// 	}

// private:
// 	std::vector<BGSKeyword*>	keys;
// };



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

	void DumpEnchantmentValues(EnchantmentItem* pEnch); //forward declaration
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


	void DumpEnchantmentValues(EnchantmentItem* pEnch)
	{
		if (!pEnch) { _MESSAGE("Cant dump values on a NULL enchantment");
			return; }

		for (UInt32 i = 0; i < pEnch->effectItemList.count; i++)
		{
			MagicItem::EffectItem* pEff = NULL;
			pEnch->effectItemList.GetNthItem(i, pEff);

			//unk14 == condition

			Condition* pCond = reinterpret_cast<Condition*>(pEff->unk14);//(pEff->condition);
			if (pCond)
			{
				_MESSAGE("    Effect %u Conditions:        ", i);
				for (UInt32 count = 1; pCond; pCond = pCond->next, count++)
				{
					//_MESSAGE("      Condition #%u              Function: %s", count, GetFunctionName(pCond->functionId));
				}
			}
			else
				_MESSAGE("    Condition %u:               NULL (%u) (%u)", i, pCond, pEff->unk14);//pEff->condition);
		}

		//base value
		// TESValueForm* pValue = DYNAMIC_CAST(equippedForm, TESForm, TESValueForm);
		// _MESSAGE("\n    Weapon Base Value:         %d", pValue ? pValue->value : 0);

		//enchant values
		_MESSAGE("    Manual Calc Flag Set?      %s", ((pEnch->data.calculations.flags & 0x01) == 0x01) ? "YES" : "NO");
		_MESSAGE("    'Enchantment Cost':        %d", pEnch->data.calculations.cost);
		_MESSAGE("    'Ench Amount':             %d", pEnch->data.unk0C);
		_MESSAGE("    Enchantment Auto Value:    %d\n\n", utilFuncs::CalcMagicItemCost(DYNAMIC_CAST(pEnch, EnchantmentItem, MagicItem)));

		EnchantmentItem* pBaseEnch = pEnch->data.baseEnchantment;
		_MESSAGE("    (acquired base enchantment)");
		_MESSAGE("    BASE Enchantment:          %08X", pBaseEnch ? pBaseEnch->formID : 0x00000000);

	}


	void DumpEnchantedWeaponValues(StaticFunctionTag* base)
	{

		// //TEST DUMP OF ALL ENCHANTMENTS.....
		// DataHandler* dh = DataHandler::GetSingleton();

		// for(UInt32 i = 0; i < dh->enchantments.count; i++)
		// {
		// 	EnchantmentItem* pEI = NULL;
		// 	dh->enchantments.GetNthItem(i, pEI);
		// 	TESFullName* pFN = DYNAMIC_CAST(pEI, EnchantmentItem, TESFullName);
		// 	_MESSAGE("DH->ench[%3u]  =  %s (0x%08X)", i, pFN ? pFN->name.data : "NO NAME", pEI->formID);
		// }


		_MESSAGE("DUMPING EQUIPPED WEAPON VALUE DATA...");

		PlayerCharacter* pPC = (*g_thePlayer);
		TESForm* equippedForm = pPC->GetEquippedObject(false); //false == right hand
		if (!equippedForm)
			return;

		//base name
		TESFullName* pFullName = DYNAMIC_CAST(equippedForm, TESForm, TESFullName);
		if (!pFullName)
			return;
		_MESSAGE("    Weapon Base Name:          %s", pFullName->name.data);

		//display name
		EquipData equipData = utilFuncs::ResolveEquippedObject(pPC, 1, 0);
		if(!(equipData.pForm && equipData.pExtraData))
			return;
		_MESSAGE("    Weapon Display Name:       %s", (utilFuncs::GetDisplayName(equipData.pForm, equipData.pExtraData)).data);

		//weapon enchantment
		TESObjectWEAP* pWeap = DYNAMIC_CAST(equippedForm, TESForm, TESObjectWEAP);
		EnchantmentItem* pEnch = pWeap->enchantable.enchantment;
		if (!pEnch)
		{
			pEnch = utilFuncs::GetExtraEnchantment(pPC, pWeap);
			if (!pEnch)
				_MESSAGE("    Enchantment Type:          NONE");
			else _MESSAGE("    Enchantment Type:          PLAYER-ENCHANTED");
		} else _MESSAGE("    Enchantment Type:          STANDARD");
		if (pEnch)
			_MESSAGE("    Enchantment Name:          %s", (DYNAMIC_CAST(pEnch, EnchantmentItem, TESFullName))->name.data);


		DumpEnchantmentValues(pEnch);
	}
}


template <typename T>
void UnpackValue(VMArray<T*>* dst, VMValue* src)
{
	UnpackArray(dst, src, GetTypeIDFromFormTypeID(T::kTypeID, (*g_skyrimVM)->GetClassRegistry()) | VMValue::kType_Identifier);
}

// template <> void UnpackValue(VMArray<TESForm*> * dst, VMValue * src)
// {
// 	UnpackArray(dst, src, GetTypeIDFromFormTypeID(TESForm::kTypeID, (*g_skyrimVM)->GetClassRegistry()) | VMValue::kType_Identifier);
// }

// template <> void UnpackValue(VMArray<EnchantmentItem*> * dst, VMValue *


// template <> void UnpackValue(VMArray<BGSKeyword*> * dst, VMValue * src)
// {
// 	UnpackArray(dst, src, GetTypeIDFromFormTypeID(BGSKeyword::kTypeID, (*g_skyrimVM)->GetClassRegistry()) | VMValue::kType_Identifier);
// }



bool RegisterPapyrusEAExtender(VMClassRegistry* registry)
{
	// Registration goes here, essentially is the same as the "RegisterFuncs" function used by ever other SKSE Papyrus class
	// See PapyrusSKSE.cpp for example, PLEASE DO NOT REGISTER CLASS FUNCTIONS, ONLY GLOBAL
	// Registering class functions causes conflict problems when you need to ship
	// the same pex files as SKSE would
	// Class functions are NOT faster than global functions, only more convenient

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
		new NativeFunction0<StaticFunctionTag, void>("DumpEnchantedWeaponValues", "EA_Extender", papyrusEAExtender::DumpEnchantedWeaponValues, registry));

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
	registry->SetFunctionFlags("EA_Extender", "DumpEnchantedWeaponValues", VMClassRegistry::kFunctionFlag_NoWait);

	registry->SetFunctionFlags("EA_Extender", "SetNthKeyword", VMClassRegistry::kFunctionFlag_NoWait);
	registry->SetFunctionFlags("EA_Extender", "SetFormArrayNthKeyword", VMClassRegistry::kFunctionFlag_NoWait);
	registry->SetFunctionFlags("EA_Extender", "SetFormArrayNthKeywordArray", VMClassRegistry::kFunctionFlag_NoWait);

	return true;
}


extern "C"
{

bool SKSEPlugin_Query(const SKSEInterface * skse, PluginInfo * info)
{
	gLog.OpenRelative(CSIDL_MYDOCUMENTS, kLogPath);
	_MESSAGE("EA_Extender (by egocarib)\n\nEnchanting Awakened Extender Loading...");

	// populate info structure
	info->infoVersion =	PluginInfo::kInfoVersion;
	info->name =		"EA Extender";
	info->version =		1;

	// store plugin handle so we can identify ourselves later
	g_pluginHandle = skse->GetPluginHandle();

	if(skse->isEditor)
	{
		_MESSAGE("loaded in editor, marking as incompatible");

		return false;
	}
	else if(skse->runtimeVersion != RUNTIME_VERSION_1_9_32_0)
	{
		_MESSAGE("unsupported runtime version %08X", skse->runtimeVersion);

		return false;
	}

	// get the scaleform interface and query its version
	g_scaleform = (SKSEScaleformInterface *)skse->QueryInterface(kInterface_Scaleform);
	if(!g_scaleform)
	{
		_MESSAGE("couldn't get scaleform interface");

		return false;
	}

	if(g_scaleform->interfaceVersion < SKSEScaleformInterface::kInterfaceVersion)
	{
		_MESSAGE("scaleform interface too old (%d expected %d)", g_scaleform->interfaceVersion, SKSEScaleformInterface::kInterfaceVersion);

		return false;
	}

	// get the serialization interface and query its version
	g_serialization = (SKSESerializationInterface *)skse->QueryInterface(kInterface_Serialization);
	if(!g_serialization)
	{
		_MESSAGE("couldn't get serialization interface");

		return false;
	}

	if(g_serialization->version < SKSESerializationInterface::kVersion)
	{
		_MESSAGE("serialization interface too old (%d expected %d)", g_serialization->version, SKSESerializationInterface::kVersion);

		return false;
	}

	// get the papyrus interface and query its version
	g_papyrus = (SKSEPapyrusInterface *)skse->QueryInterface(kInterface_Papyrus);
	if(!g_papyrus)
	{
		_MESSAGE("couldn't get papyrus interface");

		return false;
	}

	if(g_papyrus->interfaceVersion < SKSEPapyrusInterface::kInterfaceVersion)
	{
		_MESSAGE("papyrus interface too old (%d expected %d)", g_papyrus->interfaceVersion, SKSEPapyrusInterface::kInterfaceVersion);

		return false;
	}

	// ### do not do anything else in this callback
	// ### only fill out PluginInfo and return true/false

	// supported runtime version
	return true;
}

bool SKSEPlugin_Load(const SKSEInterface * skse)
{
	_MESSAGE("Interfacing with Papyrus...");

	g_papyrus->Register(RegisterPapyrusEAExtender);

	return true;
}

};