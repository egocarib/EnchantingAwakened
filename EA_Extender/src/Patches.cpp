#include "skse/GameForms.h"
#include "skse/GameData.h"
#include "skse/GameRTTI.h"
#include "EnchantingAwakenedData.h"
#include "Patches.h"
#include "Ini.h"

namespace EAPatches
{
	const UInt32 kNONE = 0xFFFFFFFF;

	void ApplyFormPatches()
	{
		if (kRemoveMagicSkillAssociations.GetData().i > 0)
		{
			//Remove magic skill associations from vanilla enchantments:

			EffectSetting* eff;

			if (eff = DYNAMIC_CAST(LookupFormByID(0x017120), TESForm, EffectSetting))  eff->properties.school = kNONE; //EnchFortifyArmorRatingSelf
			if (eff = DYNAMIC_CAST(LookupFormByID(0x04605A), TESForm, EffectSetting))  eff->properties.school = kNONE; //EnchFireDamageFFContact
			if (eff = DYNAMIC_CAST(LookupFormByID(0x04605B), TESForm, EffectSetting))  eff->properties.school = kNONE; //EnchFrostDamageFFContact
			if (eff = DYNAMIC_CAST(LookupFormByID(0x04605C), TESForm, EffectSetting))  eff->properties.school = kNONE; //EnchShockDamageFFContact
			if (eff = DYNAMIC_CAST(LookupFormByID(0x048C8B), TESForm, EffectSetting))  eff->properties.school = kNONE; //EnchResistFireConstantSelf
			if (eff = DYNAMIC_CAST(LookupFormByID(0x048F45), TESForm, EffectSetting))  eff->properties.school = kNONE; //EnchResistFrostConstantSelf
			if (eff = DYNAMIC_CAST(LookupFormByID(0x049295), TESForm, EffectSetting))  eff->properties.school = kNONE; //EnchResistShocktConstantSelf
			if (eff = DYNAMIC_CAST(LookupFormByID(0x0493AA), TESForm, EffectSetting))  eff->properties.school = kNONE; //EnchFortifyHealthConstantSelf
			if (eff = DYNAMIC_CAST(LookupFormByID(0x049504), TESForm, EffectSetting))  eff->properties.school = kNONE; //EnchFortifyMagickaConstantSelf
			if (eff = DYNAMIC_CAST(LookupFormByID(0x049507), TESForm, EffectSetting))  eff->properties.school = kNONE; //EnchFortifyStaminaConstantSelf
			if (eff = DYNAMIC_CAST(LookupFormByID(0x05B44F), TESForm, EffectSetting))  eff->properties.school = kNONE; //EnchMagickaDamageFFContact
			if (eff = DYNAMIC_CAST(LookupFormByID(0x05B451), TESForm, EffectSetting))  eff->properties.school = kNONE; //EnchInfluenceConfDownFFContactLow
			if (eff = DYNAMIC_CAST(LookupFormByID(0x05B46B), TESForm, EffectSetting))  eff->properties.school = kNONE; //EnchTurnUndeadFFContact
			if (eff = DYNAMIC_CAST(LookupFormByID(0x07A0F2), TESForm, EffectSetting))  eff->properties.school = kNONE; //EnchFortifyAlterationConstantSelf
			if (eff = DYNAMIC_CAST(LookupFormByID(0x07A0F3), TESForm, EffectSetting))  eff->properties.school = kNONE; //EnchFortifyBlockConstantSelf
			if (eff = DYNAMIC_CAST(LookupFormByID(0x07A0F4), TESForm, EffectSetting))  eff->properties.school = kNONE; //EnchFortifyCarryConstantSelf
			if (eff = DYNAMIC_CAST(LookupFormByID(0x07A0F6), TESForm, EffectSetting))  eff->properties.school = kNONE; //EnchFortifyDestructionConstantSelf
			if (eff = DYNAMIC_CAST(LookupFormByID(0x07A0F8), TESForm, EffectSetting))  eff->properties.school = kNONE; //EnchFortifyHealRateConstantSelf
			if (eff = DYNAMIC_CAST(LookupFormByID(0x07A0F9), TESForm, EffectSetting))  eff->properties.school = kNONE; //EnchFortifyHeavyArmorConstantSelf
			if (eff = DYNAMIC_CAST(LookupFormByID(0x07A0FA), TESForm, EffectSetting))  eff->properties.school = kNONE; //EnchFortifyIllusionConstantSelf
			if (eff = DYNAMIC_CAST(LookupFormByID(0x07A0FB), TESForm, EffectSetting))  eff->properties.school = kNONE; //EnchFortifyLightArmorConstantSelf
			if (eff = DYNAMIC_CAST(LookupFormByID(0x07A0FC), TESForm, EffectSetting))  eff->properties.school = kNONE; //EnchFortifyLockpickingConstantSelf
			if (eff = DYNAMIC_CAST(LookupFormByID(0x07A0FD), TESForm, EffectSetting))  eff->properties.school = kNONE; //EnchFortifyMagickaRateConstantSelf
			if (eff = DYNAMIC_CAST(LookupFormByID(0x07A0FE), TESForm, EffectSetting))  eff->properties.school = kNONE; //EnchFortifyArcheryConstantSelf
			if (eff = DYNAMIC_CAST(LookupFormByID(0x07A0FF), TESForm, EffectSetting))  eff->properties.school = kNONE; //EnchFortifyOneHandedConstantSelf
			if (eff = DYNAMIC_CAST(LookupFormByID(0x07A100), TESForm, EffectSetting))  eff->properties.school = kNONE; //EnchFortifyPickpocketConstantSelf
			if (eff = DYNAMIC_CAST(LookupFormByID(0x07A101), TESForm, EffectSetting))  eff->properties.school = kNONE; //EnchFortifyRestorationConstantSelf
			if (eff = DYNAMIC_CAST(LookupFormByID(0x07A102), TESForm, EffectSetting))  eff->properties.school = kNONE; //EnchFortifySmithingConstantSelf
			if (eff = DYNAMIC_CAST(LookupFormByID(0x07A103), TESForm, EffectSetting))  eff->properties.school = kNONE; //EnchFortifySneakConstantSelf
			if (eff = DYNAMIC_CAST(LookupFormByID(0x07A105), TESForm, EffectSetting))  eff->properties.school = kNONE; //EnchFortifyStaminaRateConstantSelf
			if (eff = DYNAMIC_CAST(LookupFormByID(0x07A106), TESForm, EffectSetting))  eff->properties.school = kNONE; //EnchFortifyTwoHandedConstantSelf
			if (eff = DYNAMIC_CAST(LookupFormByID(0x08B65C), TESForm, EffectSetting))  eff->properties.school = kNONE; //EnchFortifyAlchemyConstantSelf
			if (eff = DYNAMIC_CAST(LookupFormByID(0x092A48), TESForm, EffectSetting))  eff->properties.school = kNONE; //EnchWaterbreathingConstantSelf
			if (eff = DYNAMIC_CAST(LookupFormByID(0x092A57), TESForm, EffectSetting))  eff->properties.school = kNONE; //EnchMuffleConstantSelf
			if (eff = DYNAMIC_CAST(LookupFormByID(0x0AA155), TESForm, EffectSetting))  eff->properties.school = kNONE; //EnchAbsorbHealthFFContact
			if (eff = DYNAMIC_CAST(LookupFormByID(0x0AA156), TESForm, EffectSetting))  eff->properties.school = kNONE; //EnchAbsorbMagickaFFContact
			if (eff = DYNAMIC_CAST(LookupFormByID(0x0AA157), TESForm, EffectSetting))  eff->properties.school = kNONE; //EnchAbsorbStaminaFFContact
			if (eff = DYNAMIC_CAST(LookupFormByID(0x0ACBB5), TESForm, EffectSetting))  eff->properties.school = kNONE; //EnchBanishFFContact
			if (eff = DYNAMIC_CAST(LookupFormByID(0x0BEE93), TESForm, EffectSetting))  eff->properties.school = kNONE; //EnchInfluenceConfDownFFContactMed
			if (eff = DYNAMIC_CAST(LookupFormByID(0x0BEE94), TESForm, EffectSetting))  eff->properties.school = kNONE; //EnchInfluenceConfDownFFContactHigh
			if (eff = DYNAMIC_CAST(LookupFormByID(0x0D6933), TESForm, EffectSetting))  eff->properties.school = kNONE; //EnchFortifyPersuasionConstantSelf
			if (eff = DYNAMIC_CAST(LookupFormByID(0x0FF15E), TESForm, EffectSetting))  eff->properties.school = kNONE; //EnchResistPoisonConstantSelf
			if (eff = DYNAMIC_CAST(LookupFormByID(0x100E60), TESForm, EffectSetting))  eff->properties.school = kNONE; //EnchResistDiseaseConstantSelf
			if (eff = DYNAMIC_CAST(LookupFormByID(0x1019D6), TESForm, EffectSetting))  eff->properties.school = kNONE; //dunVolunruudPickaxeEffect
			if (eff = DYNAMIC_CAST(LookupFormByID(0x10962E), TESForm, EffectSetting))  eff->properties.school = kNONE; //EnchRobesFortifyAlterationConstantSelf
			if (eff = DYNAMIC_CAST(LookupFormByID(0x10962F), TESForm, EffectSetting))  eff->properties.school = kNONE; //EnchRobesFortifyConjurationConstantSelf
			if (eff = DYNAMIC_CAST(LookupFormByID(0x109630), TESForm, EffectSetting))  eff->properties.school = kNONE; //EnchRobesFortifyMagickaRateConstantSelf
			if (eff = DYNAMIC_CAST(LookupFormByID(0x109631), TESForm, EffectSetting))  eff->properties.school = kNONE; //EnchRobesFortifyDestructionConstantSelf
			if (eff = DYNAMIC_CAST(LookupFormByID(0x109633), TESForm, EffectSetting))  eff->properties.school = kNONE; //EnchRobesFortifyIllusionConstantSelf
			if (eff = DYNAMIC_CAST(LookupFormByID(0x109634), TESForm, EffectSetting))  eff->properties.school = kNONE; //EnchRobesFortifyRestorationConstantSelf

			if (eff = DYNAMIC_CAST(LookupFormByID(g_DragonbornUpperByteIndex | 0x02C46B), TESForm, EffectSetting))  eff->properties.school = kNONE; //DLC2EnchFireDamageFFContact50
			if (eff = DYNAMIC_CAST(LookupFormByID(g_DragonbornUpperByteIndex | 0x02C46C), TESForm, EffectSetting))  eff->properties.school = kNONE; //DLC2EnchShockDamageFFContact50
			if (eff = DYNAMIC_CAST(LookupFormByID(g_DragonbornUpperByteIndex | 0x02C46D), TESForm, EffectSetting))  eff->properties.school = kNONE; //DLC2EnchFrostDamageFFContact50
		}

		if (kRenameForms.GetData().i > 0)
		{
			//Rename stuff:

			TESFullName* fName;

			BSFixedString chaosDamage("Chaos Damage");
			if (fName = DYNAMIC_CAST(LookupFormByID(g_DragonbornUpperByteIndex | 0x02C46B), TESForm, TESFullName))  fName->name = chaosDamage; //DLC2EnchFireDamageFFContact50
			if (fName = DYNAMIC_CAST(LookupFormByID(g_DragonbornUpperByteIndex | 0x02C46C), TESForm, TESFullName))  fName->name = chaosDamage; //DLC2EnchShockDamageFFContact50
			if (fName = DYNAMIC_CAST(LookupFormByID(g_DragonbornUpperByteIndex | 0x02C46D), TESForm, TESFullName))  fName->name = chaosDamage; //DLC2EnchFrostDamageFFContact50

			if (fName = DYNAMIC_CAST(LookupFormByID(0x10DF4B), TESForm, TESFullName))  fName->name = BSFixedString("Necklace of Minor Persuasion"); //EnchNecklaceSpeechcraft01
			if (fName = DYNAMIC_CAST(LookupFormByID(0x10DF4C), TESForm, TESFullName))  fName->name = BSFixedString("Necklace of Persuasion"); //EnchNecklaceSpeechcraft02
			if (fName = DYNAMIC_CAST(LookupFormByID(0x10DF4D), TESForm, TESFullName))  fName->name = BSFixedString("Necklace of Major Persuasion"); //EnchNecklaceSpeechcraft03
			if (fName = DYNAMIC_CAST(LookupFormByID(0x10DF4E), TESForm, TESFullName))  fName->name = BSFixedString("Necklace of Eminent Persuasion"); //EnchNecklaceSpeechcraft04
			if (fName = DYNAMIC_CAST(LookupFormByID(0x10DF4F), TESForm, TESFullName))  fName->name = BSFixedString("Necklace of Extreme Persuasion"); //EnchNecklaceSpeechcraft05
			if (fName = DYNAMIC_CAST(LookupFormByID(0x10DF50), TESForm, TESFullName))  fName->name = BSFixedString("Necklace of Peerless Persuasion"); //EnchNecklaceSpeechcraft06
		}
	}
};