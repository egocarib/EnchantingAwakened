Scriptname EA_Learn_Controller extends ReferenceAlias

; GlobalVariable[] property stateInfo auto

; int property inCombat autoreadonly

Actor  property playerRef auto
Quest  property  MQ101  auto
EA_Learn_Delegator property Delegator auto

;bool[] property  learnEnabled  auto
;int[] property learnEnabled auto


int  property  ALTERATION  = 0  autoreadonly
int  property  CONJURATION = 1  autoreadonly
int  property  DESTRUCTION = 2  autoreadonly
int  property  ILLUSION    = 3  autoreadonly
int  property  RESTORATION = 4  autoreadonly
;int  property  MAGICKA     = 5  autoreadonly
; int  property  HEAVY_ARMOR = 6  autoreadonly
; int  property  LIGHT_ARMOR = 7  autoreadonly

; ;State-based event controllers
; int  property  currentEventState = 0x00
; int  property  kState_HeavyArmor = 0x01 autoreadonly
; int  property  kState_LightArmor = 0x02 autoreadonly

float  property  fortifyBlock_xp        auto hidden
float  property  fortifyHeavyArmor_xp   auto hidden
float  property  fortifyLightArmor_xp   auto hidden
float  property  fortifyHealth_xp       auto hidden
float  property  fortifyHealRate_xp     auto hidden
float  property  fortifyMagickaRate_xp  auto hidden
float  property  fortifyStaminaRate_xp  auto hidden
float  property  fortifySneak_xp        auto hidden
float  property  fortifyAlteration_xp   auto hidden
float  property  fortifyConjuration_xp  auto hidden
float  property  fortifyDestruction_xp  auto hidden
float  property  fortifyIllusion_xp     auto hidden
float  property  fortifyRestoration_xp  auto hidden


Event OnInit()
	;learnEnabled = Delegator.enchantEffectsCount
	;debug.trace(">>>>>>>>>>>>>>>>>>>>.. EXTRACTING INFO FROM Learn_Delegator (need to make sure it's initialized) - enchantEffectsCount.Length == " + learnEnabled.Length)
	RegisterForSingleUpdate(30.0)
	; RegisterForModEvent("EA_LearnAbilityUpkeep", "LearnAbilityUpkeep")
EndEvent

; Event OnPlayerLoadGame()
;     RegisterForModEvent("EA_LearnAbilityUpkeep", "LearnAbilityUpkeep")
;     int i = IsLearning.Length
;     while (i)
;     	i -= 1
;     	if (IsLearning[i])
;     		SendModEvent("EA_LearnAbilityUpkeep")
;     		return
;     	endif
;     endWhile
; EndEvent

Event OnUpdate()
	;apparently, gametime registrations dont work until player gains controls
	if (MQ101.GetCurrentStageID() >= 240)
		registerForSingleUpdateGameTime(1.0)
	else
		registerForSingleUpdate(300.0)
	endif
EndEvent

Event OnUpdateGameTime()
	awardIdleExperience() ;give every 12 hours just for wearing stuff (or having equipped in the case of weapon)
	registerForSingleUpdateGameTime(12.0)
EndEvent
Function awardIdleExperience()
EndFunction

Function LearnBlock()
	debug.notification("LearnBlock called successfully")
	debug.trace("Enchanting Awakened >>>>>>>>>>>>>>>>>>>>> LearnBlock CALLED SUCCESSFULLY")
EndFunction
Function LearnHeavyArmor()
	debug.notification("LearnHeavyArmor called successfully")
	debug.trace("Enchanting Awakened >>>>>>>>>>>>>>>>>>>>> LearnHeavyArmor CALLED SUCCESSFULLY")
EndFunction
Function LearnLightArmor()
	debug.notification("LearnLightArmor called successfully")
	debug.trace("Enchanting Awakened >>>>>>>>>>>>>>>>>>>>> LearnLightArmor CALLED SUCCESSFULLY")
EndFunction
Function LearnHealth(float modifier) ;num seconds health was below 50%
	;just take square root of modifier for learn amount.
	debug.notification("LearnHealth called successfully")
	debug.trace("Enchanting Awakened >>>>>>>>>>>>>>>>>>>>> LearnHealth CALLED SUCCESSFULLY (modifier == " + modifier + ")")
EndFunction
Function LearnMagicka()
	debug.notification("LearnMagicka called successfully")
	debug.trace("Enchanting Awakened >>>>>>>>>>>>>>>>>>>>> LearnMagicka CALLED SUCCESSFULLY")
EndFunction
Function LearnHealRate()
	debug.notification("LearnHealRate called successfully")
	debug.trace("Enchanting Awakened >>>>>>>>>>>>>>>>>>>>> LearnHealRate CALLED SUCCESSFULLY")
EndFunction
Function LearnMagickaRate()
	debug.notification("LearnMagickaRate called successfully")
	debug.trace("Enchanting Awakened >>>>>>>>>>>>>>>>>>>>> LearnMagickaRate CALLED SUCCESSFULLY")
EndFunction
Function LearnStamina(bool learnStamina, bool learnStaminaRate)
	debug.notification("LearnStamina (stamina=" + learnStamina + "  staminaRate=" + learnStaminaRate + ")")
	debug.trace("Enchanting Awakened >>>>>>>>>>>>>>>>>>>>> LearnStaminaRate CALLED SUCCESSFULLY (stamina=" + learnStamina + "  staminaRate=" + learnStaminaRate + ")")
EndFunction
Function LearnPickpocket(float modifier)
	debug.notification("LearnPickpocket called successfully")
	debug.trace("Enchanting Awakened >>>>>>>>>>>>>>>>>>>>> LearnPickpocket CALLED SUCCESSFULLY (modifier == " + modifier + ")")
EndFunction
Function LearnResistDisease(float modifier = 1.0)
	debug.notification("LearnResistDisease called successfully")
	debug.trace("Enchanting Awakened >>>>>>>>>>>>>>>>>>>>> LearnResistDisease CALLED SUCCESSFULLY (modifier == " + modifier + ")")
EndFunction

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

float sneakModifier = 1.0

Function LearnSneak(float modifier = 1.0, bool idling = false)
   ;if zero, should still maybe grant a small bit of experience
	if (idling)
		fortifySneak_xp += sneakModifier
		sneakModifier = sneakModifier * 0.95 ;limits idle experience gain to the integral of (0.95^x)
	else
		fortifySneak_xp += modifier
		sneakModifier = 1.0
	endif

	debug.notification("LearnSneak (mod: " + modifier + "  sneakMod: " + sneakModifier + "  total: " + fortifySneak_xp + ")")
	debug.trace("Enchanting Awakened >>>>>>>>>>>>>>>>>>>>> LearnSneak CALLED SUCCESSFULLY (mod: " + modifier + "  sneakMod: " + sneakModifier + "  total: " + fortifySneak_xp + ")")
EndFunction


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  MAGIC LEARNING ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

float alterationModifier  = 1.0
float conjurationModifier = 1.0
float destructionModifier = 1.0
float illusionModifier    = 1.0
float restorationModifier = 1.0

Form lastAlterationSpell
Form lastConjurationSpell
Form lastIllusionSpell

Function LearnMagic(int magicSchool, Form castedSpell)

	if (magicSchool == DESTRUCTION)
		if (playerRef.isInCombat())
			destructionModifier = 1.0
		else
			destructionModifier *= 0.8
		endif
		LearnDestruction(destructionModifier)

	elseif (magicSchool == RESTORATION)
		debug.trace("Enchanting Awakened >>>>>>>>>>>>>>>>>>>>> GetActorValuePercentage(\"Health\") == " + playerRef.GetActorValuePercentage("Health") + "   isInCombat() == " + playerRef.isInCombat())
		if ((playerRef.GetActorValuePercentage("Health") <= 0.96) || playerRef.isInCombat())
			restorationModifier = 1.0
		else
			restorationModifier *= 0.6
		endif
		LearnRestoration(restorationModifier)

	elseif (magicSchool == ALTERATION)
		if (castedSpell != lastAlterationSpell)
			alterationModifier = 1.0
			lastAlterationSpell = castedSpell
		elseif (playerRef.isInCombat())
			alterationModifier = 1.0
		else
			alterationModifier *= 0.9
		endif
		LearnAlteration(alterationModifier)

	elseif (magicSchool == CONJURATION)
		if (castedSpell != lastConjurationSpell)
			conjurationModifier = 1.0
			lastConjurationSpell = castedSpell
		elseif (playerRef.isInCombat())
			conjurationModifier = 1.0
		else
			conjurationModifier *= 0.9
		endif
		LearnConjuration(conjurationModifier)

	elseif (magicSchool == ILLUSION)
		if (castedSpell != lastIllusionSpell)
			illusionModifier = 1.0
			lastIllusionSpell = castedSpell
		elseif (playerRef.isInCombat())
			illusionModifier = 1.0
		else
			illusionModifier *= 0.9
		endif
		LearnIllusion(illusionModifier)

	endif
EndFunction


Function LearnAlteration(float modifier)
	debug.notification("LearnAlteration (modifier == " + modifier + ")")
	fortifyAlteration_xp += modifier
	debug.trace("Enchanting Awakened >>>>>>>>>>>>>>>>>>>>> LearnAlteration CALLED SUCCESSFULLY (modifier== " + modifier + "  total==" + fortifyAlteration_xp + ")")
EndFunction
Function LearnConjuration(float modifier)
	debug.notification("LearnConjuration (modifier == " + modifier + ")")
	fortifyConjuration_xp += modifier
	debug.trace("Enchanting Awakened >>>>>>>>>>>>>>>>>>>>> LearnConjuration CALLED SUCCESSFULLY (modifier== " + modifier + "  total==" + fortifyConjuration_xp + ")")
EndFunction
Function LearnDestruction(float modifier)
	debug.notification("LearnDestruction (modifier == " + modifier + ")")
	fortifyDestruction_xp += modifier
	debug.trace("Enchanting Awakened >>>>>>>>>>>>>>>>>>>>> LearnDestruction CALLED SUCCESSFULLY (modifier== " + modifier + "  total==" + fortifyDestruction_xp + ")")
EndFunction
Function LearnIllusion(float modifier)
	debug.notification("LearnIllusion (modifier == " + modifier + ")")
	fortifyIllusion_xp += modifier
	debug.trace("Enchanting Awakened >>>>>>>>>>>>>>>>>>>>> LearnIllusion CALLED SUCCESSFULLY (modifier== " + modifier + "  total==" + fortifyIllusion_xp + ")")
EndFunction
Function LearnRestoration(float modifier)
	debug.notification("LearnRestoration (modifier == " + modifier + ")")
	fortifyRestoration_xp += modifier
	debug.trace("Enchanting Awakened >>>>>>>>>>>>>>>>>>>>> LearnRestoration CALLED SUCCESSFULLY (modifier== " + modifier + "  total==" + fortifyRestoration_xp + ")")
EndFunction


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  LEARN RESISTANCE ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


Function LearnResistFire()
	debug.notification("ResistFire called successfully")
	debug.trace("Enchanting Awakened >>>>>>>>>>>>>>>>>>>>> ResistFire CALLED SUCCESSFULLY")
EndFunction
Function LearnResistFrost()
	debug.notification("ResistFrost called successfully")
	debug.trace("Enchanting Awakened >>>>>>>>>>>>>>>>>>>>> ResistFrost CALLED SUCCESSFULLY")
EndFunction
Function LearnResistShock()
	debug.notification("ResistShock called successfully")
	debug.trace("Enchanting Awakened >>>>>>>>>>>>>>>>>>>>> ResistShock CALLED SUCCESSFULLY")
EndFunction
Function LearnResistMagic()
	debug.notification("ResistMagic called successfully")
	debug.trace("Enchanting Awakened >>>>>>>>>>>>>>>>>>>>> ResistMagic CALLED SUCCESSFULLY")
EndFunction












;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  LEARN UTILITIES ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Function UpdateHeavyArmorCount(int newCount)
	debug.trace("Enchanting Awakened >>>>>>>>>>>>>>>>>>>>> UpdateHeavyArmorCount CALLED SUCCESSFULLY (newCount == " + newCount + ")")
EndFunction
Function UpdateLightArmorCount(int newCount)
	debug.trace("Enchanting Awakened >>>>>>>>>>>>>>>>>>>>> UpdateLightArmorCount CALLED SUCCESSFULLY (newCount == " + newCount + ")")
EndFunction


Function SetEnabled(int enchantID, bool enableFlag)
	debug.trace("Enchanting Awakened >>>>>>>>>>>>>>>>>>>>> WARNING, THIS FUNCTION SHOULD BE DEPRICATEDD!!!!!!")
	;learnEnabled[enchantID] = enableFlag
EndFunction



; Event OnMagicEffectApply(ObjectReference caster, MagicEffect mgef)
;     if (caster == playerRef)
;     	int thisEffect = EnchantmentEffects.find(mgef)
;     	if (thisEffect >= 0)
;     		if (!IsLearning[thisEffect])
;     			playerRef.addSpell(LearningAbilities[thisEffect])
;     			SendModEvent("EA_LearnAbilityUpkeep")
;     		endif
;     	endif
;     endif
; EndEvent

; MagicEffect[] property EnchantmentEffects auto
; Spell[]       property LearningAbilities  auto
; bool[]        property IsLearning         auto


; bool isUpkeeping
; Event LearnAbilityUpkeep(string eventName, string strArg, float numArg, Form sender)
; 	if isUpkeeping
; 		return
; 	endif
; 	isUpkeeping = true
; 	Utility.Wait(1200.0) ;20 min
; 	;check effects
; 	;if no bools left, set isUpkeeping to false
; 	;call self again
; 	int i = IsLearning.Length
; 	while (i)
; 		i -= 1
; 		if (IsLearning[i])
; 			if (!playerRef.HasMagicEffect(EnchantmentEffects[i]))

; 				;well, can't just remove it, because others use it too.... some are shared...
; EndEvent

;then just poll every 30 min or so... remove any effects that aren't on user anymore? Or onplayerloadgame?