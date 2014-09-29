#include "Ini.h"
#include "Events.h"
#include "DataHandler.h"
#include "ExtraEnchantmentInfo.h"
#include "EnchantingAwakenedData.h"
#include "skse/GameObjects.h"
#include "skse/GameForms.h"
#include "skse/GameData.h"
#include "skse/PapyrusPerk.h"
#include <cstdio> //sscanf
#include <utility> //pair
#include <string>


UInt32						g_EnchantingAwakenedUpperByteIndex = (0xFF << 24);
UInt32						g_DragonbornUpperByteIndex = (0xFF << 24);
EAData::EAUserExclusions	g_userExclusions;


namespace EAData
{

EAFormRetainer* EAFormRetainer::GetSingleton()
{
	static EAFormRetainer formRetainer;
	return &formRetainer;
}

EAFormRetainer::EAFormRetainer()
{
	tier01EnchantmentsList              = DYNAMIC_CAST(LookupFormByID(g_EnchantingAwakenedUpperByteIndex | 0x01A7F3), TESForm, BGSListForm);
	tier02EnchantmentsList              = DYNAMIC_CAST(LookupFormByID(g_EnchantingAwakenedUpperByteIndex | 0x01A7F4), TESForm, BGSListForm);
	tier03EnchantmentsList              = DYNAMIC_CAST(LookupFormByID(g_EnchantingAwakenedUpperByteIndex | 0x01A7F5), TESForm, BGSListForm);
	aetherCoreEnchantmentsList          = DYNAMIC_CAST(LookupFormByID(g_EnchantingAwakenedUpperByteIndex | 0x01A7F2), TESForm, BGSListForm);
	chaosCoreEnchantmentsList           = DYNAMIC_CAST(LookupFormByID(g_EnchantingAwakenedUpperByteIndex | 0x01A7F1), TESForm, BGSListForm);
	corpusCoreEnchantmentsList          = DYNAMIC_CAST(LookupFormByID(g_EnchantingAwakenedUpperByteIndex | 0x01A7F0), TESForm, BGSListForm);
	aetherExclusiveEnchantmentsList     = DYNAMIC_CAST(LookupFormByID(g_EnchantingAwakenedUpperByteIndex | 0x0249FC), TESForm, BGSListForm);
	chaosExclusiveEnchantmentsList      = DYNAMIC_CAST(LookupFormByID(g_EnchantingAwakenedUpperByteIndex | 0x0249FE), TESForm, BGSListForm);
	corpusExclusiveEnchantmentsList     = DYNAMIC_CAST(LookupFormByID(g_EnchantingAwakenedUpperByteIndex | 0x0249FD), TESForm, BGSListForm);
	fullRecognizedEnchantmentsList      = DYNAMIC_CAST(LookupFormByID(g_EnchantingAwakenedUpperByteIndex | 0x24AFA4), TESForm, BGSListForm);
	tier01EnchantmentsAllVariationsList = DYNAMIC_CAST(LookupFormByID(g_EnchantingAwakenedUpperByteIndex | 0x222719), TESForm, BGSListForm);
	tier02EnchantmentsAllVariationsList = DYNAMIC_CAST(LookupFormByID(g_EnchantingAwakenedUpperByteIndex | 0x22271A), TESForm, BGSListForm);
	tier03EnchantmentsAllVariationsList = DYNAMIC_CAST(LookupFormByID(g_EnchantingAwakenedUpperByteIndex | 0x22271B), TESForm, BGSListForm);
	customEnchantmentExclusionsList     = DYNAMIC_CAST(LookupFormByID(g_EnchantingAwakenedUpperByteIndex | 0x2551A7), TESForm, BGSListForm);

	ASSERT(	tier01EnchantmentsList
		&&	tier02EnchantmentsList
		&&	tier03EnchantmentsList
		&&	aetherCoreEnchantmentsList
		&&	chaosCoreEnchantmentsList
		&&	corpusCoreEnchantmentsList
		&&	aetherExclusiveEnchantmentsList
		&&	chaosExclusiveEnchantmentsList
		&&	corpusExclusiveEnchantmentsList
		&&	fullRecognizedEnchantmentsList
		&&	tier01EnchantmentsAllVariationsList
		&&	tier02EnchantmentsAllVariationsList
		&&	tier03EnchantmentsAllVariationsList
		&&  customEnchantmentExclusionsList);

	CALL_MEMBER_FN(tier01EnchantmentsList, RevertList)();
	CALL_MEMBER_FN(tier02EnchantmentsList, RevertList)();
	CALL_MEMBER_FN(tier03EnchantmentsList, RevertList)();
	CALL_MEMBER_FN(aetherCoreEnchantmentsList, RevertList)();
	CALL_MEMBER_FN(chaosCoreEnchantmentsList, RevertList)();
	CALL_MEMBER_FN(corpusCoreEnchantmentsList, RevertList)();
	CALL_MEMBER_FN(aetherExclusiveEnchantmentsList, RevertList)();
	CALL_MEMBER_FN(chaosExclusiveEnchantmentsList, RevertList)();
	CALL_MEMBER_FN(corpusExclusiveEnchantmentsList, RevertList)();
	CALL_MEMBER_FN(fullRecognizedEnchantmentsList, RevertList)();
	CALL_MEMBER_FN(tier01EnchantmentsAllVariationsList, RevertList)();
	CALL_MEMBER_FN(tier02EnchantmentsAllVariationsList, RevertList)();
	CALL_MEMBER_FN(tier03EnchantmentsAllVariationsList, RevertList)();
	CALL_MEMBER_FN(customEnchantmentExclusionsList, RevertList)();

	EA_EnchArmorFortifySpeedBase    = LookupFormByID(g_EnchantingAwakenedUpperByteIndex | 0x0DA16D);
	DLC2EnchWeaponChaosDamageBase   = LookupFormByID(g_DragonbornUpperByteIndex | 0x02C46E);
	dunHaltedStreamtAxeENCH         = LookupFormByID(0x105830);
	dunSilentMoonsEnchWeapon01      = LookupFormByID(0x03B0B2);
	dunVolunruudPickaxeEnch         = LookupFormByID(0x1019B0);
	EnchArmorFortifyAlchemyBase     = LookupFormByID(0x10FB70);
	EnchArmorFortifyAlterationBase  = LookupFormByID(0x10FB71);
	EnchArmorFortifyBlockBase       = LookupFormByID(0x10FB72);
	EnchArmorFortifyCarryBase       = LookupFormByID(0x10FB73);
	EnchArmorFortifyConjurationBase = LookupFormByID(0x10FB74);
	EnchArmorFortifyDestructionBase = LookupFormByID(0x10FB75);
	EnchArmorFortifyHealRateBase    = LookupFormByID(0x10FB76);
	EnchArmorFortifyHealthBase      = LookupFormByID(0x10FB77);
	EnchArmorFortifyHeavyArmorBase  = LookupFormByID(0x10FB78);
	EnchArmorFortifyIllusionBase    = LookupFormByID(0x10FB79);
	EnchArmorFortifyLightArmorBase  = LookupFormByID(0x10FB7A);
	EnchArmorFortifyLockpickingBase = LookupFormByID(0x10FB7B);
	EnchArmorFortifyMagickaBase     = LookupFormByID(0x10FB7C);
	EnchArmorFortifyMagickaRateBase = LookupFormByID(0x10FB7D);
	EnchArmorFortifyMarksmanBase    = LookupFormByID(0x10FB7E);
	EnchArmorFortifyOneHandedBase   = LookupFormByID(0x10FB7F);
	EnchArmorFortifyPickpocketBase  = LookupFormByID(0x10FB80);
	EnchArmorFortifyRestorationBase = LookupFormByID(0x10FB81);
	EnchArmorFortifySmithingBase    = LookupFormByID(0x10FB82);
	EnchArmorFortifySneakBase       = LookupFormByID(0x10FB83);
	EnchArmorFortifySpeechcraftBase = LookupFormByID(0x10FB84);
	EnchArmorFortifyStaminaBase     = LookupFormByID(0x10FB85);
	EnchArmorFortifyStaminaRateBase = LookupFormByID(0x10FB86);
	EnchArmorFortifyTwoHandedBase   = LookupFormByID(0x10FB87);
	EnchArmorFortifyUnarmedBase     = LookupFormByID(0x10FB88);
	EnchArmorMuffleBase             = LookupFormByID(0x10FB89);
	EnchArmorResistDiseaseBase      = LookupFormByID(0x10FB8A);
	EnchArmorResistFireBase         = LookupFormByID(0x10FB8B);
	EnchArmorResistFrostBase        = LookupFormByID(0x10FB8C);
	EnchArmorResistMagicBase        = LookupFormByID(0x10FB8D);
	EnchArmorResistMagic01          = LookupFormByID(0x0FC05B);
	EnchArmorResistPoisonBase       = LookupFormByID(0x10FB8E);
	EnchArmorResistShockBase        = LookupFormByID(0x10FB8F);
	EnchArmorWaterbreathingBase     = LookupFormByID(0x10FB90);
	EnchFierySouls                  = LookupFormByID(0x040003);
	EnchRobesAlterationBase         = LookupFormByID(0x10EAD1);
	EnchRobesConjurationBase        = LookupFormByID(0x10EAD2);
	EnchRobesDestructionBase        = LookupFormByID(0x10EAD3);
	EnchRobesIllusionBase           = LookupFormByID(0x10EAD4);
	EnchRobesRestorationBase        = LookupFormByID(0x10EAD5);
	EnchWeaponAbsorbHealthBase      = LookupFormByID(0x10FB91);
	EnchWeaponAbsorbMagickaBase     = LookupFormByID(0x10FB9D);
	EnchWeaponAbsorbStaminaBase     = LookupFormByID(0x10FB92);
	EnchWeaponBanishBase            = LookupFormByID(0x10FB93);
	EnchWeaponFearBase              = LookupFormByID(0x10FB94);
	EnchWeaponFireDamageBase        = LookupFormByID(0x10FB95);
	EnchWeaponFrostDamageBase       = LookupFormByID(0x10FB96);
	EnchWeaponMagickaDamageBase     = LookupFormByID(0x10FB97);
	EnchWeaponParalysisBase         = LookupFormByID(0x10FB98);
	EnchWeaponShockDamageBase       = LookupFormByID(0x10FB99);
	EnchWeaponSoulTrapBase			= LookupFormByID(0x10FB9A);
	EnchWeaponStaminaDamageBase     = LookupFormByID(0x10FB9B);
	EnchWeaponTurnUndeadBase        = LookupFormByID(0x10FB9C);

	PreSoulShaper_TierMultipliersPerk = DYNAMIC_CAST(LookupFormByID(g_EnchantingAwakenedUpperByteIndex | 0x222714), TESForm, BGSPerk);
	SoulShaper01_TierMultipliersPerk  = DYNAMIC_CAST(LookupFormByID(g_EnchantingAwakenedUpperByteIndex | 0x0BEE97), TESForm, BGSPerk);
	SoulShaper02_TierMultipliersPerk  = DYNAMIC_CAST(LookupFormByID(g_EnchantingAwakenedUpperByteIndex | 0x0C367C), TESForm, BGSPerk);
	SoulShaper03_TierMultipliersPerk  = DYNAMIC_CAST(LookupFormByID(g_EnchantingAwakenedUpperByteIndex | 0x0C367D), TESForm, BGSPerk);
}


void EAUserExclusions::UpdateWeaponExclusions()
{
	if (ExclusionsActive())
	{
		EquipData equipData = ResolveEquippedObject(*g_thePlayer, ExtraEnchantmentInfo::kSource_LeftHand);
		excludeLeftEquipped = g_userExclusions.IsExcluded(equipData.pForm);

		equipData = ResolveEquippedObject(*g_thePlayer, ExtraEnchantmentInfo::kSource_RightHand);
		excludeRightEquipped = g_userExclusions.IsExcluded(equipData.pForm);
	}
}

bool EAUserExclusions::ShouldExcludeHitEventSource(Events::TESHitEvent* evn)
{
	if (ExclusionsActive())
	{
		UInt32 source = evn->GetMagicHitSource();
		if (source == ExtraEnchantmentInfo::kSource_RightHand)
			return excludeRightEquipped;
		if (source == ExtraEnchantmentInfo::kSource_LeftHand)
			return excludeLeftEquipped;
	}
	return false;
}









UInt32 ExtractFormIDFromIniString(const char* src)
{
	std::string iniString(src);

	UInt32 marker = iniString.find_last_of('|');
	if (marker == std::string::npos)
		return 0;

	std::string modName = iniString.substr(0, marker);
	std::string formHex = iniString.substr(marker + 1);

	DataHandler* dataHandler = DataHandler::GetSingleton();
	UInt32 modIndex = (dataHandler) ? dataHandler->GetModIndex(modName.c_str()) : 0xFF;

	if (modIndex >= 0xFF) //mod not loaded
		return 0;

	UInt32 localFormID;
	if (sscanf_s(formHex.c_str(), "%x", &localFormID) == 0) //error
		return 0;

	return (localFormID) ? (modIndex << 24) | (localFormID & 0x00FFFFFF) : 0;
}


void UniqueListInsert(BGSListForm* list, TESForm* form, bool trashDay = false, BGSListForm* garbageTruck = NULL)
{
	static std::set<TESForm*> addedForms;

	if (trashDay)
	{
		if (garbageTruck)
			for (std::set<TESForm*>::iterator it = addedForms.begin(); it != addedForms.end(); it++)
				CALL_MEMBER_FN(garbageTruck, AddFormToList)(*it);

		addedForms.clear();
	}

	if (!form)
		return;

	std::pair<std::set<TESForm*>::iterator, bool> result = addedForms.insert(form);
	if (result.second != false) //New
		if (list)
			CALL_MEMBER_FN(list, AddFormToList)(form);
}


void FillFormlistFromSection(BGSListForm* list, const char* section, bool revertList = true)
{
	SME::INI::INIManagerIterator iter(&EnchantingAwakenedINIManager::Instance, true, section);

	if (revertList)
		CALL_MEMBER_FN(list, RevertList)();

	for(; iter.GetDone() == false; iter.GetNextSetting())
	{
		SME_ASSERT(iter()->GetType() == SME::INI::INISetting::kType_String);
		UInt32 formID = ExtractFormIDFromIniString(iter()->GetData().s);

		if(formID)
		{
			TESForm* form = LookupFormByID(formID);
			EnchantmentItem* e = DYNAMIC_CAST(form, TESForm, EnchantmentItem);

			if (e)
			{
				if (e->data.baseEnchantment)
					form = DYNAMIC_CAST(e->data.baseEnchantment, EnchantmentItem, TESForm);

				UniqueListInsert(list, form);
			}
		}
	}
}

void FillTieredFormlistDefaults()
{
	EAFormRetainer* EAData = EAFormRetainer::GetSingleton();

	//Exclusive defaults
	UniqueListInsert(EAData->aetherExclusiveEnchantmentsList, EAData->EnchWeaponAbsorbHealthBase);
	UniqueListInsert(EAData->aetherExclusiveEnchantmentsList, EAData->EnchArmorMuffleBase);

	UniqueListInsert(EAData->chaosExclusiveEnchantmentsList, EAData->EnchWeaponAbsorbStaminaBase);
	UniqueListInsert(EAData->chaosExclusiveEnchantmentsList, EAData->EA_EnchArmorFortifySpeedBase);

	UniqueListInsert(EAData->corpusExclusiveEnchantmentsList, EAData->EnchWeaponParalysisBase);
	UniqueListInsert(EAData->corpusExclusiveEnchantmentsList, EAData->EnchArmorWaterbreathingBase);

	//Tier 1 defaults
	UniqueListInsert(EAData->tier01EnchantmentsList, EAData->EnchArmorResistShockBase);
	UniqueListInsert(EAData->tier01EnchantmentsList, EAData->EnchWeaponShockDamageBase);
	UniqueListInsert(EAData->tier01EnchantmentsList, EAData->EnchArmorResistFireBase);
	UniqueListInsert(EAData->tier01EnchantmentsList, EAData->EnchWeaponFireDamageBase);
	UniqueListInsert(EAData->tier01EnchantmentsList, EAData->EnchArmorResistFrostBase);
	UniqueListInsert(EAData->tier01EnchantmentsList, EAData->EnchWeaponFrostDamageBase);
	UniqueListInsert(EAData->tier01EnchantmentsList, EAData->EnchWeaponSoulTrapBase);
	UniqueListInsert(EAData->tier01EnchantmentsList, EAData->EnchArmorFortifyMagickaBase);
	UniqueListInsert(EAData->tier01EnchantmentsList, EAData->EnchArmorFortifyMagickaRateBase);

	//Tier 2 defaults
	UniqueListInsert(EAData->tier02EnchantmentsList, EAData->EnchArmorResistMagicBase);
	UniqueListInsert(EAData->tier02EnchantmentsList, EAData->EnchArmorResistDiseaseBase);
	UniqueListInsert(EAData->tier02EnchantmentsList, EAData->EnchArmorResistPoisonBase);
	UniqueListInsert(EAData->tier02EnchantmentsList, EAData->EnchArmorFortifyAlchemyBase);
	UniqueListInsert(EAData->tier02EnchantmentsList, EAData->EnchArmorFortifySpeechcraftBase);
	UniqueListInsert(EAData->tier02EnchantmentsList, EAData->EnchArmorFortifyCarryBase);
	UniqueListInsert(EAData->tier02EnchantmentsList, EAData->EnchArmorFortifyLockpickingBase);
	UniqueListInsert(EAData->tier02EnchantmentsList, EAData->EnchArmorFortifyPickpocketBase);
	UniqueListInsert(EAData->tier02EnchantmentsList, EAData->EnchArmorFortifySmithingBase);
	UniqueListInsert(EAData->tier02EnchantmentsList, EAData->EnchArmorFortifySneakBase);
	UniqueListInsert(EAData->tier02EnchantmentsList, EAData->EnchArmorFortifyIllusionBase);
	UniqueListInsert(EAData->tier02EnchantmentsList, EAData->EnchArmorFortifyConjurationBase);
	UniqueListInsert(EAData->tier02EnchantmentsList, EAData->EnchArmorFortifyDestructionBase);
	UniqueListInsert(EAData->tier02EnchantmentsList, EAData->EnchArmorFortifyAlterationBase);
	UniqueListInsert(EAData->tier02EnchantmentsList, EAData->EnchArmorFortifyRestorationBase);
	UniqueListInsert(EAData->tier02EnchantmentsList, EAData->EnchArmorFortifyHealthBase);
	UniqueListInsert(EAData->tier02EnchantmentsList, EAData->EnchArmorFortifyHealRateBase);
	UniqueListInsert(EAData->tier02EnchantmentsList, EAData->EnchArmorFortifyStaminaBase);
	UniqueListInsert(EAData->tier02EnchantmentsList, EAData->EnchArmorFortifyStaminaRateBase);
	UniqueListInsert(EAData->tier02EnchantmentsList, EAData->EnchArmorFortifyMarksmanBase);
	UniqueListInsert(EAData->tier02EnchantmentsList, EAData->EnchArmorFortifyOneHandedBase);
	UniqueListInsert(EAData->tier02EnchantmentsList, EAData->EnchArmorFortifyTwoHandedBase);
	UniqueListInsert(EAData->tier02EnchantmentsList, EAData->EnchArmorFortifyHeavyArmorBase);
	UniqueListInsert(EAData->tier02EnchantmentsList, EAData->EnchArmorFortifyLightArmorBase);
	UniqueListInsert(EAData->tier02EnchantmentsList, EAData->EnchArmorFortifyBlockBase);
	UniqueListInsert(EAData->tier02EnchantmentsList, EAData->EnchArmorFortifyUnarmedBase);
	UniqueListInsert(EAData->tier02EnchantmentsList, EAData->EnchArmorResistMagic01);
	UniqueListInsert(EAData->tier02EnchantmentsList, EAData->EnchRobesAlterationBase);
	UniqueListInsert(EAData->tier02EnchantmentsList, EAData->EnchRobesConjurationBase);
	UniqueListInsert(EAData->tier02EnchantmentsList, EAData->EnchRobesDestructionBase);
	UniqueListInsert(EAData->tier02EnchantmentsList, EAData->EnchRobesIllusionBase);
	UniqueListInsert(EAData->tier02EnchantmentsList, EAData->EnchRobesRestorationBase);
 
	//Tier 3 defaults
	UniqueListInsert(EAData->tier03EnchantmentsList, EAData->EnchWeaponTurnUndeadBase);
	UniqueListInsert(EAData->tier03EnchantmentsList, EAData->EnchWeaponBanishBase);
	UniqueListInsert(EAData->tier03EnchantmentsList, EAData->EnchWeaponFearBase);
	UniqueListInsert(EAData->tier03EnchantmentsList, EAData->EnchWeaponAbsorbMagickaBase);
	UniqueListInsert(EAData->tier03EnchantmentsList, EAData->EnchWeaponStaminaDamageBase);
	UniqueListInsert(EAData->tier03EnchantmentsList, EAData->EnchWeaponMagickaDamageBase);
	UniqueListInsert(EAData->tier03EnchantmentsList, EAData->EnchFierySouls);
	UniqueListInsert(EAData->tier03EnchantmentsList, EAData->DLC2EnchWeaponChaosDamageBase);
	UniqueListInsert(EAData->tier03EnchantmentsList, EAData->dunSilentMoonsEnchWeapon01);
	UniqueListInsert(EAData->tier03EnchantmentsList, EAData->dunHaltedStreamtAxeENCH);
	UniqueListInsert(EAData->tier03EnchantmentsList, EAData->dunVolunruudPickaxeEnch);
}

void FillSchoolFormlistDefaults()
{
	EAFormRetainer* EAData = EAFormRetainer::GetSingleton();

	//Aether
	UniqueListInsert(EAData->aetherCoreEnchantmentsList, EAData->EnchWeaponAbsorbHealthBase);
	UniqueListInsert(EAData->aetherCoreEnchantmentsList, EAData->EnchWeaponAbsorbMagickaBase);
	UniqueListInsert(EAData->aetherCoreEnchantmentsList, EAData->EnchWeaponBanishBase);
	UniqueListInsert(EAData->aetherCoreEnchantmentsList, EAData->EnchWeaponShockDamageBase);
	UniqueListInsert(EAData->aetherCoreEnchantmentsList, EAData->EnchWeaponMagickaDamageBase);
	UniqueListInsert(EAData->aetherCoreEnchantmentsList, EAData->EnchArmorResistMagicBase);
	UniqueListInsert(EAData->aetherCoreEnchantmentsList, EAData->EnchArmorResistShockBase);
	UniqueListInsert(EAData->aetherCoreEnchantmentsList, EAData->EnchArmorMuffleBase);
	UniqueListInsert(EAData->aetherCoreEnchantmentsList, EAData->EnchArmorFortifySneakBase);
	UniqueListInsert(EAData->aetherCoreEnchantmentsList, EAData->EnchArmorFortifyIllusionBase);
	UniqueListInsert(EAData->aetherCoreEnchantmentsList, EAData->EnchArmorFortifyConjurationBase);
	UniqueListInsert(EAData->aetherCoreEnchantmentsList, EAData->EnchArmorFortifyMagickaBase);
	UniqueListInsert(EAData->aetherCoreEnchantmentsList, EAData->EnchArmorFortifyMagickaRateBase);
	UniqueListInsert(EAData->aetherCoreEnchantmentsList, EAData->EnchArmorFortifyMarksmanBase);
	UniqueListInsert(EAData->aetherCoreEnchantmentsList, EAData->EnchArmorFortifyLockpickingBase);
	UniqueListInsert(EAData->aetherCoreEnchantmentsList, EAData->EnchRobesConjurationBase);
	UniqueListInsert(EAData->aetherCoreEnchantmentsList, EAData->EnchRobesIllusionBase);
	UniqueListInsert(EAData->aetherCoreEnchantmentsList, EAData->EnchArmorResistMagic01);

	//Chaos
	UniqueListInsert(EAData->chaosCoreEnchantmentsList, EAData->EnchWeaponAbsorbStaminaBase);
	UniqueListInsert(EAData->chaosCoreEnchantmentsList, EAData->EnchWeaponFireDamageBase);
	UniqueListInsert(EAData->chaosCoreEnchantmentsList, EAData->EnchFierySouls);
	UniqueListInsert(EAData->chaosCoreEnchantmentsList, EAData->EnchWeaponFearBase);
	UniqueListInsert(EAData->chaosCoreEnchantmentsList, EAData->DLC2EnchWeaponChaosDamageBase);
	UniqueListInsert(EAData->chaosCoreEnchantmentsList, EAData->dunSilentMoonsEnchWeapon01);
	UniqueListInsert(EAData->chaosCoreEnchantmentsList, EAData->EnchArmorFortifyDestructionBase);
	UniqueListInsert(EAData->chaosCoreEnchantmentsList, EAData->EnchArmorFortifyOneHandedBase);
	UniqueListInsert(EAData->chaosCoreEnchantmentsList, EAData->EnchArmorFortifyTwoHandedBase);
	UniqueListInsert(EAData->chaosCoreEnchantmentsList, EAData->EnchArmorFortifyHealthBase);
	UniqueListInsert(EAData->chaosCoreEnchantmentsList, EAData->EnchArmorFortifyStaminaBase);
	UniqueListInsert(EAData->chaosCoreEnchantmentsList, EAData->EnchArmorResistFireBase);
	UniqueListInsert(EAData->chaosCoreEnchantmentsList, EAData->EnchArmorFortifyLightArmorBase);
	UniqueListInsert(EAData->chaosCoreEnchantmentsList, EAData->EnchArmorFortifyPickpocketBase);
	UniqueListInsert(EAData->chaosCoreEnchantmentsList, EAData->EnchArmorFortifySpeechcraftBase);
	UniqueListInsert(EAData->chaosCoreEnchantmentsList, EAData->EnchArmorFortifyAlchemyBase);
	UniqueListInsert(EAData->chaosCoreEnchantmentsList, EAData->EnchArmorFortifyUnarmedBase);
	UniqueListInsert(EAData->chaosCoreEnchantmentsList, EAData->EnchRobesDestructionBase);
	UniqueListInsert(EAData->chaosCoreEnchantmentsList, EAData->EA_EnchArmorFortifySpeedBase);

	//Corpus
	UniqueListInsert(EAData->corpusCoreEnchantmentsList, EAData->EnchWeaponParalysisBase);
	UniqueListInsert(EAData->corpusCoreEnchantmentsList, EAData->EnchWeaponTurnUndeadBase);
	UniqueListInsert(EAData->corpusCoreEnchantmentsList, EAData->EnchWeaponFrostDamageBase);
	UniqueListInsert(EAData->corpusCoreEnchantmentsList, EAData->EnchWeaponStaminaDamageBase);
	UniqueListInsert(EAData->corpusCoreEnchantmentsList, EAData->dunHaltedStreamtAxeENCH);
	UniqueListInsert(EAData->corpusCoreEnchantmentsList, EAData->dunVolunruudPickaxeEnch);
	UniqueListInsert(EAData->corpusCoreEnchantmentsList, EAData->EnchArmorFortifyRestorationBase);
	UniqueListInsert(EAData->corpusCoreEnchantmentsList, EAData->EnchArmorFortifyAlterationBase);
	UniqueListInsert(EAData->corpusCoreEnchantmentsList, EAData->EnchArmorResistFrostBase);
	UniqueListInsert(EAData->corpusCoreEnchantmentsList, EAData->EnchArmorResistPoisonBase);
	UniqueListInsert(EAData->corpusCoreEnchantmentsList, EAData->EnchArmorResistDiseaseBase);
	UniqueListInsert(EAData->corpusCoreEnchantmentsList, EAData->EnchArmorFortifyHealRateBase);
	UniqueListInsert(EAData->corpusCoreEnchantmentsList, EAData->EnchArmorFortifyStaminaRateBase);
	UniqueListInsert(EAData->corpusCoreEnchantmentsList, EAData->EnchArmorFortifyBlockBase);
	UniqueListInsert(EAData->corpusCoreEnchantmentsList, EAData->EnchArmorFortifyHeavyArmorBase);
	UniqueListInsert(EAData->corpusCoreEnchantmentsList, EAData->EnchArmorFortifySmithingBase);
	UniqueListInsert(EAData->corpusCoreEnchantmentsList, EAData->EnchArmorFortifyCarryBase);
	UniqueListInsert(EAData->corpusCoreEnchantmentsList, EAData->EnchArmorWaterbreathingBase);
	UniqueListInsert(EAData->corpusCoreEnchantmentsList, EAData->EnchRobesAlterationBase);
	UniqueListInsert(EAData->corpusCoreEnchantmentsList, EAData->EnchRobesRestorationBase);
}



void FillListWithAllVariationsOfBaseEnchantments(BGSListForm* totalList, BGSListForm* baseEnchantments)
{
	DerivedEnchantmentListProcessor children(totalList);
	baseEnchantments->Visit(children);
}



void InitializeFormlists()
{
	EAFormRetainer* EAData = EAFormRetainer::GetSingleton();
	const bool RESET_UNIQUENESS_TRACKER = true;

	//Fill formlists with user overrides or custom additions, and then with defaults afterward. The order here is important.
	UniqueListInsert(EAData->tier01EnchantmentsList, EAData->EnchWeaponSoulTrapBase); //This always belongs in this list
	FillFormlistFromSection(EAData->aetherExclusiveEnchantmentsList, EnchantingAwakenedINIManager::AetherExclusiveEnchantmentsSectionName);
	FillFormlistFromSection(EAData->chaosExclusiveEnchantmentsList, EnchantingAwakenedINIManager::ChaosExclusiveEnchantmentsSectionName);
	FillFormlistFromSection(EAData->corpusExclusiveEnchantmentsList, EnchantingAwakenedINIManager::CorpusExclusiveEnchantmentsSectionName);
	FillFormlistFromSection(EAData->tier01EnchantmentsList, EnchantingAwakenedINIManager::Tier01EnchantmentsSectionName, false);
	FillFormlistFromSection(EAData->tier02EnchantmentsList, EnchantingAwakenedINIManager::Tier02EnchantmentsSectionName);
	FillFormlistFromSection(EAData->tier03EnchantmentsList, EnchantingAwakenedINIManager::Tier03EnchantmentsSectionName);

	FillTieredFormlistDefaults();

	FillListWithAllVariationsOfBaseEnchantments(EAData->tier01EnchantmentsAllVariationsList, EAData->tier01EnchantmentsList);
	FillListWithAllVariationsOfBaseEnchantments(EAData->tier02EnchantmentsAllVariationsList, EAData->tier02EnchantmentsList);
	FillListWithAllVariationsOfBaseEnchantments(EAData->tier03EnchantmentsAllVariationsList, EAData->tier03EnchantmentsList);
	FillListWithAllVariationsOfBaseEnchantments(EAData->tier03EnchantmentsAllVariationsList, EAData->aetherExclusiveEnchantmentsList);
	FillListWithAllVariationsOfBaseEnchantments(EAData->tier03EnchantmentsAllVariationsList, EAData->chaosExclusiveEnchantmentsList);
	FillListWithAllVariationsOfBaseEnchantments(EAData->tier03EnchantmentsAllVariationsList, EAData->corpusExclusiveEnchantmentsList);
	

	//Dump all forms added so far into fullRecognizedEnchantmentsList, and then reset the unique form tracker to allow reuse of forms in lists below
	UniqueListInsert(NULL, NULL, RESET_UNIQUENESS_TRACKER, EAData->fullRecognizedEnchantmentsList);
	
	UniqueListInsert(NULL, EAData->EnchWeaponSoulTrapBase); //Prevent this from getting into any of the following lists
	FillFormlistFromSection(EAData->aetherCoreEnchantmentsList, EnchantingAwakenedINIManager::AetherExclusiveEnchantmentsSectionName);
	FillFormlistFromSection(EAData->chaosCoreEnchantmentsList, EnchantingAwakenedINIManager::ChaosExclusiveEnchantmentsSectionName);
	FillFormlistFromSection(EAData->corpusCoreEnchantmentsList, EnchantingAwakenedINIManager::CorpusExclusiveEnchantmentsSectionName);
	FillFormlistFromSection(EAData->aetherCoreEnchantmentsList, EnchantingAwakenedINIManager::AetherCoreEnchantmentsSectionName, false);
	FillFormlistFromSection(EAData->chaosCoreEnchantmentsList, EnchantingAwakenedINIManager::ChaosCoreEnchantmentsSectionName, false);
	FillFormlistFromSection(EAData->corpusCoreEnchantmentsList, EnchantingAwakenedINIManager::CorpusCoreEnchantmentsSectionName, false);

	FillSchoolFormlistDefaults();

	UniqueListInsert(NULL, NULL, RESET_UNIQUENESS_TRACKER); //Clear data

	//DEBUG OUTPUT
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	//DEBUG ONLY
				// struct ListProcessor : public BGSListForm::Visitor
				// {
				// 	virtual bool Accept(TESForm * form)
				// 	{
				// 		if (form)
				// 			_MESSAGE("%s [%08X]", (DYNAMIC_CAST(form, TESForm, TESFullName))->name.data, form->formID);
				// 		return false;
				// 	};
				// } listDumper;

				// _MESSAGE("\n\n\nDumping Tier01EnchantmentsList:");		gLog.Indent();
				// EAData->tier01EnchantmentsList->Visit(listDumper);		gLog.Outdent();
				// _MESSAGE("\nDumping Tier02EnchantmentsList:");		gLog.Indent();
				// EAData->tier02EnchantmentsList->Visit(listDumper);		gLog.Outdent();
				// _MESSAGE("\nDumping Tier03EnchantmentsList:");		gLog.Indent();
				// EAData->tier03EnchantmentsList->Visit(listDumper);		gLog.Outdent();
				// _MESSAGE("\nDumping AetherCoreEnchantmentsList:");		gLog.Indent();
				// EAData->aetherCoreEnchantmentsList->Visit(listDumper);		gLog.Outdent();
				// _MESSAGE("\nDumping ChaosCoreEnchantmentsList:");		gLog.Indent();
				// EAData->chaosCoreEnchantmentsList->Visit(listDumper);		gLog.Outdent();
				// _MESSAGE("\nDumping CorpusCoreEnchantmentsList:");		gLog.Indent();
				// EAData->corpusCoreEnchantmentsList->Visit(listDumper);		gLog.Outdent();
				// _MESSAGE("\nDumping AetherExclusiveEnchantmentsList:");		gLog.Indent();
				// EAData->aetherExclusiveEnchantmentsList->Visit(listDumper);		gLog.Outdent();
				// _MESSAGE("\nDumping ChaosExclusiveEnchantmentsList:");		gLog.Indent();
				// EAData->chaosExclusiveEnchantmentsList->Visit(listDumper);		gLog.Outdent();
				// _MESSAGE("\nDumping CorpusExclusiveEnchantmentsList:");		gLog.Indent();
				// EAData->corpusExclusiveEnchantmentsList->Visit(listDumper);		gLog.Outdent();
				// _MESSAGE("\nDumping FullRecognizedEnchantmentsList:");		gLog.Indent();
				// EAData->fullRecognizedEnchantmentsList->Visit(listDumper);		gLog.Outdent();
	//DEBUG OUTPUT
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
}




UInt32 GetPerkEntryIndexByPriority(BGSPerk* perk, UInt32 targetPriority)
{
	//Priority of entry correlates to the Tier of enchantments it affects
	UInt32 count = papyrusPerk::GetNumEntries(perk);
	for (UInt32 n = 0; n < count; n++)
		if (papyrusPerk::GetNthEntryPriority(perk, n) == targetPriority)
			return n;
	return 0xFFFFFFFF;
}


void SetPerkMultipliers()
{
	EAFormRetainer* EAData = EAFormRetainer::GetSingleton();

	BGSPerk* perk;

	perk = EAData->PreSoulShaper_TierMultipliersPerk;
	papyrusPerk::SetNthEntryValue(perk, GetPerkEntryIndexByPriority(perk, 1), 0, kBaseEnchantPower_Tier01_NoPerks.GetData().f / 20.0);
	papyrusPerk::SetNthEntryValue(perk, GetPerkEntryIndexByPriority(perk, 2), 0, kBaseEnchantPower_Tier02_NoPerks.GetData().f / 20.0);
	papyrusPerk::SetNthEntryValue(perk, GetPerkEntryIndexByPriority(perk, 3), 0, kBaseEnchantPower_Tier03_NoPerks.GetData().f / 20.0);

	perk = EAData->SoulShaper01_TierMultipliersPerk;
	papyrusPerk::SetNthEntryValue(perk, GetPerkEntryIndexByPriority(perk, 1), 0, kBaseEnchantPower_Tier01_SoulShaper01.GetData().f / 20.0);
	papyrusPerk::SetNthEntryValue(perk, GetPerkEntryIndexByPriority(perk, 2), 0, kBaseEnchantPower_Tier02_SoulShaper01.GetData().f / 20.0);
	papyrusPerk::SetNthEntryValue(perk, GetPerkEntryIndexByPriority(perk, 3), 0, kBaseEnchantPower_Tier03_SoulShaper01.GetData().f / 20.0);

	perk = EAData->SoulShaper02_TierMultipliersPerk;
	papyrusPerk::SetNthEntryValue(perk, GetPerkEntryIndexByPriority(perk, 1), 0, kBaseEnchantPower_Tier01_SoulShaper02.GetData().f / 20.0);
	papyrusPerk::SetNthEntryValue(perk, GetPerkEntryIndexByPriority(perk, 2), 0, kBaseEnchantPower_Tier02_SoulShaper02.GetData().f / 20.0);
	papyrusPerk::SetNthEntryValue(perk, GetPerkEntryIndexByPriority(perk, 3), 0, kBaseEnchantPower_Tier03_SoulShaper02.GetData().f / 20.0);

	perk = EAData->SoulShaper03_TierMultipliersPerk;
	papyrusPerk::SetNthEntryValue(perk, GetPerkEntryIndexByPriority(perk, 1), 0, kBaseEnchantPower_Tier01_SoulShaper03.GetData().f / 20.0);
	papyrusPerk::SetNthEntryValue(perk, GetPerkEntryIndexByPriority(perk, 2), 0, kBaseEnchantPower_Tier02_SoulShaper03.GetData().f / 20.0);
	papyrusPerk::SetNthEntryValue(perk, GetPerkEntryIndexByPriority(perk, 3), 0, kBaseEnchantPower_Tier03_SoulShaper03.GetData().f / 20.0);
}

void RecordCustomExclusions()
{
	EAFormRetainer* EAData = EAFormRetainer::GetSingleton();

	//Fill customEnchantmentExclusionsList with base enchantments from INI. This list is used by perks to handle exclusions
	FillFormlistFromSection(EAData->customEnchantmentExclusionsList, EnchantingAwakenedINIManager::EnchantmentExclusionsSectionName);


	//Record these base enchantment exclusions into g_userExclusions to prevent learn events from occuring for them
	struct ExclusionListProcessor : public BGSListForm::Visitor
	{
		virtual bool Accept(TESForm* form)
		{
			if (form)
				g_userExclusions.AddExclusion(form);
			return false;
		};
	} exclusionRecorder;
	EAData->customEnchantmentExclusionsList->Visit(exclusionRecorder);


	//Next, expand customEnchantmentExclusionsList to also include all the child enchantments from those bases
	struct ChildEnchantmentProcessor
	{
		bool Accept(TESForm* form)
		{
			EnchantmentItem* e = DYNAMIC_CAST(form, TESForm, EnchantmentItem);
			if (e)
				BaseEnchantmentUseResearcher::GetSingleton()->AddChildrenToList(e, EAFormRetainer::GetSingleton()->customEnchantmentExclusionsList);
			return true;
		}
	} kidnapper;
	g_userExclusions.VisitForms(&kidnapper);


	//Now process complete mod exclusions
	std::set<UInt32> excludedModUpperByteIndices;

	SME::INI::INIManagerIterator iter(&EnchantingAwakenedINIManager::Instance, true, EnchantingAwakenedINIManager::ModExclusionsSectionName);

		//Record each excluded mod's index and add it to g_userExclusions
		for(; iter.GetDone() == false; iter.GetNextSetting())
		{
			SME_ASSERT(iter()->GetType() == SME::INI::INISetting::kType_String);

			DataHandler* dataHandler = DataHandler::GetSingleton();
			UInt32 modIndex = (dataHandler) ? dataHandler->GetModIndex(iter()->GetData().s) : 0xFF;

			if (modIndex > 0 && modIndex < 0xFF)
			{
				g_userExclusions.AddExclusion((UInt8)modIndex); //Add mod index as a global exclusion
				modIndex <<= 24;
				excludedModUpperByteIndices.insert(modIndex);
			}
		}

		//Add all enchantments originating from excluded mods to customEnchantmentExclusionList
		if (!excludedModUpperByteIndices.empty())
		{
			struct ModBaseEnchantmentProcessor
			{
			private:
				std::set<UInt32>* _excludedModUpperByteIndices;

			public:
				ModBaseEnchantmentProcessor(std::set<UInt32>* arg) : _excludedModUpperByteIndices(arg) {}

				bool Accept(EnchantmentItem* e)
				{
					UInt32 modIndex = e->formID && (0xFF << 24);
					if (_excludedModUpperByteIndices->find(modIndex) != _excludedModUpperByteIndices->end())
						UniqueListInsert(EAFormRetainer::GetSingleton()->customEnchantmentExclusionsList, static_cast<TESForm*>(e));
					return true;
				}
			};
			ModBaseEnchantmentProcessor modEnchantCatcher(&excludedModUpperByteIndices);
			EnchantmentDataHandler::Visit(&modEnchantCatcher);
		}

	//Clear uniqueness tracker
	UniqueListInsert(NULL, NULL, true);

	g_userExclusions.UpdateWeaponExclusions();
}


};