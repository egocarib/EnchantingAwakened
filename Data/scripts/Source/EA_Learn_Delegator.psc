Scriptname EA_Learn_Delegator extends ReferenceAlias
{delegates various tasks necessary for learning to work}


Actor				property playerRef            auto
EA_ConfigMenu		property ConfigMenu           auto
EA_Learn_Controller	property Controller           auto hidden
MagicEffect[]		property enchantEffects       auto        ;All enchantment effects that have learning mechanics implemented
GlobalVariable[]	property enchantEffectsCount  auto        ;Counters for specific active effects. Used to conditionalize some stuff in EA_Learn_Controller
int[]				property abilityCodes         auto        ;Correlated to enchantEffects[]. This provides the index of the learning ability that should be       (should be 26 of these)
;                                                            applied to the player, found in learnAbilities[] (some effects share  the same learn ability)
int[]				property learnedTypeCodes     auto        ;indicates which specific type of mgef learning this is. slightly more specific than ability          (should be 33 of these)
;                                                            codes, because some magicEffects share the same learn ability but have their own experience trackers
;                                                            [example: the fortify magic enchantments have one ability code, but five different learnedTypeCodes]
Spell[]				property learnAbilities       auto        ;Learning abilities
int[]				property learnAbilitiesCount  auto hidden ;Counter for # of effects using this learn ability. When this reaches zero again, ability is removed

float				property kMultipleEffectScaleFactor = 0.66 auto hidden ;a single mgef's influence on "teaching" an enchantment equals [kMultipleEffectScaleFactor]^[numEffects - 1]

int					property UNKNOWN_ABILITY_INDEX = 26 autoreadonly ;index of last ability in LearnAbilities array; used for unknown effects


Event OnInit()
	learnAbilitiesCount = new int[27] ;Current Size of LearnAbilities[] array, set in CK (should equal UNKNOWN_ABILITY_INDEX + 1)
	OnPlayerLoadGame()
EndEvent

Event OnPlayerLoadGame()
	RegisterForModEvent(EA_Extender.GetArmorEnchantmentEquipEventName(), "OnLearnInform")
	;This event is sent from internal plugin whenever a new type of armor enchantment is equipped or unequipped.
	;All enchantments using the same base enchantment are considered equal by the internal plugin. Multiple
	;instances of the same enchantment equipped are ignored, so this event is only sent when the first item with
	;a specific base enchantment is equipped, or when the last item using that base enchantment has been removed.
	;
	;Learning is based on the base enchantment MGEFs as a result. Although there is a small chance that the base
	;enchantment could have different MGEFs than the actual equipped enchantment, this shouldn't really cause
	;any unexpected learning behavior unless a modder has given the base completely different & unrelated effects.
EndEvent

bool __learnLock = false
Function LEARNLOCK(bool enter)
	if (enter)
		while (__learnLock)
			Utility.waitmenumode(0.1)
		endWhile
		__learnLock = true
	else
		__learnLock = false
	endif
EndFunction




Event OnLearnInform(string eventName, string nullArg, float bIsEquipping, Form equippedEnchantmentBase)
	LEARNLOCK(TRUE)

		Enchantment baseEnchant = equippedEnchantmentBase as Enchantment
		MagicEffect[] mgefs = new MagicEffect[20] ;let's ignore any crazy modders who've added more than 20 effects to their enchantments.
		int numEffects = EA_Extender.GetEnchantmentMagicEffects(baseEnchant, mgefs)

		;determine how many mgefs are recognized effects with applicable learn abilities
		int[] recognizedMGEFs = new int[20]
		int recognizedCount = 0
		int i = 0
		while (i < numEffects)
			int thisIndex = enchantEffects.find(mgefs[i])
			if (thisIndex >= 0)
				recognizedMGEFs[recognizedCount] = thisIndex
				recognizedCount += 1
			endif
			i += 1
		endWhile

		if (recognizedCount)
			int power = 1
			float learnMult = 1.0
			while (power < recognizedCount) ;learnMult = [kMultipleEffectScaleFactor]^(recognizedCount - 1)
				learnMult *= kMultipleEffectScaleFactor
				power += 1
			endWhile

			while (recognizedCount)
				recognizedCount -= 1
				int mgefID = recognizedMGEFs[recognizedCount]
				LearnEnchantEffectRelay(mgefID, bIsEquipping, baseEnchant, learnMult)
			endWhile

		else ;unrecognized
			LearnEnchantEffectRelay(-1, bIsEquipping, baseEnchant, 1.0)
		endif

	LEARNLOCK(FALSE)
EndEvent


Function LearnEnchantEffectRelay(int mgefID, bool startLearn, Enchantment sourceEnchantment, float enchantmentLearnMult)

	if (startLearn)
		AssociateEffectData(mgefID, sourceEnchantment, enchantmentLearnMult)
	else
		DissociateEffectData(mgefID, sourceEnchantment)
	endif

	;;;DEBUG ONLY---------------------
	if (mgefID >= 0)
		debug.trace("Enchanting Awakened >>>>>>>>>>>>>>>>>>>>> effect recieved by Learn Delegator: [mgef: " + enchantEffects[mgefID].getName() + "  baseEnchant: " + sourceEnchantment.getName() + " equipping: " + startLearn + "]")
	else
		debug.trace("Enchanting Awakened >>>>>>>>>>>>>>>>>>>>> effect recieved by Learn Delegator: [mgef: UNRECOGNIZED  baseEnchant: " + sourceEnchantment.getName() + " equipping: " + startLearn + "]")
	endif
	;;;-------------------------------

	if (startLearn)
		if (mgefID >= 0)
			EnableLearning(abilityCodes[mgefID])
			if (enchantEffectsCount[mgefID]) ;only some effects have a global counter
				enchantEffectsCount[mgefID].Mod(1.0)
				SendModEvent("EA_UpdateActiveLearnEffects")
			endif
		else ;unknown effect
			EnableLearning(UNKNOWN_ABILITY_INDEX)
		endif
	else
		if (mgefID >= 0)
			if (enchantEffectsCount[mgefID])
				enchantEffectsCount[mgefID].Mod(-1.0)
				SendModEvent("EA_UpdateActiveLearnEffects")
			endif
			DisableLearning(abilityCodes[mgefID])
		else
			DisableLearning(UNKNOWN_ABILITY_INDEX)
		endif
	endif
EndFunction





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






Function AssociateEffectData(int mgefID, Enchantment enchant, float mult)
	int correlateID = StageCorrelationData(mgefID)

	int nextIndex = currentCorrelatedEnchants.find(none)

	if (currentCorrelatedEnchants.find(enchant) < 0) ;ensure data hasn't already been associated
		currentCorrelatedEnchants[nextIndex] = enchant
		currentCorrelatedMults[nextIndex] = mult
		LearnActiveCounts[correlateID] = (nextIndex + 1)
	endif
EndFunction

Function DissociateEffectData(int mgefID, Enchantment enchant)
	int correlateID = StageCorrelationData(mgefID)
	
	int curIndex = currentCorrelatedEnchants.find(enchant)

	if (curIndex >= 0) ;error check
		;shift everything down and delete this entry
		while (currentCorrelatedEnchants[curIndex + 1])
			currentCorrelatedEnchants[curIndex] = currentCorrelatedEnchants[curIndex + 1]
			currentCorrelatedMults[curIndex] = currentCorrelatedMults[curIndex + 1]
			curIndex += 1
		endwhile
		currentCorrelatedEnchants[curIndex] = none
		currentCorrelatedMults[curIndex] = 0.0
		LearnActiveCounts[correlateID] = curIndex
	endif
EndFunction





int Function StageCorrelationData(int mgefID)
	int correlateID

	if (mgefID >= 0)
		correlateID = learnedTypeCodes[mgefID]
	else ;unrecognized effect
		correlateID = Controller.iUNKNOWN
	endif

	GoToState("Correlation" + correlateID)

	return correlateID
EndFunction


Enchantment[] currentCorrelatedEnchants
float[] currentCorrelatedMults


State Correlation0
	Event OnBeginState()
		currentCorrelatedEnchants = LearnAlchemy_ActiveEnchantments
		currentCorrelatedMults = LearnAlchemy_ActiveMults
	EndEvent
EndState

State Correlation1
	Event OnBeginState()
		currentCorrelatedEnchants = LearnAlteration_ActiveEnchantments
		currentCorrelatedMults = LearnAlteration_ActiveMults
	EndEvent
EndState

State Correlation2
	Event OnBeginState()
		currentCorrelatedEnchants = LearnArchery_ActiveEnchantments
		currentCorrelatedMults = LearnArchery_ActiveMults
	EndEvent
EndState

State Correlation3
	Event OnBeginState()
		currentCorrelatedEnchants = LearnBlock_ActiveEnchantments
		currentCorrelatedMults = LearnBlock_ActiveMults
	EndEvent
EndState

State Correlation4
	Event OnBeginState()
		currentCorrelatedEnchants = LearnCarry_ActiveEnchantments
		currentCorrelatedMults = LearnCarry_ActiveMults
	EndEvent
EndState

State Correlation5
	Event OnBeginState()
		currentCorrelatedEnchants = LearnConjuration_ActiveEnchantments
		currentCorrelatedMults = LearnConjuration_ActiveMults
	EndEvent
EndState

State Correlation6
	Event OnBeginState()
		currentCorrelatedEnchants = LearnDestruction_ActiveEnchantments
		currentCorrelatedMults = LearnDestruction_ActiveMults
	EndEvent
EndState

State Correlation7
	Event OnBeginState()
		currentCorrelatedEnchants = LearnHealRate_ActiveEnchantments
		currentCorrelatedMults = LearnHealRate_ActiveMults
	EndEvent
EndState

State Correlation8
	Event OnBeginState()
		currentCorrelatedEnchants = LearnHealth_ActiveEnchantments
		currentCorrelatedMults = LearnHealth_ActiveMults
	EndEvent
EndState

State Correlation9
	Event OnBeginState()
		currentCorrelatedEnchants = LearnHeavyArmor_ActiveEnchantments
		currentCorrelatedMults = LearnHeavyArmor_ActiveMults
	EndEvent
EndState

State Correlation10
	Event OnBeginState()
		currentCorrelatedEnchants = LearnIllusion_ActiveEnchantments
		currentCorrelatedMults = LearnIllusion_ActiveMults
	EndEvent
EndState

State Correlation11
	Event OnBeginState()
		currentCorrelatedEnchants = LearnLightArmor_ActiveEnchantments
		currentCorrelatedMults = LearnLightArmor_ActiveMults
	EndEvent
EndState

State Correlation12
	Event OnBeginState()
		currentCorrelatedEnchants = LearnLockpicking_ActiveEnchantments
		currentCorrelatedMults = LearnLockpicking_ActiveMults
	EndEvent
EndState

State Correlation13
	Event OnBeginState()
		currentCorrelatedEnchants = LearnMagicka_ActiveEnchantments
		currentCorrelatedMults = LearnMagicka_ActiveMults
	EndEvent
EndState

State Correlation14
	Event OnBeginState()
		currentCorrelatedEnchants = LearnMagickaRate_ActiveEnchantments
		currentCorrelatedMults = LearnMagickaRate_ActiveMults
	EndEvent
EndState

State Correlation15
	Event OnBeginState()
		currentCorrelatedEnchants = LearnMuffle_ActiveEnchantments
		currentCorrelatedMults = LearnMuffle_ActiveMults
	EndEvent
EndState

State Correlation16
	Event OnBeginState()
		currentCorrelatedEnchants = LearnOneHanded_ActiveEnchantments
		currentCorrelatedMults = LearnOneHanded_ActiveMults
	EndEvent
EndState

State Correlation17
	Event OnBeginState()
		currentCorrelatedEnchants = LearnPersuasion_ActiveEnchantments
		currentCorrelatedMults = LearnPersuasion_ActiveMults
	EndEvent
EndState

State Correlation18
	Event OnBeginState()
		currentCorrelatedEnchants = LearnPickpocket_ActiveEnchantments
		currentCorrelatedMults = LearnPickpocket_ActiveMults
	EndEvent
EndState

State Correlation19
	Event OnBeginState()
		currentCorrelatedEnchants = LearnResistDisease_ActiveEnchantments
		currentCorrelatedMults = LearnResistDisease_ActiveMults
	EndEvent
EndState

State Correlation20
	Event OnBeginState()
		currentCorrelatedEnchants = LearnResistFire_ActiveEnchantments
		currentCorrelatedMults = LearnResistFire_ActiveMults
	EndEvent
EndState

State Correlation21
	Event OnBeginState()
		currentCorrelatedEnchants = LearnResistFrost_ActiveEnchantments
		currentCorrelatedMults = LearnResistFrost_ActiveMults
	EndEvent
EndState

State Correlation22
	Event OnBeginState()
		currentCorrelatedEnchants = LearnResistMagic_ActiveEnchantments
		currentCorrelatedMults = LearnResistMagic_ActiveMults
	EndEvent
EndState

State Correlation23
	Event OnBeginState()
		currentCorrelatedEnchants = LearnResistPoison_ActiveEnchantments
		currentCorrelatedMults = LearnResistPoison_ActiveMults
	EndEvent
EndState

State Correlation24
	Event OnBeginState()
		currentCorrelatedEnchants = LearnResistShock_ActiveEnchantments
		currentCorrelatedMults = LearnResistShock_ActiveMults
	EndEvent
EndState

State Correlation25
	Event OnBeginState()
		currentCorrelatedEnchants = LearnRestoration_ActiveEnchantments
		currentCorrelatedMults = LearnRestoration_ActiveMults
	EndEvent
EndState

State Correlation26
	Event OnBeginState()
		currentCorrelatedEnchants = LearnSmithing_ActiveEnchantments
		currentCorrelatedMults = LearnSmithing_ActiveMults
	EndEvent
EndState

State Correlation27
	Event OnBeginState()
		currentCorrelatedEnchants = LearnSneak_ActiveEnchantments
		currentCorrelatedMults = LearnSneak_ActiveMults
	EndEvent
EndState

State Correlation28
	Event OnBeginState()
		currentCorrelatedEnchants = LearnSpeed_ActiveEnchantments
		currentCorrelatedMults = LearnSpeed_ActiveMults
	EndEvent
EndState

State Correlation29
	Event OnBeginState()
		currentCorrelatedEnchants = LearnStamina_ActiveEnchantments
		currentCorrelatedMults = LearnStamina_ActiveMults
	EndEvent
EndState

State Correlation30
	Event OnBeginState()
		currentCorrelatedEnchants = LearnStaminaRate_ActiveEnchantments
		currentCorrelatedMults = LearnStaminaRate_ActiveMults
	EndEvent
EndState

State Correlation31
	Event OnBeginState()
		currentCorrelatedEnchants = LearnTwoHanded_ActiveEnchantments
		currentCorrelatedMults = LearnTwoHanded_ActiveMults
	EndEvent
EndState

State Correlation32
	Event OnBeginState()
		currentCorrelatedEnchants = LearnUnarmed_ActiveEnchantments
		currentCorrelatedMults = LearnUnarmed_ActiveMults
	EndEvent
EndState

State Correlation33
	Event OnBeginState()
		currentCorrelatedEnchants = LearnWaterbreathing_ActiveEnchantments
		currentCorrelatedMults = LearnWaterbreathing_ActiveMults
	EndEvent
EndState

State Correlation34
	Event OnBeginState()
		currentCorrelatedEnchants = LearnUnknown_ActiveEnchantments
		currentCorrelatedMults = LearnUnknown_ActiveMults
	EndEvent
EndState




Function CorrelationArraySetup(EA_Learn_Controller __controller)
	Controller = __controller

	LearnActiveCounts = Controller.LearnActiveCounts

	LearnAlchemy_ActiveEnchantments        = Controller.LearnAlchemy_ActiveEnchantments
	LearnAlteration_ActiveEnchantments     = Controller.LearnAlteration_ActiveEnchantments
	LearnArchery_ActiveEnchantments        = Controller.LearnArchery_ActiveEnchantments
	LearnBlock_ActiveEnchantments          = Controller.LearnBlock_ActiveEnchantments
	LearnCarry_ActiveEnchantments          = Controller.LearnCarry_ActiveEnchantments
	LearnConjuration_ActiveEnchantments    = Controller.LearnConjuration_ActiveEnchantments
	LearnDestruction_ActiveEnchantments    = Controller.LearnDestruction_ActiveEnchantments
	LearnHealRate_ActiveEnchantments       = Controller.LearnHealRate_ActiveEnchantments
	LearnHealth_ActiveEnchantments         = Controller.LearnHealth_ActiveEnchantments
	LearnHeavyArmor_ActiveEnchantments     = Controller.LearnHeavyArmor_ActiveEnchantments
	LearnIllusion_ActiveEnchantments       = Controller.LearnIllusion_ActiveEnchantments
	LearnLightArmor_ActiveEnchantments     = Controller.LearnLightArmor_ActiveEnchantments
	LearnLockpicking_ActiveEnchantments    = Controller.LearnLockpicking_ActiveEnchantments
	LearnMagicka_ActiveEnchantments        = Controller.LearnMagicka_ActiveEnchantments
	LearnMagickaRate_ActiveEnchantments    = Controller.LearnMagickaRate_ActiveEnchantments
	LearnMuffle_ActiveEnchantments         = Controller.LearnMuffle_ActiveEnchantments
	LearnOneHanded_ActiveEnchantments      = Controller.LearnOneHanded_ActiveEnchantments
	LearnPersuasion_ActiveEnchantments     = Controller.LearnPersuasion_ActiveEnchantments
	LearnPickpocket_ActiveEnchantments     = Controller.LearnPickpocket_ActiveEnchantments
	LearnResistDisease_ActiveEnchantments  = Controller.LearnResistDisease_ActiveEnchantments
	LearnResistFire_ActiveEnchantments     = Controller.LearnResistFire_ActiveEnchantments
	LearnResistFrost_ActiveEnchantments    = Controller.LearnResistFrost_ActiveEnchantments
	LearnResistMagic_ActiveEnchantments    = Controller.LearnResistMagic_ActiveEnchantments
	LearnResistPoison_ActiveEnchantments   = Controller.LearnResistPoison_ActiveEnchantments
	LearnResistShock_ActiveEnchantments    = Controller.LearnResistShock_ActiveEnchantments
	LearnRestoration_ActiveEnchantments    = Controller.LearnRestoration_ActiveEnchantments
	LearnSmithing_ActiveEnchantments       = Controller.LearnSmithing_ActiveEnchantments
	LearnSneak_ActiveEnchantments          = Controller.LearnSneak_ActiveEnchantments
	LearnSpeed_ActiveEnchantments          = Controller.LearnSpeed_ActiveEnchantments
	LearnStamina_ActiveEnchantments        = Controller.LearnStamina_ActiveEnchantments
	LearnStaminaRate_ActiveEnchantments    = Controller.LearnStaminaRate_ActiveEnchantments
	LearnTwoHanded_ActiveEnchantments      = Controller.LearnTwoHanded_ActiveEnchantments
	LearnUnarmed_ActiveEnchantments        = Controller.LearnUnarmed_ActiveEnchantments
	LearnWaterbreathing_ActiveEnchantments = Controller.LearnWaterbreathing_ActiveEnchantments
	LearnUnknown_ActiveEnchantments        = Controller.LearnUnknown_ActiveEnchantments

	LearnAlchemy_ActiveMults        = Controller.LearnAlchemy_ActiveMults
	LearnAlteration_ActiveMults     = Controller.LearnAlteration_ActiveMults
	LearnArchery_ActiveMults        = Controller.LearnArchery_ActiveMults
	LearnBlock_ActiveMults          = Controller.LearnBlock_ActiveMults
	LearnCarry_ActiveMults          = Controller.LearnCarry_ActiveMults
	LearnConjuration_ActiveMults    = Controller.LearnConjuration_ActiveMults
	LearnDestruction_ActiveMults    = Controller.LearnDestruction_ActiveMults
	LearnHealRate_ActiveMults       = Controller.LearnHealRate_ActiveMults
	LearnHealth_ActiveMults         = Controller.LearnHealth_ActiveMults
	LearnHeavyArmor_ActiveMults     = Controller.LearnHeavyArmor_ActiveMults
	LearnIllusion_ActiveMults       = Controller.LearnIllusion_ActiveMults
	LearnLightArmor_ActiveMults     = Controller.LearnLightArmor_ActiveMults
	LearnLockpicking_ActiveMults    = Controller.LearnLockpicking_ActiveMults
	LearnMagicka_ActiveMults        = Controller.LearnMagicka_ActiveMults
	LearnMagickaRate_ActiveMults    = Controller.LearnMagickaRate_ActiveMults
	LearnMuffle_ActiveMults         = Controller.LearnMuffle_ActiveMults
	LearnOneHanded_ActiveMults      = Controller.LearnOneHanded_ActiveMults
	LearnPersuasion_ActiveMults     = Controller.LearnPersuasion_ActiveMults
	LearnPickpocket_ActiveMults     = Controller.LearnPickpocket_ActiveMults
	LearnResistDisease_ActiveMults  = Controller.LearnResistDisease_ActiveMults
	LearnResistFire_ActiveMults     = Controller.LearnResistFire_ActiveMults
	LearnResistFrost_ActiveMults    = Controller.LearnResistFrost_ActiveMults
	LearnResistMagic_ActiveMults    = Controller.LearnResistMagic_ActiveMults
	LearnResistPoison_ActiveMults   = Controller.LearnResistPoison_ActiveMults
	LearnResistShock_ActiveMults    = Controller.LearnResistShock_ActiveMults
	LearnRestoration_ActiveMults    = Controller.LearnRestoration_ActiveMults
	LearnSmithing_ActiveMults       = Controller.LearnSmithing_ActiveMults
	LearnSneak_ActiveMults          = Controller.LearnSneak_ActiveMults
	LearnSpeed_ActiveMults          = Controller.LearnSpeed_ActiveMults
	LearnStamina_ActiveMults        = Controller.LearnStamina_ActiveMults
	LearnStaminaRate_ActiveMults    = Controller.LearnStaminaRate_ActiveMults
	LearnTwoHanded_ActiveMults      = Controller.LearnTwoHanded_ActiveMults
	LearnUnarmed_ActiveMults        = Controller.LearnUnarmed_ActiveMults
	LearnWaterbreathing_ActiveMults = Controller.LearnWaterbreathing_ActiveMults
	LearnUnknown_ActiveMults        = Controller.LearnUnknown_ActiveMults
EndFunction


int[]  property  LearnActiveCounts  auto hidden ;count for how many enchants/mults are in each of the 33 arrays below

Enchantment[]  property  LearnAlchemy_ActiveEnchantments         auto hidden
Enchantment[]  property  LearnAlteration_ActiveEnchantments      auto hidden
Enchantment[]  property  LearnArchery_ActiveEnchantments         auto hidden
Enchantment[]  property  LearnBlock_ActiveEnchantments           auto hidden
Enchantment[]  property  LearnCarry_ActiveEnchantments           auto hidden
Enchantment[]  property  LearnConjuration_ActiveEnchantments     auto hidden
Enchantment[]  property  LearnDestruction_ActiveEnchantments     auto hidden
Enchantment[]  property  LearnHealRate_ActiveEnchantments        auto hidden
Enchantment[]  property  LearnHealth_ActiveEnchantments          auto hidden
Enchantment[]  property  LearnHeavyArmor_ActiveEnchantments      auto hidden
Enchantment[]  property  LearnIllusion_ActiveEnchantments        auto hidden
Enchantment[]  property  LearnLightArmor_ActiveEnchantments      auto hidden ;33 arrays
Enchantment[]  property  LearnLockpicking_ActiveEnchantments     auto hidden
Enchantment[]  property  LearnMagicka_ActiveEnchantments         auto hidden
Enchantment[]  property  LearnMagickaRate_ActiveEnchantments     auto hidden
Enchantment[]  property  LearnMuffle_ActiveEnchantments          auto hidden
Enchantment[]  property  LearnOneHanded_ActiveEnchantments       auto hidden
Enchantment[]  property  LearnPersuasion_ActiveEnchantments      auto hidden
Enchantment[]  property  LearnPickpocket_ActiveEnchantments      auto hidden
Enchantment[]  property  LearnResistDisease_ActiveEnchantments   auto hidden
Enchantment[]  property  LearnResistFire_ActiveEnchantments      auto hidden
Enchantment[]  property  LearnResistFrost_ActiveEnchantments     auto hidden
Enchantment[]  property  LearnResistMagic_ActiveEnchantments     auto hidden
Enchantment[]  property  LearnResistPoison_ActiveEnchantments    auto hidden
Enchantment[]  property  LearnResistShock_ActiveEnchantments     auto hidden
Enchantment[]  property  LearnRestoration_ActiveEnchantments     auto hidden
Enchantment[]  property  LearnSmithing_ActiveEnchantments        auto hidden
Enchantment[]  property  LearnSneak_ActiveEnchantments           auto hidden
Enchantment[]  property  LearnSpeed_ActiveEnchantments           auto hidden
Enchantment[]  property  LearnStamina_ActiveEnchantments         auto hidden
Enchantment[]  property  LearnStaminaRate_ActiveEnchantments     auto hidden
Enchantment[]  property  LearnTwoHanded_ActiveEnchantments       auto hidden
Enchantment[]  property  LearnUnarmed_ActiveEnchantments         auto hidden
Enchantment[]  property  LearnWaterbreathing_ActiveEnchantments  auto hidden
Enchantment[]  property  LearnUnknown_ActiveEnchantments         auto hidden

float[]  property  LearnAlchemy_ActiveMults         auto hidden
float[]  property  LearnAlteration_ActiveMults      auto hidden
float[]  property  LearnArchery_ActiveMults         auto hidden
float[]  property  LearnBlock_ActiveMults           auto hidden
float[]  property  LearnCarry_ActiveMults           auto hidden
float[]  property  LearnConjuration_ActiveMults     auto hidden
float[]  property  LearnDestruction_ActiveMults     auto hidden
float[]  property  LearnHealRate_ActiveMults        auto hidden
float[]  property  LearnHealth_ActiveMults          auto hidden
float[]  property  LearnHeavyArmor_ActiveMults      auto hidden
float[]  property  LearnIllusion_ActiveMults        auto hidden
float[]  property  LearnLightArmor_ActiveMults      auto hidden
float[]  property  LearnLockpicking_ActiveMults     auto hidden
float[]  property  LearnMagicka_ActiveMults         auto hidden
float[]  property  LearnMagickaRate_ActiveMults     auto hidden
float[]  property  LearnMuffle_ActiveMults          auto hidden
float[]  property  LearnOneHanded_ActiveMults       auto hidden
float[]  property  LearnPersuasion_ActiveMults      auto hidden
float[]  property  LearnPickpocket_ActiveMults      auto hidden
float[]  property  LearnResistDisease_ActiveMults   auto hidden
float[]  property  LearnResistFire_ActiveMults      auto hidden
float[]  property  LearnResistFrost_ActiveMults     auto hidden
float[]  property  LearnResistMagic_ActiveMults     auto hidden
float[]  property  LearnResistPoison_ActiveMults    auto hidden
float[]  property  LearnResistShock_ActiveMults     auto hidden
float[]  property  LearnRestoration_ActiveMults     auto hidden
float[]  property  LearnSmithing_ActiveMults        auto hidden
float[]  property  LearnSneak_ActiveMults           auto hidden
float[]  property  LearnSpeed_ActiveMults           auto hidden
float[]  property  LearnStamina_ActiveMults         auto hidden
float[]  property  LearnStaminaRate_ActiveMults     auto hidden
float[]  property  LearnTwoHanded_ActiveMults       auto hidden
float[]  property  LearnUnarmed_ActiveMults         auto hidden
float[]  property  LearnWaterbreathing_ActiveMults  auto hidden
float[]  property  LearnUnknown_ActiveMults         auto hidden