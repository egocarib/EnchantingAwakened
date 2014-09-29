// #include "[SME Sundries]\SME_Prefix.h"
#include "[SME Sundries]\INIManager.h"
#include "skse\PapyrusArgs.h"


class EnchantingAwakenedINIManager : public SME::INI::INIManager
{
public:
	void Initialize(const char* INIPath, void* Paramenter);

	void ApplyIniMultModifiers(VMArray<float> &multsToModify);
	void GetIniPerkPowerVals(VMArray<float> &basePowers, VMArray<float> &learnPowers);
	// UInt32 ExtractFormIDFromIniString(const char* src);
	// void FillTieredEnchantmentLists();

	static const char*		Tier01EnchantmentsSectionName;
	static const char*		Tier02EnchantmentsSectionName;
	static const char*		Tier03EnchantmentsSectionName;
	static const char*		AetherCoreEnchantmentsSectionName;
	static const char*		ChaosCoreEnchantmentsSectionName;
	static const char*		CorpusCoreEnchantmentsSectionName;
	static const char*		AetherExclusiveEnchantmentsSectionName;
	static const char*		ChaosExclusiveEnchantmentsSectionName;
	static const char*		CorpusExclusiveEnchantmentsSectionName;
	static const char*		EnchantmentExclusionsSectionName;
	static const char*		ModExclusionsSectionName;

	static EnchantingAwakenedINIManager		Instance;
};


// [LearnRateMultipliers]
extern	SME::INI::INISetting	kLearnMult_AllWeapons;
extern	SME::INI::INISetting	kLearnMult_Alchemy;
extern	SME::INI::INISetting	kLearnMult_Alteration;
extern	SME::INI::INISetting	kLearnMult_Archery;
extern	SME::INI::INISetting	kLearnMult_Block;
extern	SME::INI::INISetting	kLearnMult_Carry;
extern	SME::INI::INISetting	kLearnMult_Conjuration;
extern	SME::INI::INISetting	kLearnMult_Destruction;
extern	SME::INI::INISetting	kLearnMult_HealRate;
extern	SME::INI::INISetting	kLearnMult_Health;
extern	SME::INI::INISetting	kLearnMult_HeavyArmor;
extern	SME::INI::INISetting	kLearnMult_Illusion;
extern	SME::INI::INISetting	kLearnMult_LightArmor;
extern	SME::INI::INISetting	kLearnMult_Lockpicking;
extern	SME::INI::INISetting	kLearnMult_Magicka;
extern	SME::INI::INISetting	kLearnMult_MagickaRate;
extern	SME::INI::INISetting	kLearnMult_Muffle;
extern	SME::INI::INISetting	kLearnMult_OneHanded;
extern	SME::INI::INISetting	kLearnMult_Persuasion;
extern	SME::INI::INISetting	kLearnMult_Pickpocket;
extern	SME::INI::INISetting	kLearnMult_ResistDisease;
extern	SME::INI::INISetting	kLearnMult_ResistFire;
extern	SME::INI::INISetting	kLearnMult_ResistFrost;
extern	SME::INI::INISetting	kLearnMult_ResistMagic;
extern	SME::INI::INISetting	kLearnMult_ResistPoison;
extern	SME::INI::INISetting	kLearnMult_ResistShock;
extern	SME::INI::INISetting	kLearnMult_Restoration;
extern	SME::INI::INISetting	kLearnMult_Smithing;
extern	SME::INI::INISetting	kLearnMult_Sneak;
extern	SME::INI::INISetting	kLearnMult_Speed;
extern	SME::INI::INISetting	kLearnMult_Stamina;
extern	SME::INI::INISetting	kLearnMult_StaminaRate;
extern	SME::INI::INISetting	kLearnMult_TwoHanded;
extern	SME::INI::INISetting	kLearnMult_Unarmed;
extern	SME::INI::INISetting	kLearnMult_Waterbreathing;
extern	SME::INI::INISetting	kLearnMult_UnknownEffects;

// [PerkPowerBase]
extern	SME::INI::INISetting	kBaseEnchantPower_Tier01_NoPerks;
extern	SME::INI::INISetting	kBaseEnchantPower_Tier02_NoPerks;
extern	SME::INI::INISetting	kBaseEnchantPower_Tier03_NoPerks;
extern	SME::INI::INISetting	kBaseEnchantPower_Tier01_SoulShaper01;
extern	SME::INI::INISetting	kBaseEnchantPower_Tier02_SoulShaper01;
extern	SME::INI::INISetting	kBaseEnchantPower_Tier03_SoulShaper01;
extern	SME::INI::INISetting	kBaseEnchantPower_Tier01_SoulShaper02;
extern	SME::INI::INISetting	kBaseEnchantPower_Tier02_SoulShaper02;
extern	SME::INI::INISetting	kBaseEnchantPower_Tier03_SoulShaper02;
extern	SME::INI::INISetting	kBaseEnchantPower_Tier01_SoulShaper03;
extern	SME::INI::INISetting	kBaseEnchantPower_Tier02_SoulShaper03;
extern	SME::INI::INISetting	kBaseEnchantPower_Tier03_SoulShaper03;

// [PerkPowerMaxLearnable]
extern	SME::INI::INISetting	kMaxEnchantPower_Tier01_NoPerks;
extern	SME::INI::INISetting	kMaxEnchantPower_Tier02_NoPerks;
extern	SME::INI::INISetting	kMaxEnchantPower_Tier03_NoPerks;
extern	SME::INI::INISetting	kMaxEnchantPower_Tier01_SoulShaper01;
extern	SME::INI::INISetting	kMaxEnchantPower_Tier02_SoulShaper01;
extern	SME::INI::INISetting	kMaxEnchantPower_Tier03_SoulShaper01;
extern	SME::INI::INISetting	kMaxEnchantPower_Tier01_SoulShaper02;
extern	SME::INI::INISetting	kMaxEnchantPower_Tier02_SoulShaper02;
extern	SME::INI::INISetting	kMaxEnchantPower_Tier03_SoulShaper02;
extern	SME::INI::INISetting	kMaxEnchantPower_Tier01_SoulShaper03;
extern	SME::INI::INISetting	kMaxEnchantPower_Tier02_SoulShaper03;
extern	SME::INI::INISetting	kMaxEnchantPower_Tier03_SoulShaper03;

// [GamePatches]
extern	SME::INI::INISetting	kRemoveMagicSkillAssociations;
extern	SME::INI::INISetting	kRenameForms;