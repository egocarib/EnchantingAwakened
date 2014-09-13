#include "skse/GameForms.h"
#include "skse/GameObjects.h"
#include "skse/GameExtraData.h"
#include "skse/GameData.h"
#include "skse/GameRTTI.h"
#include "skse/PapyrusNativeFunctions.h"
#include <vector>


class VMClassRegistry;
class VMValue;
struct StaticFunctionTag;


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

extern MagicSkillStrings magicSkillStrings;



bool KeyListHasMagicDisallowEnchanting(BGSKeywordForm* keywords);

bool FormHasMagicDisallowEnchanting(TESForm* form);

inline bool IsPlayerCraftedEnchantment(EnchantmentItem* enchantment);



struct FormEnchantmentPair
{
	TESForm*			form;
	EnchantmentItem*	enchantment;
	FormEnchantmentPair(TESForm* f, EnchantmentItem* e) : form(f), enchantment(e) {}
};

typedef std::vector<FormEnchantmentPair> FormEnchantmentVec;

class ExtraContainerEnchantedItemExtractor
{
private:
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






namespace papyrusEAExtender
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


}

bool RegisterPapyrusEAExtender(VMClassRegistry* registry);