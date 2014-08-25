Scriptname EA_Learn_Delegator extends ReferenceAlias
{delegates various tasks necessary for learning to work}

Actor            property playerRef            auto
EA_ConfigMenu    property ConfigMenu           auto
Message          property EA_SeeMenuForDetails auto
MagicEffect[]    property enchantEffects       auto        ;All enchantment effects that have learning mechanics implemented
GlobalVariable[] property enchantEffectsCount  auto        ;Counters for specific active effects. Used to conditionalize some stuff in EA_Learn_Controller
int[]            property abilityCodes         auto        ;Correlated to enchantEffects[]. This provides the index of the learning ability that should be
;                                                            applied to the player, found in learnAbilities[] (some effects share  the same learn ability)
Spell[]          property learnAbilities       auto        ;Learning abilities
int[]            property learnAbilitiesCount  auto hidden ;Counter for effects using this learn ability. When this reaches zero again, ability is removed


Event OnLearnInform(Form mgef, bool startLearn)
	LEARNLOCK(TRUE)
		if (!mgef)
			debug.trace("Enchanting Awakened >>>>>>>>>>>>>>>>>>>>> NULL MGEF RECIEVED by Learn Delegator")
			LEARNLOCK(FALSE)
			return
		endif
		int effectID = enchantEffects.find(mgef as MagicEffect)
		debug.trace("Enchanting Awakened >>>>>>>>>>>>>>>>>>>>> effect recieved by Learn Delegator: [" + (mgef as form).getName() + "]")
		if (effectID >= 0)
			if (startLearn)
				EnableLearning(abilityCodes[effectID])
				if (enchantEffectsCount[effectID]) ;only some effects have a global counter
					enchantEffectsCount[effectID].Mod(1.0)
					SendModEvent("EA_UpdateActiveLearnEffects")
				endif
			else
				if (enchantEffectsCount[effectID])
					enchantEffectsCount[effectID].Mod(-1.0)
					SendModEvent("EA_UpdateActiveLearnEffects")
				endif
				DisableLearning(abilityCodes[effectID])
			endif
		else
			debug.trace("Enchanting Awakened >>>>>>>>>>>>>>>>>>>>> Unrecognized effect type")
		endif
	LEARNLOCK(FALSE)
EndEvent


Function EnableLearning(int code)
	debug.trace("Enchanting Awakened >>>>>>>>>>>>>>>>>>>>> " + (learnAbilities[code] as form).getName() + " enabled. New Count = " + (learnAbilitiesCount[code] + 1))
	if (learnAbilitiesCount[code] == 0)
		playerRef.AddSpell(learnAbilities[code])
		debug.trace("Enchanting Awakened >>>>>>>>>>>>>>>>>>>>> " + (learnAbilities[code] as form).getName() + " Ability ADDED")
	endif
	learnAbilitiesCount[code] = learnAbilitiesCount[code] + 1        ;need to fix all the unnecessary conditions on my magic effects now...
EndFunction

Function DisableLearning(int code)
	learnAbilitiesCount[code] = learnAbilitiesCount[code] - 1
	debug.trace("Enchanting Awakened >>>>>>>>>>>>>>>>>>>>> " + (learnAbilities[code] as form).getName() + " disabled. New Count = " + learnAbilitiesCount[code])
	if (learnAbilitiesCount[code] == 0)
		playerRef.RemoveSpell(learnAbilities[code])
		debug.trace("Enchanting Awakened >>>>>>>>>>>>>>>>>>>>> " + (learnAbilities[code] as form).getName() + " Ability REMOVED")
	endif
EndFunction


Event OnPlayerLoadGame()
	RegisterForModEvent("EA_LearnInform", "OnLearnInform")
EndEvent

Event OnInit()
	;enchantEffectsCount = new int[48]
	learnAbilitiesCount = new int[29] ;current size of abilities array
	RegisterForModEvent("EA_LearnInform", "OnLearnInform")

	RegisterForModEvent("EA_LearnableEquipCheck", "OnLearnableEquipCheck")
    int eventCode = ModEvent.Create("EA_LearnableEquipCheck")
    ModEvent.Send(eventCode)
EndEvent

Event OnLearnableEquipCheck()
	if (HasLearnableEnchantEquipped(playerRef))
		ConfigMenu.queueReequipWarning = true
		Utility.Wait(30.0)
		if (ConfigMenu.queueReequipWarning)
			EA_SeeMenuForDetails.show() ;Please check Enchanting Awakened's MCM Menu for an important message.
		endif
	endif
EndEvent

bool _learnLock = false
Function LEARNLOCK(bool enter)
	if (enter)
		while (_learnLock)
			Utility.Wait(0.2)
		endWhile
		_learnLock = true
	else
		_learnLock = false
	endif
EndFunction


bool Function HasLearnableEnchantEquipped(Actor target)
	int slotsChecked
	slotsChecked += 0x00100000 ;ignore reserved slots
	slotsChecked += 0x00200000
	slotsChecked += 0x80000000
	int thisSlot  = 0x01

	while (thisSlot < 0x80000000)
		if (Math.LogicalAnd(slotsChecked, thisSlot) != thisSlot)
			Armor thisArmor = target.GetWornForm(thisSlot) as Armor
			if (thisArmor)
				Enchantment e = thisArmor.GetEnchantment()
				if (!e)
					e = WornObject.GetEnchantment(target, 0, thisSlot)
				endif
				if (e)
					int n = e.GetCostliestEffectIndex()
					MagicEffect mgef = e.GetNthEffectMagicEffect(n)
					if (enchantEffects.find(mgef) >= 0)
						return true
					endif
				endif
				slotsChecked += thisArmor.GetSlotMask()
			else
				slotsChecked += thisSlot
			endif
		endif
		thisSlot *= 2
	endWhile

	return false
EndFunction


;/ Filled in the CK

	enchantEffects[0]  = EnchFortifyAlchemyConstantSelf
	enchantEffects[1]  = EnchFortifyArcheryConstantSelf
	enchantEffects[2]  = EnchFortifyBlockConstantSelf
	enchantEffects[3]  = EnchFortifyCarryConstantSelf
	enchantEffects[4]  = EnchFortifyHealRateConstantSelf
	enchantEffects[5]  = EnchFortifyHealthConstantSelf
	enchantEffects[6]  = EnchFortifyHeavyArmorConstantSelf
	enchantEffects[7]  = EnchFortifyLightArmorConstantSelf
	enchantEffects[8]  = EnchFortifyLockpickingConstantSelf
	enchantEffects[9]  = EnchFortifyMagickaConstantSelf
	enchantEffects[10] = EnchFortifyMagickaRateConstantSelf
	enchantEffects[11] = EnchRobesFortifyMagickaRateConstantSelf
	enchantEffects[12] = EA_EnchRobesFortifyMagickaRateConstantSelf
	enchantEffects[13] = EnchFortifyOneHandedConstantSelf
	enchantEffects[14] = EnchFortifyPersuasionConstantSelf
	enchantEffects[15] = EnchFortifyArticulation
	enchantEffects[16] = EnchFortifySpeechcraftConstantSelf
	enchantEffects[17] = EnchFortifyPickpocketConstantSelf
	enchantEffects[18] = EnchFortifySmithingConstantSelf
	enchantEffects[19] = EnchFortifySneakConstantSelf
	enchantEffects[20] = EnchFortifyStaminaConstantSelf
	enchantEffects[21] = EnchFortifyStaminaRateConstantSelf
	enchantEffects[22] = EnchFortifyTwoHandedConstantSelf
	enchantEffects[23] = EnchFortifyUnarmedDamage
	enchantEffects[24] = EnchResistDiseaseConstantSelf
	enchantEffects[25] = EnchResistFireConstantSelf
	enchantEffects[26] = EnchResistFrostConstantSelf
	enchantEffects[27] = EnchResistMagicConstantSelf
	enchantEffects[28] = EnchResistPoisonConstantSelf
	enchantEffects[29] = EnchResistShocktConstantSelf
	enchantEffects[30] = EnchMuffleConstantSelf
	enchantEffects[31] = EnchWaterbreathingConstantSelf
	enchantEffects[32] = EA_EnchArmorSpeedMult
	enchantEffects[33] = EnchFortifyAlterationConstantSelf
	enchantEffects[34] = EnchRobesFortifyAlterationConstantSelf
	enchantEffects[35] = EA_EnchRobesAlterationBase
	enchantEffects[36] = EnchFortifyConjurationConstantSelf
	enchantEffects[37] = EnchRobesFortifyConjurationConstantSelf
	enchantEffects[38] = EA_EnchRobesConjurationBase
	enchantEffects[39] = EnchFortifyDestructionConstantSelf
	enchantEffects[40] = EnchRobesFortifyDestructionConstantSelf
	enchantEffects[41] = EA_EnchRobesDestructionBase
	enchantEffects[42] = EnchFortifyIllusionConstantSelf
	enchantEffects[43] = EnchRobesFortifyIllusionConstantSelf
	enchantEffects[44] = EA_EnchRobesIllusionBase
	enchantEffects[45] = EnchFortifyRestorationConstantSelf
	enchantEffects[46] = EnchRobesFortifyRestorationConstantSelf
	enchantEffects[47] = EA_EnchRobesRestorationBase


	abilityCodes[0]  = 0    ; EnchFortifyAlchemyConstantSelf
	abilityCodes[1]  = 1    ; EnchFortifyArcheryConstantSelf
	abilityCodes[2]  = 2    ; EnchFortifyBlockConstantSelf
	abilityCodes[3]  = 3    ; EnchFortifyCarryConstantSelf
	abilityCodes[4]  = 4    ; EnchFortifyHealRateConstantSelf
	abilityCodes[5]  = 5    ; EnchFortifyHealthConstantSelf
	abilityCodes[6]  = 6    ; EnchFortifyHeavyArmorConstantSelf
	abilityCodes[7]  = 7    ; EnchFortifyLightArmorConstantSelf
	abilityCodes[8]  = 8    ; EnchFortifyLockpickingConstantSelf
	abilityCodes[9]  = 9    ; EnchFortifyMagickaConstantSelf
	abilityCodes[10] = 10   ; EnchFortifyMagickaRateConstantSelf
	abilityCodes[11] = 10   ; EnchRobesFortifyMagickaRateConstantSelf
	abilityCodes[12] = 10   ; EA_EnchRobesFortifyMagickaRateConstantSelf
	abilityCodes[13] = 11   ; EnchFortifyOneHandedConstantSelf
	abilityCodes[14] = 12   ; EnchFortifyPersuasionConstantSelf
	abilityCodes[15] = 12   ; EnchFortifyArticulation
	abilityCodes[16] = 12   ; EnchFortifySpeechcraftConstantSelf
	abilityCodes[17] = 13   ; EnchFortifyPickpocketConstantSelf
	abilityCodes[18] = 14   ; EnchFortifySmithingConstantSelf
	abilityCodes[19] = 15   ; EnchFortifySneakConstantSelf
	abilityCodes[20] = 16   ; EnchFortifyStaminaConstantSelf
	abilityCodes[21] = 16   ; EnchFortifyStaminaRateConstantSelf
	abilityCodes[22] = 17   ; EnchFortifyTwoHandedConstantSelf
	abilityCodes[23] = 18   ; EnchFortifyUnarmedDamage
	abilityCodes[24] = 19   ; EnchResistDiseaseConstantSelf
	abilityCodes[25] = 20   ; EnchResistFireConstantSelf
	abilityCodes[26] = 21   ; EnchResistFrostConstantSelf
	abilityCodes[27] = 22   ; EnchResistMagicConstantSelf
	abilityCodes[28] = 23   ; EnchResistPoisonConstantSelf
	abilityCodes[29] = 24   ; EnchResistShocktConstantSelf
	abilityCodes[30] = 25   ; EnchMuffleConstantSelf
	abilityCodes[31] = 26   ; EnchWaterbreathingConstantSelf
	abilityCodes[32] = 27   ; EA_EnchArmorSpeedMult
	abilityCodes[33] = 28   ; EnchFortifyAlterationConstantSelf
	abilityCodes[34] = 28   ; EnchRobesFortifyAlterationConstantSelf
	abilityCodes[35] = 28   ; EA_EnchRobesAlterationBase
	abilityCodes[36] = 28   ; EnchFortifyConjurationConstantSelf
	abilityCodes[37] = 28   ; EnchRobesFortifyConjurationConstantSelf
	abilityCodes[38] = 28   ; EA_EnchRobesConjurationBase
	abilityCodes[39] = 28   ; EnchFortifyDestructionConstantSelf
	abilityCodes[40] = 28   ; EnchRobesFortifyDestructionConstantSelf
	abilityCodes[41] = 28   ; EA_EnchRobesDestructionBase
	abilityCodes[42] = 28   ; EnchFortifyIllusionConstantSelf
	abilityCodes[43] = 28   ; EnchRobesFortifyIllusionConstantSelf
	abilityCodes[44] = 28   ; EA_EnchRobesIllusionBase
	abilityCodes[45] = 28   ; EnchFortifyRestorationConstantSelf
	abilityCodes[46] = 28   ; EnchRobesFortifyRestorationConstantSelf
	abilityCodes[47] = 28   ; EA_EnchRobesRestorationBase


















not included (not sure what I'm doing with weapons yet...)

	enchantEffects[45] = Game.GetFormFromFile(0x04605B, "Skyrim.esm")             ; 45 EnchFrostDamageFFContact
	;enchantEffects[47] = Game.GetFormFromFile(0x0BEE94, "Skyrim.esm")             ;;  EnchInfluenceConfDownFFContactHigh
	enchantEffects[46] = Game.GetFormFromFile(0x05B451, "Skyrim.esm")             ; 46 EnchInfluenceConfDownFFContactLow
	;enchantEffects[49] = Game.GetFormFromFile(0x0BEE93, "Skyrim.esm")             ;;  EnchInfluenceConfDownFFContactMed
	enchantEffects[47] = Game.GetFormFromFile(0x05B44F, "Skyrim.esm")             ; 47 EnchMagickaDamageFFContact
	enchantEffects[48] = Game.GetFormFromFile(0x0ACBB6, "Skyrim.esm")             ; 48 EnchParalysisFFContact
	enchantEffects[49] = Game.GetFormFromFile(0x04605C, "Skyrim.esm")             ; 49 EnchShockDamageFFContact
	enchantEffects[50] = Game.GetFormFromFile(0x0F5D24, "Skyrim.esm")             ; 50 EnchSoulTrapFFAimedArea
	enchantEffects[51] = Game.GetFormFromFile(0x05B452, "Skyrim.esm")             ; 51 EnchSoulTrapFFContact
	enchantEffects[52] = Game.GetFormFromFile(0x05B450, "Skyrim.esm")             ; 52 EnchStaminaDamageFFContact
	enchantEffects[53] = Game.GetFormFromFile(0x05B46B, "Skyrim.esm")             ; 53 EnchTurnUndeadFFContact
	enchantEffects[54] = Game.GetFormFromFile(0x0AA155, "Skyrim.esm")             ; 54 EnchAbsorbHealthFFContact
	enchantEffects[55] = Game.GetFormFromFile(0x0AA156, "Skyrim.esm")             ; 55 EnchAbsorbMagickaFFContact
	enchantEffects[56] = Game.GetFormFromFile(0x0AA157, "Skyrim.esm")             ; 56 EnchAbsorbStaminaFFContact
	enchantEffects[57] = Game.GetFormFromFile(0x0ACBB5, "Skyrim.esm")             ; 57 EnchBanishFFContact
	enchantEffects[58] = Game.GetFormFromFile(0x04605A, "Skyrim.esm")             ; 58 EnchFireDamageFFContact

	;include hunter's prowess and pickaxe enchant?

	;account for SkyRe/Requiem here?

/;