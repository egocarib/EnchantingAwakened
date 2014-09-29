#include "Ini.h"

using namespace SME::INI;

EnchantingAwakenedINIManager		EnchantingAwakenedINIManager::Instance;

const char*	EnchantingAwakenedINIManager::Tier01EnchantmentsSectionName          = "Tier01Enchantments";
const char*	EnchantingAwakenedINIManager::Tier02EnchantmentsSectionName          = "Tier02Enchantments";
const char*	EnchantingAwakenedINIManager::Tier03EnchantmentsSectionName          = "Tier03Enchantments";
const char*	EnchantingAwakenedINIManager::AetherCoreEnchantmentsSectionName      = "AetherCoreEnchantments";
const char*	EnchantingAwakenedINIManager::ChaosCoreEnchantmentsSectionName       = "ChaosCoreEnchantments";
const char*	EnchantingAwakenedINIManager::CorpusCoreEnchantmentsSectionName      = "CorpusCoreEnchantments";
const char*	EnchantingAwakenedINIManager::AetherExclusiveEnchantmentsSectionName = "AetherExclusiveEnchantments";
const char*	EnchantingAwakenedINIManager::ChaosExclusiveEnchantmentsSectionName  = "ChaosExclusiveEnchantments";
const char*	EnchantingAwakenedINIManager::CorpusExclusiveEnchantmentsSectionName = "CorpusExclusiveEnchantments";
const char* EnchantingAwakenedINIManager::EnchantmentExclusionsSectionName       = "EnchantmentExclusions";
const char* EnchantingAwakenedINIManager::ModExclusionsSectionName               = "ModExclusions";

// [LearnRateMultipliers]
INISetting kLearnMult_AllWeapons	("LearnMult_AllWeaponEnchantments", "LearnRateMultipliers", "Weapon Enchantment Learn Mult",          (float)1.0);
INISetting kLearnMult_Alchemy		("LearnMult_Alchemy",               "LearnRateMultipliers", "Alchemy Enchantment Learn Mult",         (float)1.0);
INISetting kLearnMult_Alteration	("LearnMult_Alteration",            "LearnRateMultipliers", "Alteration Enchantment Learn Mult",      (float)1.0);
INISetting kLearnMult_Archery		("LearnMult_Archery",               "LearnRateMultipliers", "Archery Enchantment Learn Mult",         (float)1.0);
INISetting kLearnMult_Block			("LearnMult_Block",                 "LearnRateMultipliers", "Block Enchantment Learn Mult",           (float)1.0);
INISetting kLearnMult_Carry			("LearnMult_Carry",                 "LearnRateMultipliers", "Carry Enchantment Learn Mult",           (float)1.0);
INISetting kLearnMult_Conjuration	("LearnMult_Conjuration",           "LearnRateMultipliers", "Conjuration Enchantment Learn Mult",     (float)1.0);
INISetting kLearnMult_Destruction	("LearnMult_Destruction",           "LearnRateMultipliers", "Destruction Enchantment Learn Mult",     (float)1.0);
INISetting kLearnMult_HealRate		("LearnMult_HealRate",              "LearnRateMultipliers", "HealRate Enchantment Learn Mult",        (float)1.0);
INISetting kLearnMult_Health		("LearnMult_Health",                "LearnRateMultipliers", "Health Enchantment Learn Mult",          (float)1.0);
INISetting kLearnMult_HeavyArmor	("LearnMult_HeavyArmor",            "LearnRateMultipliers", "HeavyArmor Enchantment Learn Mult",      (float)1.0);
INISetting kLearnMult_Illusion		("LearnMult_Illusion",              "LearnRateMultipliers", "Illusion Enchantment Learn Mult",        (float)1.0);
INISetting kLearnMult_LightArmor	("LearnMult_LightArmor",            "LearnRateMultipliers", "LightArmor Enchantment Learn Mult",      (float)1.0);
INISetting kLearnMult_Lockpicking	("LearnMult_Lockpicking",           "LearnRateMultipliers", "Lockpicking Enchantment Learn Mult",     (float)1.0);
INISetting kLearnMult_Magicka		("LearnMult_Magicka",               "LearnRateMultipliers", "Magicka Enchantment Learn Mult",         (float)1.0);
INISetting kLearnMult_MagickaRate	("LearnMult_MagickaRate",           "LearnRateMultipliers", "MagickaRate Enchantment Learn Mult",     (float)1.0);
INISetting kLearnMult_Muffle		("LearnMult_Muffle",                "LearnRateMultipliers", "Muffle Enchantment Learn Mult",          (float)1.0);
INISetting kLearnMult_OneHanded		("LearnMult_OneHanded",             "LearnRateMultipliers", "OneHanded Enchantment Learn Mult",       (float)1.0);
INISetting kLearnMult_Persuasion	("LearnMult_Persuasion",            "LearnRateMultipliers", "Persuasion Enchantment Learn Mult",      (float)1.0);
INISetting kLearnMult_Pickpocket	("LearnMult_Pickpocket",            "LearnRateMultipliers", "Pickpocket Enchantment Learn Mult",      (float)1.0);
INISetting kLearnMult_ResistDisease	("LearnMult_ResistDisease",         "LearnRateMultipliers", "ResistDisease Enchantment Learn Mult",   (float)1.0);
INISetting kLearnMult_ResistFire	("LearnMult_ResistFire",            "LearnRateMultipliers", "ResistFire Enchantment Learn Mult",      (float)1.0);
INISetting kLearnMult_ResistFrost	("LearnMult_ResistFrost",           "LearnRateMultipliers", "ResistFrost Enchantment Learn Mult",     (float)1.0);
INISetting kLearnMult_ResistMagic	("LearnMult_ResistMagic",           "LearnRateMultipliers", "ResistMagic Enchantment Learn Mult",     (float)1.0);
INISetting kLearnMult_ResistPoison	("LearnMult_ResistPoison",          "LearnRateMultipliers", "ResistPoison Enchantment Learn Mult",    (float)1.0);
INISetting kLearnMult_ResistShock	("LearnMult_ResistShock",           "LearnRateMultipliers", "ResistShock Enchantment Learn Mult",     (float)1.0);
INISetting kLearnMult_Restoration	("LearnMult_Restoration",           "LearnRateMultipliers", "Restoration Enchantment Learn Mult",     (float)1.0);
INISetting kLearnMult_Smithing		("LearnMult_Smithing",              "LearnRateMultipliers", "Smithing Enchantment Learn Mult",        (float)1.0);
INISetting kLearnMult_Sneak			("LearnMult_Sneak",                 "LearnRateMultipliers", "Sneak Enchantment Learn Mult",           (float)1.0);
INISetting kLearnMult_Speed			("LearnMult_Speed",                 "LearnRateMultipliers", "Speed Enchantment Learn Mult",           (float)1.0);
INISetting kLearnMult_Stamina		("LearnMult_Stamina",               "LearnRateMultipliers", "Stamina Enchantment Learn Mult",         (float)1.0);
INISetting kLearnMult_StaminaRate	("LearnMult_StaminaRate",           "LearnRateMultipliers", "StaminaRate Enchantment Learn Mult",     (float)1.0);
INISetting kLearnMult_TwoHanded		("LearnMult_TwoHanded",             "LearnRateMultipliers", "TwoHanded Enchantment Learn Mult",       (float)1.0);
INISetting kLearnMult_Unarmed		("LearnMult_Unarmed",               "LearnRateMultipliers", "Unarmed Enchantment Learn Mult",         (float)1.0);
INISetting kLearnMult_Waterbreathing("LearnMult_Waterbreathing",        "LearnRateMultipliers", "Waterbreathing Enchantment Learn Mult",  (float)1.0);
INISetting kLearnMult_UnknownEffects("LearnMult_UnknownEffects",        "LearnRateMultipliers", "Unknown Effects Enchantment Learn Mult", (float)1.0);

// [PerkPowerBase]
INISetting kBaseEnchantPower_Tier01_NoPerks			("BaseEnchantPower_Tier01_NoPerks",      "PerkPowerBase", "", (float)0.20);
INISetting kBaseEnchantPower_Tier01_SoulShaper01	("BaseEnchantPower_Tier01_SoulShaper01", "PerkPowerBase", "", (float)0.70);
INISetting kBaseEnchantPower_Tier01_SoulShaper02	("BaseEnchantPower_Tier01_SoulShaper02", "PerkPowerBase", "", (float)1.00);
INISetting kBaseEnchantPower_Tier01_SoulShaper03	("BaseEnchantPower_Tier01_SoulShaper03", "PerkPowerBase", "", (float)1.00);
INISetting kBaseEnchantPower_Tier02_NoPerks			("BaseEnchantPower_Tier02_NoPerks",      "PerkPowerBase", "", (float)0.20);
INISetting kBaseEnchantPower_Tier02_SoulShaper01	("BaseEnchantPower_Tier02_SoulShaper01", "PerkPowerBase", "", (float)0.50);
INISetting kBaseEnchantPower_Tier02_SoulShaper02	("BaseEnchantPower_Tier02_SoulShaper02", "PerkPowerBase", "", (float)0.80);
INISetting kBaseEnchantPower_Tier02_SoulShaper03	("BaseEnchantPower_Tier02_SoulShaper03", "PerkPowerBase", "", (float)1.00);
INISetting kBaseEnchantPower_Tier03_NoPerks			("BaseEnchantPower_Tier03_NoPerks",      "PerkPowerBase", "", (float)0.20);
INISetting kBaseEnchantPower_Tier03_SoulShaper01	("BaseEnchantPower_Tier03_SoulShaper01", "PerkPowerBase", "", (float)0.40);
INISetting kBaseEnchantPower_Tier03_SoulShaper02	("BaseEnchantPower_Tier03_SoulShaper02", "PerkPowerBase", "", (float)0.60);
INISetting kBaseEnchantPower_Tier03_SoulShaper03	("BaseEnchantPower_Tier03_SoulShaper03", "PerkPowerBase", "", (float)0.80);

// [PerkPowerMaxLearnable]
INISetting kMaxEnchantPower_Tier01_NoPerks			("MaxEnchantPower_Tier01_NoPerks",      "PerkPowerMaxLearnable", "", (float)1.00);
INISetting kMaxEnchantPower_Tier01_SoulShaper01		("MaxEnchantPower_Tier01_SoulShaper01", "PerkPowerMaxLearnable", "", (float)1.20);
INISetting kMaxEnchantPower_Tier01_SoulShaper02		("MaxEnchantPower_Tier01_SoulShaper02", "PerkPowerMaxLearnable", "", (float)1.40);
INISetting kMaxEnchantPower_Tier01_SoulShaper03		("MaxEnchantPower_Tier01_SoulShaper03", "PerkPowerMaxLearnable", "", (float)1.60);
INISetting kMaxEnchantPower_Tier02_NoPerks			("MaxEnchantPower_Tier02_NoPerks",      "PerkPowerMaxLearnable", "", (float)1.00);
INISetting kMaxEnchantPower_Tier02_SoulShaper01		("MaxEnchantPower_Tier02_SoulShaper01", "PerkPowerMaxLearnable", "", (float)1.15);
INISetting kMaxEnchantPower_Tier02_SoulShaper02		("MaxEnchantPower_Tier02_SoulShaper02", "PerkPowerMaxLearnable", "", (float)1.30);
INISetting kMaxEnchantPower_Tier02_SoulShaper03		("MaxEnchantPower_Tier02_SoulShaper03", "PerkPowerMaxLearnable", "", (float)1.50);
INISetting kMaxEnchantPower_Tier03_NoPerks			("MaxEnchantPower_Tier03_NoPerks",      "PerkPowerMaxLearnable", "", (float)1.00);
INISetting kMaxEnchantPower_Tier03_SoulShaper01		("MaxEnchantPower_Tier03_SoulShaper01", "PerkPowerMaxLearnable", "", (float)1.10);
INISetting kMaxEnchantPower_Tier03_SoulShaper02		("MaxEnchantPower_Tier03_SoulShaper02", "PerkPowerMaxLearnable", "", (float)1.20);
INISetting kMaxEnchantPower_Tier03_SoulShaper03		("MaxEnchantPower_Tier03_SoulShaper03", "PerkPowerMaxLearnable", "", (float)1.40);

// [GamePatches]
INISetting kRemoveMagicSkillAssociations("RemoveMagicSkillAssociations", "GamePatches", "Set Vanilla Enchantment Skill Associations to NONE", (SInt32)1);
INISetting kRenameForms					("RenameForms",                  "GamePatches", "Rename a few Enchantments & Forms for consistency",  (SInt32)1);




void EnchantingAwakenedINIManager::Initialize(const char* INIPath, void* Paramenter)
{
	this->INIFilePath = INIPath;

	std::fstream INIStream(INIPath, std::fstream::in);
	bool CreateINI = false;

	if (INIStream.fail())
	{
		_MESSAGE("INI File not found; Creating one...");
		CreateINI = true;
	}

	_MESSAGE("INI Path = %s", INIPath);

	INIStream.close();
	INIStream.clear();

// [LearnMultipliers]
	RegisterSetting(&kLearnMult_AllWeapons);
	RegisterSetting(&kLearnMult_Alchemy);
	RegisterSetting(&kLearnMult_Alteration);
	RegisterSetting(&kLearnMult_Archery);
	RegisterSetting(&kLearnMult_Block);
	RegisterSetting(&kLearnMult_Carry);
	RegisterSetting(&kLearnMult_Conjuration);
	RegisterSetting(&kLearnMult_Destruction);
	RegisterSetting(&kLearnMult_HealRate);
	RegisterSetting(&kLearnMult_Health);
	RegisterSetting(&kLearnMult_HeavyArmor);
	RegisterSetting(&kLearnMult_Illusion);
	RegisterSetting(&kLearnMult_LightArmor);
	RegisterSetting(&kLearnMult_Lockpicking);
	RegisterSetting(&kLearnMult_Magicka);
	RegisterSetting(&kLearnMult_MagickaRate);
	RegisterSetting(&kLearnMult_Muffle);
	RegisterSetting(&kLearnMult_OneHanded);
	RegisterSetting(&kLearnMult_Persuasion);
	RegisterSetting(&kLearnMult_Pickpocket);
	RegisterSetting(&kLearnMult_ResistDisease);
	RegisterSetting(&kLearnMult_ResistFire);
	RegisterSetting(&kLearnMult_ResistFrost);
	RegisterSetting(&kLearnMult_ResistMagic);
	RegisterSetting(&kLearnMult_ResistPoison);
	RegisterSetting(&kLearnMult_ResistShock);
	RegisterSetting(&kLearnMult_Restoration);
	RegisterSetting(&kLearnMult_Smithing);
	RegisterSetting(&kLearnMult_Sneak);
	RegisterSetting(&kLearnMult_Speed);
	RegisterSetting(&kLearnMult_Stamina);
	RegisterSetting(&kLearnMult_StaminaRate);
	RegisterSetting(&kLearnMult_TwoHanded);
	RegisterSetting(&kLearnMult_Unarmed);
	RegisterSetting(&kLearnMult_Waterbreathing);
	RegisterSetting(&kLearnMult_UnknownEffects);

// [PerkPowerBase]
	RegisterSetting(&kBaseEnchantPower_Tier01_NoPerks);
	RegisterSetting(&kBaseEnchantPower_Tier02_NoPerks);
	RegisterSetting(&kBaseEnchantPower_Tier03_NoPerks);
	RegisterSetting(&kBaseEnchantPower_Tier01_SoulShaper01);
	RegisterSetting(&kBaseEnchantPower_Tier02_SoulShaper01);
	RegisterSetting(&kBaseEnchantPower_Tier03_SoulShaper01);
	RegisterSetting(&kBaseEnchantPower_Tier01_SoulShaper02);
	RegisterSetting(&kBaseEnchantPower_Tier02_SoulShaper02);
	RegisterSetting(&kBaseEnchantPower_Tier03_SoulShaper02);
	RegisterSetting(&kBaseEnchantPower_Tier01_SoulShaper03);
	RegisterSetting(&kBaseEnchantPower_Tier02_SoulShaper03);
	RegisterSetting(&kBaseEnchantPower_Tier03_SoulShaper03);

// [PerkPowerMaxLearnable]
	RegisterSetting(&kMaxEnchantPower_Tier01_NoPerks);
	RegisterSetting(&kMaxEnchantPower_Tier02_NoPerks);
	RegisterSetting(&kMaxEnchantPower_Tier03_NoPerks);
	RegisterSetting(&kMaxEnchantPower_Tier01_SoulShaper01);
	RegisterSetting(&kMaxEnchantPower_Tier02_SoulShaper01);
	RegisterSetting(&kMaxEnchantPower_Tier03_SoulShaper01);
	RegisterSetting(&kMaxEnchantPower_Tier01_SoulShaper02);
	RegisterSetting(&kMaxEnchantPower_Tier02_SoulShaper02);
	RegisterSetting(&kMaxEnchantPower_Tier03_SoulShaper02);
	RegisterSetting(&kMaxEnchantPower_Tier01_SoulShaper03);
	RegisterSetting(&kMaxEnchantPower_Tier02_SoulShaper03);
	RegisterSetting(&kMaxEnchantPower_Tier03_SoulShaper03);

// [GamePatches]
	RegisterSetting(&kRemoveMagicSkillAssociations);
	RegisterSetting(&kRenameForms);

	if (CreateINI)
		Save();

	PopulateFromSection(Tier01EnchantmentsSectionName);
	PopulateFromSection(Tier02EnchantmentsSectionName);
	PopulateFromSection(Tier03EnchantmentsSectionName);
	PopulateFromSection(AetherCoreEnchantmentsSectionName);
	PopulateFromSection(ChaosCoreEnchantmentsSectionName);
	PopulateFromSection(CorpusCoreEnchantmentsSectionName);
	PopulateFromSection(AetherExclusiveEnchantmentsSectionName);
	PopulateFromSection(ChaosExclusiveEnchantmentsSectionName);
	PopulateFromSection(CorpusExclusiveEnchantmentsSectionName);
	PopulateFromSection(EnchantmentExclusionsSectionName);
	PopulateFromSection(ModExclusionsSectionName);
}





void ApplyMultByIndex(VMArray<float> &multsToModify, UInt32 index, float iniVal, float max)
{
	//Enforce limits
	if (iniVal < 0.0)
		iniVal = 0.0;
	else if (iniVal > max)
		iniVal = max;

	float data;
	multsToModify.Get(&data, index);
	data *= iniVal;
	multsToModify.Set(&data, index);
}

void EnchantingAwakenedINIManager::ApplyIniMultModifiers(VMArray<float> &multsToModify)
{
	const float LIMIT = 100.0;

	ApplyMultByIndex(multsToModify, 0, kLearnMult_Alchemy.GetData().f, LIMIT);
	ApplyMultByIndex(multsToModify, 1, kLearnMult_Alteration.GetData().f, LIMIT);
	ApplyMultByIndex(multsToModify, 2, kLearnMult_Archery.GetData().f, LIMIT);
	ApplyMultByIndex(multsToModify, 3, kLearnMult_Block.GetData().f, LIMIT);
	ApplyMultByIndex(multsToModify, 4, kLearnMult_Carry.GetData().f, LIMIT);
	ApplyMultByIndex(multsToModify, 5, kLearnMult_Conjuration.GetData().f, LIMIT);
	ApplyMultByIndex(multsToModify, 6, kLearnMult_Destruction.GetData().f, LIMIT);
	ApplyMultByIndex(multsToModify, 7, kLearnMult_HealRate.GetData().f, LIMIT);
	ApplyMultByIndex(multsToModify, 8, kLearnMult_Health.GetData().f, LIMIT);
	ApplyMultByIndex(multsToModify, 9, kLearnMult_HeavyArmor.GetData().f, LIMIT);
	ApplyMultByIndex(multsToModify, 10, kLearnMult_Illusion.GetData().f, LIMIT);
	ApplyMultByIndex(multsToModify, 11, kLearnMult_LightArmor.GetData().f, LIMIT);
	ApplyMultByIndex(multsToModify, 12, kLearnMult_Lockpicking.GetData().f, LIMIT);
	ApplyMultByIndex(multsToModify, 13, kLearnMult_Magicka.GetData().f, LIMIT);
	ApplyMultByIndex(multsToModify, 14, kLearnMult_MagickaRate.GetData().f, LIMIT);
	ApplyMultByIndex(multsToModify, 15, kLearnMult_Muffle.GetData().f, LIMIT);
	ApplyMultByIndex(multsToModify, 16, kLearnMult_OneHanded.GetData().f, LIMIT);
	ApplyMultByIndex(multsToModify, 17, kLearnMult_Persuasion.GetData().f, LIMIT);
	ApplyMultByIndex(multsToModify, 18, kLearnMult_Pickpocket.GetData().f, LIMIT);
	ApplyMultByIndex(multsToModify, 19, kLearnMult_ResistDisease.GetData().f, LIMIT);
	ApplyMultByIndex(multsToModify, 20, kLearnMult_ResistFire.GetData().f, LIMIT);
	ApplyMultByIndex(multsToModify, 21, kLearnMult_ResistFrost.GetData().f, LIMIT);
	ApplyMultByIndex(multsToModify, 22, kLearnMult_ResistMagic.GetData().f, LIMIT);
	ApplyMultByIndex(multsToModify, 23, kLearnMult_ResistPoison.GetData().f, LIMIT);
	ApplyMultByIndex(multsToModify, 24, kLearnMult_ResistShock.GetData().f, LIMIT);
	ApplyMultByIndex(multsToModify, 25, kLearnMult_Restoration.GetData().f, LIMIT);
	ApplyMultByIndex(multsToModify, 26, kLearnMult_Smithing.GetData().f, LIMIT);
	ApplyMultByIndex(multsToModify, 27, kLearnMult_Sneak.GetData().f, LIMIT);
	ApplyMultByIndex(multsToModify, 28, kLearnMult_Speed.GetData().f, LIMIT);
	ApplyMultByIndex(multsToModify, 29, kLearnMult_Stamina.GetData().f, LIMIT);
	ApplyMultByIndex(multsToModify, 30, kLearnMult_StaminaRate.GetData().f, LIMIT);
	ApplyMultByIndex(multsToModify, 31, kLearnMult_TwoHanded.GetData().f, LIMIT);
	ApplyMultByIndex(multsToModify, 32, kLearnMult_Unarmed.GetData().f, LIMIT);
	ApplyMultByIndex(multsToModify, 33, kLearnMult_Waterbreathing.GetData().f, LIMIT);
	ApplyMultByIndex(multsToModify, 34, kLearnMult_UnknownEffects.GetData().f, LIMIT);
	ApplyMultByIndex(multsToModify, 35, kLearnMult_AllWeapons.GetData().f, LIMIT);
}


void SetFloatByIndex(VMArray<float> &dest, UInt32 index, float iniVal, float min, float max)
{
	//Enforce limits
	if (iniVal < min)
		iniVal = min;
	else if (iniVal > max)
		iniVal = max;

	dest.Set(&iniVal, index);
}

void EnchantingAwakenedINIManager::GetIniPerkPowerVals(VMArray<float> &basePowers, VMArray<float> &learnPowers)
{
	const float LIMIT = 10.0;

	SetFloatByIndex(basePowers, 0, kBaseEnchantPower_Tier01_NoPerks.GetData().f, 0.0, LIMIT);
	SetFloatByIndex(basePowers, 1, kBaseEnchantPower_Tier02_NoPerks.GetData().f, 0.0, LIMIT);
	SetFloatByIndex(basePowers, 2, kBaseEnchantPower_Tier03_NoPerks.GetData().f, 0.0, LIMIT);
	SetFloatByIndex(basePowers, 3, kBaseEnchantPower_Tier01_SoulShaper01.GetData().f, 0.0, LIMIT);
	SetFloatByIndex(basePowers, 4, kBaseEnchantPower_Tier02_SoulShaper01.GetData().f, 0.0, LIMIT);
	SetFloatByIndex(basePowers, 5, kBaseEnchantPower_Tier03_SoulShaper01.GetData().f, 0.0, LIMIT);
	SetFloatByIndex(basePowers, 6, kBaseEnchantPower_Tier01_SoulShaper02.GetData().f, 0.0, LIMIT);
	SetFloatByIndex(basePowers, 7, kBaseEnchantPower_Tier02_SoulShaper02.GetData().f, 0.0, LIMIT);
	SetFloatByIndex(basePowers, 8, kBaseEnchantPower_Tier03_SoulShaper02.GetData().f, 0.0, LIMIT);
	SetFloatByIndex(basePowers, 9, kBaseEnchantPower_Tier01_SoulShaper03.GetData().f, 0.0, LIMIT);
	SetFloatByIndex(basePowers, 10, kBaseEnchantPower_Tier02_SoulShaper03.GetData().f, 0.0, LIMIT);
	SetFloatByIndex(basePowers, 11, kBaseEnchantPower_Tier03_SoulShaper03.GetData().f, 0.0, LIMIT);

	SetFloatByIndex(learnPowers, 0, kMaxEnchantPower_Tier01_NoPerks.GetData().f, kBaseEnchantPower_Tier01_NoPerks.GetData().f, LIMIT);
	SetFloatByIndex(learnPowers, 1, kMaxEnchantPower_Tier02_NoPerks.GetData().f, kBaseEnchantPower_Tier02_NoPerks.GetData().f, LIMIT);
	SetFloatByIndex(learnPowers, 2, kMaxEnchantPower_Tier03_NoPerks.GetData().f, kBaseEnchantPower_Tier03_NoPerks.GetData().f, LIMIT);
	SetFloatByIndex(learnPowers, 3, kMaxEnchantPower_Tier01_SoulShaper01.GetData().f, kBaseEnchantPower_Tier01_SoulShaper01.GetData().f, LIMIT);
	SetFloatByIndex(learnPowers, 4, kMaxEnchantPower_Tier02_SoulShaper01.GetData().f, kBaseEnchantPower_Tier02_SoulShaper01.GetData().f, LIMIT);
	SetFloatByIndex(learnPowers, 5, kMaxEnchantPower_Tier03_SoulShaper01.GetData().f, kBaseEnchantPower_Tier03_SoulShaper01.GetData().f, LIMIT);
	SetFloatByIndex(learnPowers, 6, kMaxEnchantPower_Tier01_SoulShaper02.GetData().f, kBaseEnchantPower_Tier01_SoulShaper02.GetData().f, LIMIT);
	SetFloatByIndex(learnPowers, 7, kMaxEnchantPower_Tier02_SoulShaper02.GetData().f, kBaseEnchantPower_Tier02_SoulShaper02.GetData().f, LIMIT);
	SetFloatByIndex(learnPowers, 8, kMaxEnchantPower_Tier03_SoulShaper02.GetData().f, kBaseEnchantPower_Tier03_SoulShaper02.GetData().f, LIMIT);
	SetFloatByIndex(learnPowers, 9, kMaxEnchantPower_Tier01_SoulShaper03.GetData().f, kBaseEnchantPower_Tier01_SoulShaper03.GetData().f, LIMIT);
	SetFloatByIndex(learnPowers, 10, kMaxEnchantPower_Tier02_SoulShaper03.GetData().f, kBaseEnchantPower_Tier02_SoulShaper03.GetData().f, LIMIT);
	SetFloatByIndex(learnPowers, 11, kMaxEnchantPower_Tier03_SoulShaper03.GetData().f, kBaseEnchantPower_Tier03_SoulShaper03.GetData().f, LIMIT);
}