Scriptname EA_Learn_Controller extends ReferenceAlias conditional
{central control script for learn events and adding learn experience}


Actor                      property  playerRef  auto
Quest                      property  MQ101      auto
EA_Learn_Delegator         property  Delegator  auto
EA_Learn_MaintenanceScript property  Maintainer  auto


;constants
int  property  ALTERATION_SCHOOL  = 0  autoreadonly
int  property  CONJURATION_SCHOOL = 1  autoreadonly
int  property  DESTRUCTION_SCHOOL = 2  autoreadonly
int  property  ILLUSION_SCHOOL    = 3  autoreadonly
int  property  RESTORATION_SCHOOL = 4  autoreadonly

int  property  UNARMED_WEAPTYPE     = 0  autoreadonly
int  property  ONEHANDED_WEAPTYPE   = 1  autoreadonly
int  property  TWOHANDED_WEAPTYPE   = 2  autoreadonly
int  property  BOW_WEAPTYPE         = 3  autoreadonly

;experience tracker indices
int  property  iALCHEMY        = 0   autoreadonly
int  property  iALTERATION     = 1   autoreadonly
int  property  iARCHERY        = 2   autoreadonly
int  property  iBLOCK          = 3   autoreadonly
int  property  iCARRY          = 4   autoreadonly
int  property  iCONJURATION    = 5   autoreadonly
int  property  iDESTRUCTION    = 6   autoreadonly
int  property  iHEALRATE       = 7   autoreadonly
int  property  iHEALTH         = 8   autoreadonly
int  property  iHEAVYARMOR     = 9   autoreadonly
int  property  iILLUSION       = 10  autoreadonly
int  property  iLIGHTARMOR     = 11  autoreadonly
int  property  iLOCKPICKING    = 12  autoreadonly
int  property  iMAGICKA        = 13  autoreadonly
int  property  iMAGICKARATE    = 14  autoreadonly
int  property  iMUFFLE         = 15  autoreadonly
int  property  iONEHANDED      = 16  autoreadonly
int  property  iPERSUASION     = 17  autoreadonly
int  property  iPICKPOCKET     = 18  autoreadonly
int  property  iRESISTDISEASE  = 19  autoreadonly
int  property  iRESISTFIRE     = 20  autoreadonly
int  property  iRESISTFROST    = 21  autoreadonly
int  property  iRESISTMAGIC    = 22  autoreadonly
int  property  iRESISTPOISON   = 23  autoreadonly
int  property  iRESISTSHOCK    = 24  autoreadonly
int  property  iRESTORATION    = 25  autoreadonly
int  property  iSMITHING       = 26  autoreadonly
int  property  iSNEAK          = 27  autoreadonly
int  property  iSPEED          = 28  autoreadonly
int  property  iSTAMINA        = 29  autoreadonly
int  property  iSTAMINARATE    = 30  autoreadonly
int  property  iTWOHANDED      = 31  autoreadonly
int  property  iUNARMED        = 32  autoreadonly
int  property  iWATERBREATHING = 33  autoreadonly
int  property  iUNKNOWN        = 34  autoreadonly
int  property  iWEAPONENCHANTS = 35  autoreadonly



;Defensive Enchantment Experience Trackers (i.e. Armor Enchantments)
Enchantment[]  property  defensiveEnchantments              auto ;fill in first 33 with enchantments at indexes based on constants above
float[]        property  defensiveEnchantments_xp           auto hidden
int[]          property  defensiveEnchantments_lvl          auto hidden ;1 through 20 inclusive
int            property  defensiveEnchantmentsCurrentIndex  auto hidden

;Offensive Enchantment Experience Trackers (i.e. Weapon Enchantments)
Enchantment[]  property  offensiveEnchantments              auto hidden
float[]        property  offensiveEnchantments_xp           auto hidden
int[]          property  offensiveEnchantments_lvl          auto hidden ;1 through 20 inclusive
int            property  offensiveEnchantmentsCurrentIndex  auto hidden

;learn scaling settings, determine the speed of learning
float[]  property  kExperienceMults  auto hidden

;Thresholds that must be reached to get to each new perk/experience level
float[]        property  learnLevelThresholds               auto hidden ;index == level



Function SetDefaultExperienceMultipliers()
	kExperienceMults                  = new float[36]
	kExperienceMults[iALCHEMY]        = 5.0   ; ~2000 potions mixed/ingredients harvested
	kExperienceMults[iALTERATION]     = 8.0   ; ~1250+ casts
	kExperienceMults[iARCHERY]        = 8.0   ; ~1250 kills
	kExperienceMults[iBLOCK]          = 16.0  ; ~625 blocks
	kExperienceMults[iCARRY]          = 4.0   ; ~42 hours worn
	kExperienceMults[iCONJURATION]    = 8.0   ; ~1250+ casts
	kExperienceMults[iDESTRUCTION]    = 3.333 ; ~3000+ casts
	kExperienceMults[iHEALRATE]       = 30.0  ; ~333 times: drop below 35% health, then heal back to full health
	kExperienceMults[iHEALTH]         = 8.0   ; ~21 min under 50% health
	kExperienceMults[iHEAVYARMOR]     = 10.0  ; ~1000-4000+ times hit by weapon or bash (10 sec detection delay) [scaled back if less than 4 heavy armor items worn]
	kExperienceMults[iILLUSION]       = 8.0   ; ~1250+ casts
	kExperienceMults[iLIGHTARMOR]     = 10.0  ; ~1000-4000+ times hit by weapon or bash (10 sec detection delay) [scaled back if less than 4 light armor items worn]
	kExperienceMults[iLOCKPICKING]    = 80.0  ; ~125 locks picked
	kExperienceMults[iMAGICKA]        = 8.0   ; ~1250 spell casts (15 sec detection delay)
	kExperienceMults[iMAGICKARATE]    = 4.0   ; ~2500 times: drop below 20% magicka then heal back to full magicka
	kExperienceMults[iMUFFLE]         = 2.0   ; ~250 points: 1 point per 20 min worn, 1 point per sneak attack/lock picked
	kExperienceMults[iONEHANDED]      = 7.0   ; ~1430 kills
	kExperienceMults[iPERSUASION]     = 3.5   ; ~2860 'points' from barters and other speech successes
	kExperienceMults[iPICKPOCKET]     = 4.0   ; ~200 pockets picked
	kExperienceMults[iRESISTDISEASE]  = 25.0  ; ~400 times hit by a disease-carrying creature (10 sec detection delay)
	kExperienceMults[iRESISTFIRE]     = 30.0  ; ~333 times hit by fire damage (15 second detection delay)
	kExperienceMults[iRESISTFROST]    = 30.0  ; ~333 times hit by frost damage (15 second detection delay)
	kExperienceMults[iRESISTMAGIC]    = 15.0  ; ~666 times hit by hostile magic effect (15 second detection delay)
	kExperienceMults[iRESISTPOISON]   = 20.0  ; ~500 points: 1 point per hit by poisonous-type creature (10 sec detection delay), 15 points when hit by poison dart trap or poison bloom
	kExperienceMults[iRESISTSHOCK]    = 40.0  ; ~250 times hit by shock damage (15 second detection delay)
	kExperienceMults[iRESTORATION]    = 4.0   ; ~2500+ casts
	kExperienceMults[iSMITHING]       = 9.0   ; ~1111 points: 1 point for crafting item (but diminishing returns for repetitive items crafted)
	kExperienceMults[iSNEAK]          = 3.333 ; ~3000 points: diminishing returns while sneaking, reset when sneaking near a hostile actor. Bad deeds give 6 points and also reset diminishing returns.
	kExperienceMults[iSPEED]          = 1.5   ; ~40 hours, assuming player sprints for about 100 seconds each hour
	kExperienceMults[iSTAMINA]        = 4.0   ; ~2500 times: drop to low stamina then heal back to full
	kExperienceMults[iSTAMINARATE]    = 4.0   ; ~2500 times: drop to low stamina then heal back to full          DOUBLE CHECK STAMINA SETUP IN CK (dont know exact %s from script)
	kExperienceMults[iTWOHANDED]      = 8.0   ; ~1250 kills
	kExperienceMults[iUNARMED]        = 20.0  ; ~500 kills
	kExperienceMults[iWATERBREATHING] = 1.0   ; ~167 minutes underwater
	kExperienceMults[iUNKNOWN]        = 4.0   ; ~42 hours worn
	kExperienceMults[iWEAPONENCHANTS] = 3.0   ; ~3333+ hits (this one MUST BE SET/reset MANUALLY using EA_Extender.SetOffensiveEnchantmentLearnExperienceMult)
EndFunction


Event OnInit()
	debugSetup() ;DEBUG STRINGS
	ExperienceArrayInit()
	CorrelationArrayInit()
	registerForSingleUpdate(0.1)
EndEvent

Event OnPlayerLoadGame()
	RegisterForModEvent(EA_Extender.GetLearnEventName(), "OnLearnOffensiveEnchantment")

	SetDefaultExperienceMultipliers() ;set default mults
	EA_Extender.ApplyIniMultModifiers(kExperienceMults) ;apply ini adjustment to mults
EndEvent

Auto State InitState
	Event OnUpdate()
		GoToState("") ;exit InitState
		ExperienceArrayPostInit()
		CorrelationArrayPostInit()
		OnPlayerLoadGame()
		; RegisterForSingleUpdate(30.0)
	EndEvent
EndState

; Event OnUpdate()
; 	;apparently, gametime registrations dont work until player gains controls
; 	if (MQ101.GetCurrentStageID() >= 240)
; 		registerForSingleUpdateGameTime(1.0)
; 	else
; 		registerForSingleUpdate(300.0)
; 	endif
; EndEvent

; Event OnUpdateGameTime()
; 	; awardIdleExperience() ;give every 12 hours just for wearing stuff (or having equipped in the case of weapon)
; 	registerForSingleUpdateGameTime(12.0)
; EndEvent

; Function awardIdleExperience()
; 	;;;;;;;;;;;;;;;;;;;;;;;;;; I may just depricate this, not really necessary...
; EndFunction




;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  CORE LEARN HANDLERS  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;Event is called from internal plugin, which keeps track of weapon enchantment experience
;and sends this event whenever a new learn experience threshold is passed
Event OnLearnOffensiveEnchantment(string eventName, string nullArg, float thresholdExperienceTotalPassed, Form learnedEnchantment)
	Enchantment e = learnedEnchantment as Enchantment ;this will be the BASE enchantment, sent from internal plugin
	int thisIndex = offensiveEnchantments.Find(e)
	if (thisIndex < 0)
		if (offensiveEnchantmentsCurrentIndex >= 128)
			debug.trace("Enchanting Awakened: Error - offensiveEnchantments learn overflow [enchantment: " + e.getFormID() + "]")
			return
		endif
		thisIndex = offensiveEnchantmentsCurrentIndex
		offensiveEnchantmentsCurrentIndex += 1
		offensiveEnchantments[thisIndex] = e
	endif
	offensiveEnchantments_xp[thisIndex] = thresholdExperienceTotalPassed

	;determine what new experience level has been reached
	int oldLevel = offensiveEnchantments_lvl[thisIndex]
	int newLevel = learnLevelThresholds.find(thresholdExperienceTotalPassed)
	if (newLevel <= 0)
		debug.trace("Enchanting Awakened: Error - invalid threshold passed to OnLearnOffensiveEnchantment event [" + thresholdExperienceTotalPassed + "]")
		return
	endif

	if (newLevel != oldLevel)
		offensiveEnchantments_lvl[thisIndex] = newLevel
		AdjustEnchantmentLearnLevel(e, oldLevel, newLevel)
	endif
EndEvent

;Similar to OnLearnOffensiveEnchantment event above, except instead of being called from internal plugin, this
;is called from the specific learn functions below that handle each armor enchantment magic effect type.
Function LearnDefensiveEnchantments(int learnID, float xp, Enchantment[] enchantsToLearn, float[] mults)

	debug.trace("Enchanting Awakened:   --   learn defensive enchantment event called:\n                       --\n")
	debug.trace("                       --        mgefName     = " + debugStrings[learnID])
	debug.trace("                       --        enchantCount = " + LearnActiveCounts[learnID])
	debug.trace("                       --        xp           = " + (xp * kExperienceMults[learnID]))

	int enchantCount = LearnActiveCounts[learnID]
	while (enchantCount)
		enchantCount -= 1
		int index = defensiveEnchantments.find(enchantsToLearn[enchantCount])
		if (index < 0)
			if (defensiveEnchantmentsCurrentIndex < 128)
				defensiveEnchantments[defensiveEnchantmentsCurrentIndex] = enchantsToLearn[enchantCount]
				index = defensiveEnchantmentsCurrentIndex
				defensiveEnchantmentsCurrentIndex += 1
			else
				debug.trace("Enchanting Awakened: Error - defensiveEnchantments learn slot overflow [enchantment: " \
				  + enchantsToLearn[enchantCount].getName() + " formid: " + enchantsToLearn[enchantCount].getFormID() + " idx: " + enchantCount + "]")
			endif
		endif

		xp = xp * kExperienceMults[learnID] * mults[enchantCount]
		defensiveEnchantments_xp[index] = defensiveEnchantments_xp[index] + xp
		int currentLevel = defensiveEnchantments_lvl[index]
		int nextLevel = currentLevel + 1

		if (defensiveEnchantments_xp[index] >= learnLevelThresholds[nextLevel])
			while ((defensiveEnchantments_xp[index] >= learnLevelThresholds[nextLevel]) && (currentLevel < 20))
				currentLevel = nextLevel
				nextLevel += 1
			endWhile

			if (currentLevel > defensiveEnchantments_lvl[index])
				AdjustEnchantmentLearnLevel(enchantsToLearn[enchantCount], oldLevel = defensiveEnchantments_lvl[index], newLevel = currentLevel)
				defensiveEnchantments_lvl[index] = currentLevel
			endif
		endif
		;Would also be a good idea to remove any enchantments that have reached level 20 here so they dont
		;keep taking up processing time in this function and can simply be ignored.
	endWhile
EndFunction


;;;;;;;;;;;;;;;;;;;  LEARN RELAY FUNCS, CALLED FROM INDIVIDUAL LEARN ABILITIES  ;;;;;;;;;;;;;;;;;;;;;;;;;;

Function LearnAlchemy		(float modifier = 1.0)
								LearnDefensiveEnchantments(iALCHEMY, modifier, LearnAlchemy_ActiveEnchantments, LearnAlchemy_ActiveMults)
							EndFunction
Function LearnAlteration	(float modifier = 1.0)
								LearnDefensiveEnchantments(iALTERATION, modifier, LearnAlteration_ActiveEnchantments, LearnAlteration_ActiveMults)
							EndFunction
Function LearnArchery		(float modifier = 1.0)
								LearnDefensiveEnchantments(iARCHERY, modifier, LearnArchery_ActiveEnchantments, LearnArchery_ActiveMults)
							EndFunction
Function LearnBlock			(float modifier = 1.0)
								LearnDefensiveEnchantments(iBLOCK, modifier, LearnBlock_ActiveEnchantments, LearnBlock_ActiveMults)
							EndFunction
Function LearnCarry			(float modifier = 1.0)
								LearnDefensiveEnchantments(iCARRY, modifier, LearnCarry_ActiveEnchantments, LearnCarry_ActiveMults)
							EndFunction
Function LearnConjuration	(float modifier = 1.0)
								LearnDefensiveEnchantments(iCONJURATION, modifier, LearnConjuration_ActiveEnchantments, LearnConjuration_ActiveMults)
							EndFunction
Function LearnDestruction	(float modifier = 1.0)
								LearnDefensiveEnchantments(iDESTRUCTION, modifier, LearnDestruction_ActiveEnchantments, LearnDestruction_ActiveMults)
							EndFunction
Function LearnHealRate 		(float modifier = 1.0)
								LearnDefensiveEnchantments(iHEALRATE, modifier, LearnHealRate_ActiveEnchantments, LearnHealRate_ActiveMults)
							EndFunction
Function LearnHealth		(float modifier = 1.0)
								if (modifier > 10.0)
									modifier = Math.pow(modifier - 10.0, 0.4) + 10.0 ;diminish returns after 10 seconds below 50% health
								endif
								LearnDefensiveEnchantments(iHEALTH, modifier, LearnHealth_ActiveEnchantments, LearnHealth_ActiveMults)
							EndFunction
Function LearnHeavyArmor	(float modifier = 1.0)
								;playerHeavyArmorWornCount updated from EA_Learn_FortifyHeavyArmor each equip event
								modifier *= (playerHeavyArmorWornCount / 4.0)
								LearnDefensiveEnchantments(iHEAVYARMOR, modifier, LearnHeavyArmor_ActiveEnchantments, LearnHeavyArmor_ActiveMults)
							EndFunction
Function LearnIllusion		(float modifier = 1.0)
								LearnDefensiveEnchantments(iILLUSION, modifier, LearnIllusion_ActiveEnchantments, LearnIllusion_ActiveMults)
							EndFunction
Function LearnLightArmor	(float modifier = 1.0)
								;playerHeavyArmorWornCount updated from EA_Learn_FortifyLightArmor each equip event
								modifier *= (playerLightArmorWornCount / 4.0)
								LearnDefensiveEnchantments(iLIGHTARMOR, modifier, LearnLightArmor_ActiveEnchantments, LearnLightArmor_ActiveMults)
							EndFunction
							;---------------------------LearnLockpicking------------------|
							Cell lastCell							   ; static variables |
							float lockpickingModulator = 1.0		   ;                  |
Function LearnLockpicking	(float modifier = 1.0)
								Cell thisCell = playerRef.GetParentCell()
								if (thisCell == lastCell) ;limit gain from something like thieves guild practice locks (to the integral of 0.975^x)
									lockpickingModulator *= 0.975
								else
									lastCell = thisCell
									lockpickingModulator = 1.0
								endif
								modifier *= lockpickingModulator
								LearnDefensiveEnchantments(iLOCKPICKING, modifier, LearnLockpicking_ActiveEnchantments, LearnLockpicking_ActiveMults)
							EndFunction
Function LearnMagicka		(float modifier = 1.0)
								LearnDefensiveEnchantments(iMAGICKA, modifier, LearnMagicka_ActiveEnchantments, LearnMagicka_ActiveMults)
							EndFunction
Function LearnMagickaRate	(float modifier = 1.0)
								LearnDefensiveEnchantments(iMAGICKARATE, modifier, LearnMagickaRate_ActiveEnchantments, LearnMagickaRate_ActiveMults)
							EndFunction
Function LearnMuffle		(float modifier = 1.0)
								LearnDefensiveEnchantments(iMUFFLE, modifier, LearnMuffle_ActiveEnchantments, LearnMuffle_ActiveMults)
							EndFunction
Function LearnOneHanded		(float modifier = 1.0)
								LearnDefensiveEnchantments(iONEHANDED, modifier, LearnOneHanded_ActiveEnchantments, LearnOneHanded_ActiveMults)
							EndFunction
Function LearnPersuasion	(float modifier = 1.0)
								LearnDefensiveEnchantments(iPERSUASION, modifier, LearnPersuasion_ActiveEnchantments, LearnPersuasion_ActiveMults)
							EndFunction
Function LearnPickpocket	(float modifier = 1.0)
								LearnDefensiveEnchantments(iPICKPOCKET, modifier, LearnPickpocket_ActiveEnchantments, LearnPickpocket_ActiveMults)
							EndFunction
Function LearnResistDisease	(float modifier = 1.0)
								LearnDefensiveEnchantments(iRESISTDISEASE, modifier, LearnResistDisease_ActiveEnchantments, LearnResistDisease_ActiveMults)
							EndFunction
Function LearnResistFire	(float modifier = 1.0)
								LearnDefensiveEnchantments(iRESISTFIRE, modifier, LearnResistFire_ActiveEnchantments, LearnResistFire_ActiveMults)
							EndFunction
Function LearnResistFrost	(float modifier = 1.0)
								LearnDefensiveEnchantments(iRESISTFROST, modifier, LearnResistFrost_ActiveEnchantments, LearnResistFrost_ActiveMults)
							EndFunction
Function LearnResistMagic	(float modifier = 1.0)
								LearnDefensiveEnchantments(iRESISTMAGIC, modifier, LearnResistMagic_ActiveEnchantments, LearnResistMagic_ActiveMults)
							EndFunction
Function LearnResistPoison	(float modifier = 1.0)
								LearnDefensiveEnchantments(iRESISTPOISON, modifier, LearnResistPoison_ActiveEnchantments, LearnResistPoison_ActiveMults)
							EndFunction
Function LearnResistShock	(float modifier = 1.0)
								LearnDefensiveEnchantments(iRESISTSHOCK, modifier, LearnResistShock_ActiveEnchantments, LearnResistShock_ActiveMults)
							EndFunction
Function LearnRestoration	(float modifier = 1.0)
								LearnDefensiveEnchantments(iRESTORATION, modifier, LearnRestoration_ActiveEnchantments, LearnRestoration_ActiveMults)
							EndFunction
Function LearnSmithing		(float modifier = 1.0)
								LearnDefensiveEnchantments(iSMITHING, modifier, LearnSmithing_ActiveEnchantments, LearnSmithing_ActiveMults)
							EndFunction
							;---------------------------------LearnSneak------------------|
							float sneakModulator = 1.0                 ; static variables |
Function LearnSneak			(float modifier = 1.0, bool idling = false)
								if (idling)
									modifier *= sneakModulator
									sneakModulator *= 0.95 ;limits idle experience gain to the integral of (0.95^x)
								else
									sneakModulator = 1.0
								endif
								LearnDefensiveEnchantments(iSNEAK, modifier, LearnSneak_ActiveEnchantments, LearnSneak_ActiveMults)
							EndFunction
Function LearnSpeed			(float modifier = 1.0)
								LearnDefensiveEnchantments(iSPEED, modifier, LearnSpeed_ActiveEnchantments, LearnSpeed_ActiveMults)
							EndFunction
Function LearnStamina		(bool learnStamina, bool learnStaminaRate, float modifier = 1.0)
								if (learnStamina)
									LearnDefensiveEnchantments(iSTAMINA, modifier, LearnStamina_ActiveEnchantments, LearnStamina_ActiveMults)
								endif
								if (learnStaminaRate)
									LearnDefensiveEnchantments(iSTAMINARATE, modifier, LearnStaminaRate_ActiveEnchantments, LearnStaminaRate_ActiveMults)
								endif
							EndFunction
Function LearnTwoHanded		(float modifier = 1.0)
								LearnDefensiveEnchantments(iTWOHANDED, modifier, LearnTwoHanded_ActiveEnchantments, LearnTwoHanded_ActiveMults)
							EndFunction
Function LearnUnarmed		(float modifier = 1.0)
								LearnDefensiveEnchantments(iUNARMED, modifier, LearnUnarmed_ActiveEnchantments, LearnUnarmed_ActiveMults)
							EndFunction
Function LearnWaterbreathing(float modifier = 1.0)
								LearnDefensiveEnchantments(iWATERBREATHING, modifier, LearnWaterbreathing_ActiveEnchantments, LearnWaterbreathing_ActiveMults)
							EndFunction
Function LearnUnknownEffect	(float modifier = 1.0)
								LearnDefensiveEnchantments(iUNKNOWN, modifier, LearnUnknown_ActiveEnchantments, LearnUnknown_ActiveMults)
							EndFunction



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  MAGIC LEARN SWITCHBOARD  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

float alterationModulator  = 1.0
float conjurationModulator = 1.0
float destructionModulator = 1.0
float illusionModulator    = 1.0
float restorationModulator = 1.0

Form lastAlterationSpell
Form lastConjurationSpell
Form lastIllusionSpell

Function LearnMagic(int magicSchool, Form castedSpell)

	if (magicSchool == DESTRUCTION_SCHOOL)
		if (playerRef.isInCombat())
			destructionModulator = 1.0
		else
			destructionModulator *= 0.8
		endif
		LearnDestruction(destructionModulator)

	elseif (magicSchool == RESTORATION_SCHOOL)
		if ((playerRef.GetActorValuePercentage("Health") <= 0.96) || playerRef.isInCombat())
			restorationModulator = 1.0
		else
			restorationModulator *= 0.6
		endif
		LearnRestoration(restorationModulator)

	elseif (magicSchool == ALTERATION_SCHOOL)
		if (castedSpell != lastAlterationSpell)
			alterationModulator = 1.0
			lastAlterationSpell = castedSpell
		elseif (playerRef.isInCombat())
			alterationModulator = 1.0
		else
			alterationModulator *= 0.9
		endif
		LearnAlteration(alterationModulator)

	elseif (magicSchool == CONJURATION_SCHOOL)
		if (castedSpell != lastConjurationSpell)
			conjurationModulator = 1.0
			lastConjurationSpell = castedSpell
		elseif (playerRef.isInCombat())
			conjurationModulator = 1.0
		else
			conjurationModulator *= 0.9
		endif
		LearnConjuration(conjurationModulator)

	elseif (magicSchool == ILLUSION_SCHOOL)
		if (castedSpell != lastIllusionSpell)
			illusionModulator = 1.0
			lastIllusionSpell = castedSpell
		elseif (playerRef.isInCombat())
			illusionModulator = 1.0
		else
			illusionModulator *= 0.9
		endif
		LearnIllusion(illusionModulator)

	endif
EndFunction


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  WEAPON LEARN SWITCHBOARD  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Function LearnWeapon(int weaponType)
	;my player had about 550 kills at level 25
	if (weaponType == ONEHANDED_WEAPTYPE)
		LearnOneHanded()
	elseif (weaponType == TWOHANDED_WEAPTYPE)
		LearnTwoHanded()
	elseif (weaponType == BOW_WEAPTYPE)
		LearnArchery()
	elseif (weaponType == UNARMED_WEAPTYPE)
		LearnUnarmed()
	endif
EndFunction


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  ARMOR LEARN UTILITIES  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

float property playerHeavyArmorWornCount auto hidden
float property playerLightArmorWornCount auto hidden

Function UpdateHeavyArmorCount(int newCount) ;receives number from 0 to 4 inclusive
	playerHeavyArmorWornCount = newCount as float
EndFunction
Function UpdateLightArmorCount(int newCount)
	playerLightArmorWornCount = newCount as float
EndFunction





;;;;;;;;;;;;;;;;;;;;;;;;;;;;   LEARN ABILITY-TO-ENCHANTMENT CORRELATION   ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

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

Function CorrelationArrayInit()

	LearnActiveCounts = new int[35]

	;there are 30 usable slotmasks, so it seems sensible to limit the length of these

	LearnAlchemy_ActiveEnchantments        = new Enchantment[30]
	LearnAlteration_ActiveEnchantments     = new Enchantment[30]
	LearnArchery_ActiveEnchantments        = new Enchantment[30]
	LearnBlock_ActiveEnchantments          = new Enchantment[30]
	LearnCarry_ActiveEnchantments          = new Enchantment[30]
	LearnConjuration_ActiveEnchantments    = new Enchantment[30]
	LearnDestruction_ActiveEnchantments    = new Enchantment[30]
	LearnHealRate_ActiveEnchantments       = new Enchantment[30]
	LearnHealth_ActiveEnchantments         = new Enchantment[30]
	LearnHeavyArmor_ActiveEnchantments     = new Enchantment[30]
	LearnIllusion_ActiveEnchantments       = new Enchantment[30]
	LearnLightArmor_ActiveEnchantments     = new Enchantment[30]
	LearnLockpicking_ActiveEnchantments    = new Enchantment[30]
	LearnMagicka_ActiveEnchantments        = new Enchantment[30]
	LearnMagickaRate_ActiveEnchantments    = new Enchantment[30]
	LearnMuffle_ActiveEnchantments         = new Enchantment[30]
	LearnOneHanded_ActiveEnchantments      = new Enchantment[30]
	LearnPersuasion_ActiveEnchantments     = new Enchantment[30]
	LearnPickpocket_ActiveEnchantments     = new Enchantment[30]
	LearnResistDisease_ActiveEnchantments  = new Enchantment[30]
	LearnResistFire_ActiveEnchantments     = new Enchantment[30]
	LearnResistFrost_ActiveEnchantments    = new Enchantment[30]
	LearnResistMagic_ActiveEnchantments    = new Enchantment[30]
	LearnResistPoison_ActiveEnchantments   = new Enchantment[30]
	LearnResistShock_ActiveEnchantments    = new Enchantment[30]
	LearnRestoration_ActiveEnchantments    = new Enchantment[30]
	LearnSmithing_ActiveEnchantments       = new Enchantment[30]
	LearnSneak_ActiveEnchantments          = new Enchantment[30]
	LearnSpeed_ActiveEnchantments          = new Enchantment[30]
	LearnStamina_ActiveEnchantments        = new Enchantment[30]
	LearnStaminaRate_ActiveEnchantments    = new Enchantment[30]
	LearnTwoHanded_ActiveEnchantments      = new Enchantment[30]
	LearnUnarmed_ActiveEnchantments        = new Enchantment[30]
	LearnWaterbreathing_ActiveEnchantments = new Enchantment[30]
	LearnUnknown_ActiveEnchantments        = new Enchantment[30]

	LearnAlchemy_ActiveMults        = new float[30]
	LearnAlteration_ActiveMults     = new float[30]
	LearnArchery_ActiveMults        = new float[30]
	LearnBlock_ActiveMults          = new float[30]
	LearnCarry_ActiveMults          = new float[30]
	LearnConjuration_ActiveMults    = new float[30]
	LearnDestruction_ActiveMults    = new float[30]
	LearnHealRate_ActiveMults       = new float[30]
	LearnHealth_ActiveMults         = new float[30]
	LearnHeavyArmor_ActiveMults     = new float[30]
	LearnIllusion_ActiveMults       = new float[30]
	LearnLightArmor_ActiveMults     = new float[30]
	LearnLockpicking_ActiveMults    = new float[30]
	LearnMagicka_ActiveMults        = new float[30]
	LearnMagickaRate_ActiveMults    = new float[30]
	LearnMuffle_ActiveMults         = new float[30]
	LearnOneHanded_ActiveMults      = new float[30]
	LearnPersuasion_ActiveMults     = new float[30]
	LearnPickpocket_ActiveMults     = new float[30]
	LearnResistDisease_ActiveMults  = new float[30]
	LearnResistFire_ActiveMults     = new float[30]
	LearnResistFrost_ActiveMults    = new float[30]
	LearnResistMagic_ActiveMults    = new float[30]
	LearnResistPoison_ActiveMults   = new float[30]
	LearnResistShock_ActiveMults    = new float[30]
	LearnRestoration_ActiveMults    = new float[30]
	LearnSmithing_ActiveMults       = new float[30]
	LearnSneak_ActiveMults          = new float[30]
	LearnSpeed_ActiveMults          = new float[30]
	LearnStamina_ActiveMults        = new float[30]
	LearnStaminaRate_ActiveMults    = new float[30]
	LearnTwoHanded_ActiveMults      = new float[30]
	LearnUnarmed_ActiveMults        = new float[30]
	LearnWaterbreathing_ActiveMults = new float[30]
	LearnUnknown_ActiveMults        = new float[30]
EndFunction

Function CorrelationArrayPostInit()
	Delegator.CorrelationArraySetup(self)
EndFunction




;;;;;;;;;;;;;;;;;;;;;;;;;; LEARN EXPERIENCE, LEVELING, & PERK ASSIGNMENT ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Perk[]      property  LearnPerks            auto ;fill with all 60 learn perks in CK, in order (tier01 level01 -> tier03 level20)
Formlist[]  property  LearnExperienceLists  auto ;fill with all 60 formlists in CK (correlates to perks & enchantment arrays below)

Enchantment[]  property  tier1_ExpLevel01_Enchantments  auto  hidden
Enchantment[]  property  tier1_ExpLevel02_Enchantments  auto  hidden
Enchantment[]  property  tier1_ExpLevel03_Enchantments  auto  hidden
Enchantment[]  property  tier1_ExpLevel04_Enchantments  auto  hidden
Enchantment[]  property  tier1_ExpLevel05_Enchantments  auto  hidden
Enchantment[]  property  tier1_ExpLevel06_Enchantments  auto  hidden
Enchantment[]  property  tier1_ExpLevel07_Enchantments  auto  hidden
Enchantment[]  property  tier1_ExpLevel08_Enchantments  auto  hidden
Enchantment[]  property  tier1_ExpLevel09_Enchantments  auto  hidden
Enchantment[]  property  tier1_ExpLevel10_Enchantments  auto  hidden
Enchantment[]  property  tier1_ExpLevel11_Enchantments  auto  hidden
Enchantment[]  property  tier1_ExpLevel12_Enchantments  auto  hidden
Enchantment[]  property  tier1_ExpLevel13_Enchantments  auto  hidden
Enchantment[]  property  tier1_ExpLevel14_Enchantments  auto  hidden
Enchantment[]  property  tier1_ExpLevel15_Enchantments  auto  hidden
Enchantment[]  property  tier1_ExpLevel16_Enchantments  auto  hidden
Enchantment[]  property  tier1_ExpLevel17_Enchantments  auto  hidden
Enchantment[]  property  tier1_ExpLevel18_Enchantments  auto  hidden
Enchantment[]  property  tier1_ExpLevel19_Enchantments  auto  hidden
Enchantment[]  property  tier1_ExpLevel20_Enchantments  auto  hidden

Enchantment[]  property  tier2_ExpLevel01_Enchantments  auto  hidden
Enchantment[]  property  tier2_ExpLevel02_Enchantments  auto  hidden
Enchantment[]  property  tier2_ExpLevel03_Enchantments  auto  hidden
Enchantment[]  property  tier2_ExpLevel04_Enchantments  auto  hidden
Enchantment[]  property  tier2_ExpLevel05_Enchantments  auto  hidden
Enchantment[]  property  tier2_ExpLevel06_Enchantments  auto  hidden
Enchantment[]  property  tier2_ExpLevel07_Enchantments  auto  hidden
Enchantment[]  property  tier2_ExpLevel08_Enchantments  auto  hidden
Enchantment[]  property  tier2_ExpLevel09_Enchantments  auto  hidden
Enchantment[]  property  tier2_ExpLevel10_Enchantments  auto  hidden
Enchantment[]  property  tier2_ExpLevel11_Enchantments  auto  hidden
Enchantment[]  property  tier2_ExpLevel12_Enchantments  auto  hidden
Enchantment[]  property  tier2_ExpLevel13_Enchantments  auto  hidden
Enchantment[]  property  tier2_ExpLevel14_Enchantments  auto  hidden
Enchantment[]  property  tier2_ExpLevel15_Enchantments  auto  hidden
Enchantment[]  property  tier2_ExpLevel16_Enchantments  auto  hidden
Enchantment[]  property  tier2_ExpLevel17_Enchantments  auto  hidden
Enchantment[]  property  tier2_ExpLevel18_Enchantments  auto  hidden
Enchantment[]  property  tier2_ExpLevel19_Enchantments  auto  hidden
Enchantment[]  property  tier2_ExpLevel20_Enchantments  auto  hidden

Enchantment[]  property  tier3_ExpLevel01_Enchantments  auto  hidden
Enchantment[]  property  tier3_ExpLevel02_Enchantments  auto  hidden
Enchantment[]  property  tier3_ExpLevel03_Enchantments  auto  hidden
Enchantment[]  property  tier3_ExpLevel04_Enchantments  auto  hidden
Enchantment[]  property  tier3_ExpLevel05_Enchantments  auto  hidden
Enchantment[]  property  tier3_ExpLevel06_Enchantments  auto  hidden
Enchantment[]  property  tier3_ExpLevel07_Enchantments  auto  hidden
Enchantment[]  property  tier3_ExpLevel08_Enchantments  auto  hidden
Enchantment[]  property  tier3_ExpLevel09_Enchantments  auto  hidden
Enchantment[]  property  tier3_ExpLevel10_Enchantments  auto  hidden
Enchantment[]  property  tier3_ExpLevel11_Enchantments  auto  hidden
Enchantment[]  property  tier3_ExpLevel12_Enchantments  auto  hidden
Enchantment[]  property  tier3_ExpLevel13_Enchantments  auto  hidden
Enchantment[]  property  tier3_ExpLevel14_Enchantments  auto  hidden
Enchantment[]  property  tier3_ExpLevel15_Enchantments  auto  hidden
Enchantment[]  property  tier3_ExpLevel16_Enchantments  auto  hidden
Enchantment[]  property  tier3_ExpLevel17_Enchantments  auto  hidden
Enchantment[]  property  tier3_ExpLevel18_Enchantments  auto  hidden
Enchantment[]  property  tier3_ExpLevel19_Enchantments  auto  hidden
Enchantment[]  property  tier3_ExpLevel20_Enchantments  auto  hidden


Function ExperienceArrayInit()
	defensiveEnchantments         = new Enchantment[128]
	defensiveEnchantments_xp      = new float[128]
	defensiveEnchantments_lvl     = new int[128]
	offensiveEnchantments         = new Enchantment[128]
	offensiveEnchantments_xp      = new float[128]
	offensiveEnchantments_lvl     = new int[128]

	learnLevelThresholds          = new float[21]

	tier1_ExpLevel01_Enchantments = new Enchantment[128]
	tier1_ExpLevel02_Enchantments = new Enchantment[128]
	tier1_ExpLevel03_Enchantments = new Enchantment[128]
	tier1_ExpLevel04_Enchantments = new Enchantment[128]
	tier1_ExpLevel05_Enchantments = new Enchantment[128]
	tier1_ExpLevel06_Enchantments = new Enchantment[128]
	tier1_ExpLevel07_Enchantments = new Enchantment[128]
	tier1_ExpLevel08_Enchantments = new Enchantment[128]
	tier1_ExpLevel09_Enchantments = new Enchantment[128]
	tier1_ExpLevel10_Enchantments = new Enchantment[128]
	tier1_ExpLevel11_Enchantments = new Enchantment[128]
	tier1_ExpLevel12_Enchantments = new Enchantment[128]
	tier1_ExpLevel13_Enchantments = new Enchantment[128]
	tier1_ExpLevel14_Enchantments = new Enchantment[128]
	tier1_ExpLevel15_Enchantments = new Enchantment[128]
	tier1_ExpLevel16_Enchantments = new Enchantment[128]
	tier1_ExpLevel17_Enchantments = new Enchantment[128]
	tier1_ExpLevel18_Enchantments = new Enchantment[128]
	tier1_ExpLevel19_Enchantments = new Enchantment[128]
	tier1_ExpLevel20_Enchantments = new Enchantment[128]

	tier2_ExpLevel01_Enchantments = new Enchantment[128]
	tier2_ExpLevel02_Enchantments = new Enchantment[128]
	tier2_ExpLevel03_Enchantments = new Enchantment[128]
	tier2_ExpLevel04_Enchantments = new Enchantment[128]
	tier2_ExpLevel05_Enchantments = new Enchantment[128]
	tier2_ExpLevel06_Enchantments = new Enchantment[128]
	tier2_ExpLevel07_Enchantments = new Enchantment[128]
	tier2_ExpLevel08_Enchantments = new Enchantment[128]
	tier2_ExpLevel09_Enchantments = new Enchantment[128]
	tier2_ExpLevel10_Enchantments = new Enchantment[128]
	tier2_ExpLevel11_Enchantments = new Enchantment[128]
	tier2_ExpLevel12_Enchantments = new Enchantment[128]
	tier2_ExpLevel13_Enchantments = new Enchantment[128]
	tier2_ExpLevel14_Enchantments = new Enchantment[128]
	tier2_ExpLevel15_Enchantments = new Enchantment[128]
	tier2_ExpLevel16_Enchantments = new Enchantment[128]
	tier2_ExpLevel17_Enchantments = new Enchantment[128]
	tier2_ExpLevel18_Enchantments = new Enchantment[128]
	tier2_ExpLevel19_Enchantments = new Enchantment[128]
	tier2_ExpLevel20_Enchantments = new Enchantment[128]

	tier3_ExpLevel01_Enchantments = new Enchantment[128]
	tier3_ExpLevel02_Enchantments = new Enchantment[128]
	tier3_ExpLevel03_Enchantments = new Enchantment[128]
	tier3_ExpLevel04_Enchantments = new Enchantment[128]
	tier3_ExpLevel05_Enchantments = new Enchantment[128]
	tier3_ExpLevel06_Enchantments = new Enchantment[128]
	tier3_ExpLevel07_Enchantments = new Enchantment[128]
	tier3_ExpLevel08_Enchantments = new Enchantment[128]
	tier3_ExpLevel09_Enchantments = new Enchantment[128]
	tier3_ExpLevel10_Enchantments = new Enchantment[128]
	tier3_ExpLevel11_Enchantments = new Enchantment[128]
	tier3_ExpLevel12_Enchantments = new Enchantment[128]
	tier3_ExpLevel13_Enchantments = new Enchantment[128]
	tier3_ExpLevel14_Enchantments = new Enchantment[128]
	tier3_ExpLevel15_Enchantments = new Enchantment[128]
	tier3_ExpLevel16_Enchantments = new Enchantment[128]
	tier3_ExpLevel17_Enchantments = new Enchantment[128]
	tier3_ExpLevel18_Enchantments = new Enchantment[128]
	tier3_ExpLevel19_Enchantments = new Enchantment[128]
	tier3_ExpLevel20_Enchantments = new Enchantment[128]
EndFunction

Function ExperienceArrayPostInit() ;setup
	Maintainer.LinkLearnPerks(self)

	int i = 21
	while (i) ;set learn thresholds
		i -= 1
		learnLevelThresholds[i] = (200 + (15 * i)) * i
		; learnLevelThresholds[i] = i * 4 ;;;DEBUGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGG
	endWhile

	EA_Extender.SetOffensiveEnchantmentLearnExperienceMult(kExperienceMults[iWEAPONENCHANTS])
	EA_Extender.SetOffensiveEnchantmentLearnLevelThresholds(learnLevelThresholds)
EndFunction


; (NOT USED)
; Enchantment[] Function GetEnchantmentExperienceTrackerAbsolute(int absoluteIndex)
; 	int tier  = (absoluteIndex / 20) + 1
; 	int level = (absoluteIndex % 20)
; 	GetEnchantmentExperienceTracker(tier, level)
; EndFunction


Enchantment[] Function GetEnchantmentExperienceTracker(int tier, int level)
	if (tier == 1)
		if (level <= 10)
			if (level <= 5)
				if (level == 1)
					return tier1_ExpLevel01_Enchantments
				elseif (level == 2)
					return tier1_ExpLevel02_Enchantments
				elseif (level == 3)
					return tier1_ExpLevel03_Enchantments
				elseif (level == 4)
					return tier1_ExpLevel04_Enchantments
				else ;(level == 5)
					return tier1_ExpLevel05_Enchantments
				endif
			else ;(level > 5)
				if (level == 6)
					return tier1_ExpLevel06_Enchantments
				elseif (level == 7)
					return tier1_ExpLevel07_Enchantments
				elseif (level == 8)
					return tier1_ExpLevel08_Enchantments
				elseif (level == 9)
					return tier1_ExpLevel09_Enchantments
				else ;(level == 10)
					return tier1_ExpLevel10_Enchantments
				endif
			endif
		else ;(level > 10)
			if (level <= 15)
				if (level == 11)
					return tier1_ExpLevel11_Enchantments
				elseif (level == 12)
					return tier1_ExpLevel12_Enchantments
				elseif (level == 13)
					return tier1_ExpLevel13_Enchantments
				elseif (level == 14)
					return tier1_ExpLevel14_Enchantments
				else ;(level == 15)
					return tier1_ExpLevel15_Enchantments
				endif
			else ;(level > 15)
				if (level == 16)
					return tier1_ExpLevel16_Enchantments
				elseif (level == 17)
					return tier1_ExpLevel17_Enchantments
				elseif (level == 18)
					return tier1_ExpLevel18_Enchantments
				elseif (level == 19)
					return tier1_ExpLevel19_Enchantments
				else ;(level == 20)
					return tier1_ExpLevel20_Enchantments
				endif
			endif
		endif
	elseif (tier == 2)
		if (level <= 10)
			if (level <= 5)
				if (level == 1)
					return tier2_ExpLevel01_Enchantments
				elseif (level == 2)
					return tier2_ExpLevel02_Enchantments
				elseif (level == 3)
					return tier2_ExpLevel03_Enchantments
				elseif (level == 4)
					return tier2_ExpLevel04_Enchantments
				else ;(level == 5)
					return tier2_ExpLevel05_Enchantments
				endif
			else ;(level > 5)
				if (level == 6)
					return tier2_ExpLevel06_Enchantments
				elseif (level == 7)
					return tier2_ExpLevel07_Enchantments
				elseif (level == 8)
					return tier2_ExpLevel08_Enchantments
				elseif (level == 9)
					return tier2_ExpLevel09_Enchantments
				else ;(level == 10)
					return tier2_ExpLevel10_Enchantments
				endif
			endif
		else ;(level > 10)
			if (level <= 15)
				if (level == 11)
					return tier2_ExpLevel11_Enchantments
				elseif (level == 12)
					return tier2_ExpLevel12_Enchantments
				elseif (level == 13)
					return tier2_ExpLevel13_Enchantments
				elseif (level == 14)
					return tier2_ExpLevel14_Enchantments
				else ;(level == 15)
					return tier2_ExpLevel15_Enchantments
				endif
			else ;(level > 15)
				if (level == 16)
					return tier2_ExpLevel16_Enchantments
				elseif (level == 17)
					return tier2_ExpLevel17_Enchantments
				elseif (level == 18)
					return tier2_ExpLevel18_Enchantments
				elseif (level == 19)
					return tier2_ExpLevel19_Enchantments
				else ;(level == 20)
					return tier2_ExpLevel20_Enchantments
				endif
			endif
		endif
	else ;(tier == 3)
		if (level <= 10)
			if (level <= 5)
				if (level == 1)
					return tier3_ExpLevel01_Enchantments
				elseif (level == 2)
					return tier3_ExpLevel02_Enchantments
				elseif (level == 3)
					return tier3_ExpLevel03_Enchantments
				elseif (level == 4)
					return tier3_ExpLevel04_Enchantments
				else ;(level == 5)
					return tier3_ExpLevel05_Enchantments
				endif
			else ;(level > 5)
				if (level == 6)
					return tier3_ExpLevel06_Enchantments
				elseif (level == 7)
					return tier3_ExpLevel07_Enchantments
				elseif (level == 8)
					return tier3_ExpLevel08_Enchantments
				elseif (level == 9)
					return tier3_ExpLevel09_Enchantments
				else ;(level == 10)
					return tier3_ExpLevel10_Enchantments
				endif
			endif
		else ;(level > 10)
			if (level <= 15)
				if (level == 11)
					return tier3_ExpLevel11_Enchantments
				elseif (level == 12)
					return tier3_ExpLevel12_Enchantments
				elseif (level == 13)
					return tier3_ExpLevel13_Enchantments
				elseif (level == 14)
					return tier3_ExpLevel14_Enchantments
				else ;(level == 15)
					return tier3_ExpLevel15_Enchantments
				endif
			else ;(level > 15)
				if (level == 16)
					return tier3_ExpLevel16_Enchantments
				elseif (level == 17)
					return tier3_ExpLevel17_Enchantments
				elseif (level == 18)
					return tier3_ExpLevel18_Enchantments
				elseif (level == 19)
					return tier3_ExpLevel19_Enchantments
				else ;(level == 20)
					return tier3_ExpLevel20_Enchantments
				endif
			endif
		endif
	endif
	;else, error:
	debug.trace("Enchanting Awakened: Error - GetEnchantmentExperienceTracker" \
	  + " inputs out of bounds [tier: " + tier + " level: " + level + "]")
	Enchantment[] nullArray = new Enchantment[128]
	return nullArray
EndFunction



Formlist  property  EA_Tier1_EnchantmentsList  auto
Formlist  property  EA_Tier2_EnchantmentsList  auto
Formlist  property  EA_Tier3_EnchantmentsList  auto
bool      AdjustLearnLevelLOCK = false

Function AdjustEnchantmentLearnLevel(Enchantment baseEnch, int oldLevel, int newLevel) ;levels should be integers from 1 to 20 inclusive
	int tier = 1
	if (EA_Tier2_EnchantmentsList.hasForm(baseEnch))
		tier = 2
	elseif (EA_Tier3_EnchantmentsList.hasForm(baseEnch))
		tier = 3
	endif

	while AdjustLearnLevelLOCK
		utility.waitmenumode(0.2)
	endWhile
	AdjustLearnLevelLOCK = true

		if (oldLevel > 0)
			;retrieve old list data
			Enchantment[] oldList = GetEnchantmentExperienceTracker(tier, oldLevel)
			int entryIndex        = oldList.find(baseEnch)
			int maxIndex          = oldList.find(none)
			if (maxIndex == -1)
				maxIndex = 128
			else
				maxIndex -= 1
			endif

			if (entryIndex < 0 || maxIndex < entryIndex) ;error
				debug.trace("Enchanting Awakened: Error - AdjustLearnLevel index error [enchantment: " \
				  + baseEnch.getFormID() + " entryIndex: " + entryIndex + " maxIndex: " + maxIndex \
				  + " tier: " + tier + " oldLevel: " + oldLevel + " newLevel: " + newLevel + "]")
				AdjustLearnLevelLOCK = false
				return
			endif

			;clear entry from old list and shift other elements down
			while (entryIndex < maxIndex)
				oldList[entryIndex] = oldList[entryIndex + 1]
				entryIndex += 1
			endWhile
			oldList[entryIndex] = none

			;reset associated formlist with correct forms
			int associatedIndex = ((tier - 1) * 20) + oldLevel - 1
			Formlist associatedFormlist = LearnExperienceLists[associatedIndex]
			associatedFormlist.Revert()

			if (maxIndex > 0) ;update perk scaling formlist based on remaining enchantments
				EA_Extender.FillFormlistWithChildrenOfBaseEnchantments(associatedFormlist, oldList)
			else ;no enchantments left in list, REMOVE ASSOCIATED PERK from player
				playerRef.RemovePerk(LearnPerks[associatedIndex])
			endif
		endif


		;insert enchantment into new list
		Enchantment[] newList = GetEnchantmentExperienceTracker(tier, newLevel)
		int nextIndex         = newList.find(none)

		if (nextIndex == -1) ;error
			debug.trace("Enchanting Awakened: Error - AdjustLearnLevel index overflow [enchantment: " \
			  + baseEnch.getFormID() + " tier: " + tier + " oldLevel: " + oldLevel + " newLevel: " + newLevel + "]")
			AdjustLearnLevelLOCK = false
			return
		endif

		newList[nextIndex] = baseEnch

		; ;;DEBUG ONLY -------------------------------------------------------------
		; if (newLevel % 5) == 0
		; 	debug.notification("new level == " + newLevel)
		; endif ;;------------------------------------------------------------------

		;update associated formlist with new forms
		int associatedIndex = ((tier - 1) * 20) + newLevel - 1
		Formlist associatedFormlist = LearnExperienceLists[associatedIndex]
		EA_Extender.FillFormlistWithChildrenOfBaseEnchantments(associatedFormlist, newList)

		if (nextIndex == 0) ;first enchantment added to list, ADD ASSOCIATED PERK to player
			playerRef.AddPerk(LearnPerks[associatedIndex])
		endif

	AdjustLearnLevelLOCK = false
EndFunction























;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;							DEBUG  ONLY     -    delete strings and traces

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

string[] debugStrings

Function debugSetup()
	debugStrings = new string[35]

	debugStrings[0] = "Alchemy"
	debugStrings[1] = "Alteration"
	debugStrings[2] = "Archery"
	debugStrings[3] = "Block"
	debugStrings[4] = "Carry"
	debugStrings[5] = "Conjuration"
	debugStrings[6] = "Destruction"
	debugStrings[7] = "Healrate"
	debugStrings[8] = "Health"
	debugStrings[9] = "Heavyarmor"
	debugStrings[10] = "Illusion"
	debugStrings[11] = "Lightarmor"
	debugStrings[12] = "Lockpicking"
	debugStrings[13] = "Magicka"
	debugStrings[14] = "Magickarate"
	debugStrings[15] = "Muffle"
	debugStrings[16] = "Onehanded"
	debugStrings[17] = "Persuasion"
	debugStrings[18] = "Pickpocket"
	debugStrings[19] = "Resistdisease"
	debugStrings[20] = "Resistfire"
	debugStrings[21] = "Resistfrost"
	debugStrings[22] = "Resistmagic"
	debugStrings[23] = "Resistpoison"
	debugStrings[24] = "Resistshock"
	debugStrings[25] = "Restoration"
	debugStrings[26] = "Smithing"
	debugStrings[27] = "Sneak"
	debugStrings[28] = "Speed"
	debugStrings[29] = "Stamina"
	debugStrings[30] = "Staminarate"
	debugStrings[31] = "Twohanded"
	debugStrings[32] = "Unarmed"
	debugStrings[33] = "Waterbreathing"
	debugStrings[34] = "UnknownEffect"
	debugStrings[35] = "OffensiveEnchantments"
EndFunction