#pragma once
#include "skse/GameRTTI.h"
#include <set>

class		TESForm;
class		BGSPerk;
class		BGSListForm;
class		EnchantmentItem;
namespace 	Events { struct TESHitEvent; };

namespace EAData
{
	class EAUserExclusions;
};


extern	UInt32						g_EnchantingAwakenedUpperByteIndex;
extern	UInt32						g_DragonbornUpperByteIndex;
extern	EAData::EAUserExclusions	g_userExclusions;


namespace EAData
{

void InitializeFormlists();
void SetPerkMultipliers();
void RecordCustomExclusions();

class EAFormRetainer
{
private:
	EAFormRetainer();

public:
	static EAFormRetainer* GetSingleton();

	//EA Lists
	BGSListForm* tier01EnchantmentsList;
	BGSListForm* tier02EnchantmentsList;
	BGSListForm* tier03EnchantmentsList;
	BGSListForm* aetherCoreEnchantmentsList;
	BGSListForm* chaosCoreEnchantmentsList;
	BGSListForm* corpusCoreEnchantmentsList;
	BGSListForm* aetherExclusiveEnchantmentsList;
	BGSListForm* chaosExclusiveEnchantmentsList;
	BGSListForm* corpusExclusiveEnchantmentsList;
	BGSListForm* fullRecognizedEnchantmentsList;
	BGSListForm* tier01EnchantmentsAllVariationsList;
	BGSListForm* tier02EnchantmentsAllVariationsList;
	BGSListForm* tier03EnchantmentsAllVariationsList;
	BGSListForm* customEnchantmentExclusionsList;

	//Base Enchantments
	TESForm* EA_EnchArmorFortifySpeedBase;
	TESForm* DLC2EnchWeaponChaosDamageBase;
	TESForm* dunHaltedStreamtAxeENCH;
	TESForm* dunSilentMoonsEnchWeapon01;
	TESForm* dunVolunruudPickaxeEnch;
	TESForm* EnchArmorFortifyAlchemyBase;
	TESForm* EnchArmorFortifyAlterationBase;
	TESForm* EnchArmorFortifyBlockBase;
	TESForm* EnchArmorFortifyCarryBase;
	TESForm* EnchArmorFortifyConjurationBase;
	TESForm* EnchArmorFortifyDestructionBase;
	TESForm* EnchArmorFortifyHealRateBase;
	TESForm* EnchArmorFortifyHealthBase;
	TESForm* EnchArmorFortifyHeavyArmorBase;
	TESForm* EnchArmorFortifyIllusionBase;
	TESForm* EnchArmorFortifyLightArmorBase;
	TESForm* EnchArmorFortifyLockpickingBase;
	TESForm* EnchArmorFortifyMagickaBase;
	TESForm* EnchArmorFortifyMagickaRateBase;
	TESForm* EnchArmorFortifyMarksmanBase;
	TESForm* EnchArmorFortifyOneHandedBase;
	TESForm* EnchArmorFortifyPickpocketBase;
	TESForm* EnchArmorFortifyRestorationBase;
	TESForm* EnchArmorFortifySmithingBase;
	TESForm* EnchArmorFortifySneakBase;
	TESForm* EnchArmorFortifySpeechcraftBase;
	TESForm* EnchArmorFortifyStaminaBase;
	TESForm* EnchArmorFortifyStaminaRateBase;
	TESForm* EnchArmorFortifyTwoHandedBase;
	TESForm* EnchArmorFortifyUnarmedBase;
	TESForm* EnchArmorMuffleBase;
	TESForm* EnchArmorResistDiseaseBase;
	TESForm* EnchArmorResistFireBase;
	TESForm* EnchArmorResistFrostBase;
	TESForm* EnchArmorResistMagic01;
	TESForm* EnchArmorResistMagicBase;
	TESForm* EnchArmorResistPoisonBase;
	TESForm* EnchArmorResistShockBase;
	TESForm* EnchArmorWaterbreathingBase;
	TESForm* EnchFierySouls;
	TESForm* EnchRobesAlterationBase;
	TESForm* EnchRobesConjurationBase;
	TESForm* EnchRobesDestructionBase;
	TESForm* EnchRobesIllusionBase;
	TESForm* EnchRobesRestorationBase;
	TESForm* EnchWeaponAbsorbHealthBase;
	TESForm* EnchWeaponAbsorbMagickaBase;
	TESForm* EnchWeaponAbsorbStaminaBase;
	TESForm* EnchWeaponBanishBase;
	TESForm* EnchWeaponFearBase;
	TESForm* EnchWeaponFireDamageBase;
	TESForm* EnchWeaponFrostDamageBase;
	TESForm* EnchWeaponMagickaDamageBase;
	TESForm* EnchWeaponParalysisBase;
	TESForm* EnchWeaponShockDamageBase;
	TESForm* EnchWeaponSoulTrapBase;
	TESForm* EnchWeaponStaminaDamageBase;
	TESForm* EnchWeaponTurnUndeadBase;

	//EA Perks
	BGSPerk* PreSoulShaper_TierMultipliersPerk;
	BGSPerk* SoulShaper01_TierMultipliersPerk;
	BGSPerk* SoulShaper02_TierMultipliersPerk;
	BGSPerk* SoulShaper03_TierMultipliersPerk;
};


class EAUserExclusions
{
private:
	std::set<TESForm*>	excludedForms;
	std::set<UInt8>		excludedModIndices;
	bool				excludeRightEquipped;
	bool				excludeLeftEquipped;

	bool ExclusionsActive()
	{
		static bool exclusionsActive = (!excludedForms.empty() || !excludedModIndices.empty());
		return exclusionsActive;
	}

public:
	EAUserExclusions()
		: excludedForms()
		, excludedModIndices()
		, excludeRightEquipped(false)
		, excludeLeftEquipped(false) {}

	template <class Visitor>
	void VisitForms(Visitor* visitor)
	{
		bool bContinue = true;
		for (std::set<TESForm*>::iterator it = excludedForms.begin(); it != excludedForms.end() && bContinue; it++)
			bContinue = visitor->Accept(*it);
	}

	bool IsExcluded(TESForm* form)
	{
		if (ExclusionsActive())
		{
			if (form)
			{
				if (excludedForms.find(form) != excludedForms.end())
					return true;
				
				UInt8 modIndex = (UInt8)(form->formID >> 24);
				if (excludedModIndices.find(modIndex) != excludedModIndices.end())
					return true;
			}
		}
		return false;
	}

	bool IsExcluded(EnchantmentItem* enchantment)
	{
		if (ExclusionsActive())
			return IsExcluded(DYNAMIC_CAST(enchantment, EnchantmentItem, TESForm));
		
		return false;
	}

	void AddExclusion(TESForm* form)	{ excludedForms.insert(form); }
	void AddExclusion(UInt8 modIndex)	{ excludedModIndices.insert(modIndex); }

	void UpdateWeaponExclusions();
	bool ShouldExcludeHitEventSource(Events::TESHitEvent* evn);
};

};