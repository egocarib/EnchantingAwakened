Scriptname EA_Learn_Controller extends ReferenceAlias conditional
{central control script for learn events and adding learn experience}


Actor              property  playerRef  auto
Quest              property  MQ101      auto
EA_Learn_Delegator property  Delegator  auto

int  property  ALTERATION  = 0  autoreadonly
int  property  CONJURATION = 1  autoreadonly
int  property  DESTRUCTION = 2  autoreadonly
int  property  ILLUSION    = 3  autoreadonly
int  property  RESTORATION = 4  autoreadonly

int  property  UNARMED     = 0  autoreadonly
int  property  ONEHANDED   = 1  autoreadonly
int  property  TWOHANDED   = 2  autoreadonly
int  property  BOW         = 3  autoreadonly


float  property  fortifyAlchemy_xp      auto hidden conditional
float  property  fortifyLockpicking_xp  auto hidden conditional
float  property  fortifyCarry_xp        auto hidden conditional
float  property  fortifyArchery_xp      auto hidden conditional
float  property  fortifyOneHanded_xp    auto hidden conditional
float  property  fortifyTwoHanded_xp    auto hidden conditional
float  property  fortifyBlock_xp        auto hidden conditional
float  property  fortifyHeavyArmor_xp   auto hidden conditional
float  property  fortifyLightArmor_xp   auto hidden conditional
float  property  fortifyHealth_xp       auto hidden conditional
float  property  fortifyHealRate_xp     auto hidden conditional
float  property  fortifyMagickaRate_xp  auto hidden conditional
float  property  fortifyStaminaRate_xp  auto hidden conditional
float  property  fortifySneak_xp        auto hidden conditional
float  property  fortifyAlteration_xp   auto hidden conditional
float  property  fortifyConjuration_xp  auto hidden conditional
float  property  fortifyDestruction_xp  auto hidden conditional
float  property  fortifyIllusion_xp     auto hidden conditional
float  property  fortifyRestoration_xp  auto hidden conditional


Event OnInit()
	RegisterForSingleUpdate(30.0)
EndEvent

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
	;;;;;;;;;;;;;;;;;;;;;;;;;;
EndFunction

Function LearnBlock(float modifier = 1.0)
	debug.notification("LearnBlock called successfully")
	debug.trace("Enchanting Awakened >>>>>>>>>>>>>>>>>>>>> LearnBlock CALLED SUCCESSFULLY")
EndFunction
Function LearnHeavyArmor(float modifier = 1.0)
	;need to base this off the count, updated in UpdateHeavyArmorCount() function below
	debug.notification("LearnHeavyArmor called successfully")
	debug.trace("Enchanting Awakened >>>>>>>>>>>>>>>>>>>>> LearnHeavyArmor CALLED SUCCESSFULLY")
EndFunction
Function LearnLightArmor(float modifier = 1.0)
	;need to base this off the count, updated in UpdateLightArmorCount() function below
	debug.notification("LearnLightArmor called successfully")
	debug.trace("Enchanting Awakened >>>>>>>>>>>>>>>>>>>>> LearnLightArmor CALLED SUCCESSFULLY")
EndFunction
Function LearnHealth(float modifier = 1.0) ;num seconds health was below 50%
	;just take square root of modifier for learn amount.
	debug.notification("LearnHealth called successfully")
	debug.trace("Enchanting Awakened >>>>>>>>>>>>>>>>>>>>> LearnHealth CALLED SUCCESSFULLY (modifier == " + modifier + ")")
EndFunction
Function LearnMagicka(float modifier = 1.0)
	debug.notification("LearnMagicka called successfully")
	debug.trace("Enchanting Awakened >>>>>>>>>>>>>>>>>>>>> LearnMagicka CALLED SUCCESSFULLY")
EndFunction
Function LearnHealRate(float modifier = 1.0)
	debug.notification("LearnHealRate called successfully")
	debug.trace("Enchanting Awakened >>>>>>>>>>>>>>>>>>>>> LearnHealRate CALLED SUCCESSFULLY")
EndFunction
Function LearnMagickaRate(float modifier = 1.0)
	debug.notification("LearnMagickaRate called successfully")
	debug.trace("Enchanting Awakened >>>>>>>>>>>>>>>>>>>>> LearnMagickaRate CALLED SUCCESSFULLY")
EndFunction
Function LearnStamina(bool learnStamina, bool learnStaminaRate, float modifier = 1.0)
	debug.notification("LearnStamina (stamina=" + learnStamina + "  staminaRate=" + learnStaminaRate + ")")
	debug.trace("Enchanting Awakened >>>>>>>>>>>>>>>>>>>>> LearnStaminaRate CALLED SUCCESSFULLY (stamina=" + learnStamina + "  staminaRate=" + learnStaminaRate + ")")
EndFunction
Function LearnPickpocket(float modifier = 1.0)
	debug.notification("LearnPickpocket called successfully")
	debug.trace("Enchanting Awakened >>>>>>>>>>>>>>>>>>>>> LearnPickpocket CALLED SUCCESSFULLY (modifier == " + modifier + ")")
EndFunction
Function LearnResistDisease(float modifier = 1.0)
	debug.notification("LearnResistDisease called successfully")
	debug.trace("Enchanting Awakened >>>>>>>>>>>>>>>>>>>>> LearnResistDisease CALLED SUCCESSFULLY (modifier == " + modifier + ")")
EndFunction

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



Function LearnAlchemy(float modifier = 1.0)
	;my player had about 1000 total "points" around level 25. most players would probably reach 5,000-10,000 by level 40/50. I remember I wasn't going nuts collecting ingredients or skilling up alchemy..
	debug.notification("LearnAlchemy called successfully")
	debug.trace("Enchanting Awakened >>>>>>>>>>>>>>>>>>>>> LearnAlchemy CALLED SUCCESSFULLY (modifier == " + modifier + ")")
EndFunction

Function LearnWeapon(int weaponType)
	;my player had about 550 kills at level 25
	if (weaponType == ONEHANDED)
		LearnOneHanded()
	elseif (weaponType == TWOHANDED)
		LearnTwoHanded()
	elseif (weaponType == BOW)
		LearnArchery()
	elseif (weaponType == UNARMED)
		LearnUnarmed()
	endif
EndFunction

Function LearnOneHanded(float modifier = 1.0)
	debug.notification("LearnOneHanded called successfully")
	debug.trace("Enchanting Awakened >>>>>>>>>>>>>>>>>>>>> LearnOneHanded CALLED SUCCESSFULLY")
EndFunction
Function LearnTwoHanded(float modifier = 1.0)
	debug.notification("LearnTwoHanded called successfully")
	debug.trace("Enchanting Awakened >>>>>>>>>>>>>>>>>>>>> LearnTwoHanded CALLED SUCCESSFULLY")
EndFunction
Function LearnArchery(float modifier = 1.0)
	debug.notification("LearnArchery called successfully")
	debug.trace("Enchanting Awakened >>>>>>>>>>>>>>>>>>>>> LearnArchery CALLED SUCCESSFULLY")
EndFunction
Function LearnUnarmed(float modifier = 1.0)
	debug.notification("LearnUnarmed called successfully")
	debug.trace("Enchanting Awakened >>>>>>>>>>>>>>>>>>>>> LearnUnarmed CALLED SUCCESSFULLY")
EndFunction

Function LearnCarry(float modifier = 1.0)
	;this function is passed # of minutes enchantment worn. Probably shoot for 100 hours to master?
	debug.notification("LearnCarry called successfully")
	debug.trace("Enchanting Awakened >>>>>>>>>>>>>>>>>>>>> LearnCarry CALLED SUCCESSFULLY (modifier == " + modifier + ")")
EndFunction

Cell lastCell
float lockpickingModifier = 1.0

Function LearnLockpicking(float modifier = 1.0)
	;get to 100 to master.
	Cell thisCell = playerRef.GetParentCell()
	if (thisCell == lastCell) ;limit gain from something like thieves guild practice locks (to the integral of 0.98^x)
		lockpickingModifier *= 0.98
	else
		lastCell = thisCell
		lockpickingModifier = 1.0
	endif
	fortifyLockpicking_xp += lockpickingModifier
EndFunction

Function LearnPersuasion(float modifier = 1.0)
	debug.notification("LearnPersuasion called successfully")
	debug.trace("Enchanting Awakened >>>>>>>>>>>>>>>>>>>>> LearnPersuasion CALLED SUCCESSFULLY (modifier == " + modifier + ")")
	; persuasionTasks  = Game.QueryStat("Houses Owned") * 200
	; persuasionTasks += Game.QueryStat("Stores Invested In") * 300      ;~ 1670 points at level 25 (860 barter, 810 other points based on this formula)
	; persuasionTasks += Game.QueryStat("Barters")                       ;(but keep in mind points only will count while wearing the correct enchantment...)
	; persuasionTasks += Game.QueryStat("Persuasions") * 40
	; persuasionTasks += Game.QueryStat("Bribes") * 60
	; persuasionTasks += Game.QueryStat("Intimidations") * 80
	; persuasionTasks += (playerRef.GetBaseActorValue("Speechcraft") * 10.0) as int
EndFunction

Function LearnWaterbreathing(float modifier = 1.0)
	debug.notification("LearnWaterbreathing called successfully")
	debug.trace("Enchanting Awakened >>>>>>>>>>>>>>>>>>>>> LearnWaterbreathing CALLED SUCCESSFULLY (modifier == " + modifier + ")")
EndFunction

Function LearnSmithing(float modifier = 1.0)
	debug.notification("LearnSmithing called successfully")
	debug.trace("Enchanting Awakened >>>>>>>>>>>>>>>>>>>>> LearnSmithing CALLED SUCCESSFULLY (modifier == " + modifier + ")")
EndFunction

Function LearnSpeed(float modifier = 1.0)
	debug.notification("LearnSpeed called successfully")
	debug.trace("Enchanting Awakened >>>>>>>>>>>>>>>>>>>>> LearnSpeed CALLED SUCCESSFULLY (modifier == " + modifier + ")")
EndFunction

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

float sneakModifier = 1.0

Function LearnSneak(float modifier = 1.0, bool idling = false)
   ;if zero, should still maybe grant a small bit of experience
	if (idling)
		modifier *= sneakModifier
		sneakModifier *= 0.95 ;limits idle experience gain to the integral of (0.95^x)
	else
		sneakModifier = 1.0
	endif
	fortifySneak_xp += modifier

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


Function LearnAlteration(float modifier = 1.0)
	debug.notification("LearnAlteration (modifier == " + modifier + ")")
	fortifyAlteration_xp += modifier
	debug.trace("Enchanting Awakened >>>>>>>>>>>>>>>>>>>>> LearnAlteration CALLED SUCCESSFULLY (modifier== " + modifier + "  total==" + fortifyAlteration_xp + ")")
EndFunction
Function LearnConjuration(float modifier = 1.0)
	debug.notification("LearnConjuration (modifier == " + modifier + ")")
	fortifyConjuration_xp += modifier
	debug.trace("Enchanting Awakened >>>>>>>>>>>>>>>>>>>>> LearnConjuration CALLED SUCCESSFULLY (modifier== " + modifier + "  total==" + fortifyConjuration_xp + ")")
EndFunction
Function LearnDestruction(float modifier = 1.0)
	debug.notification("LearnDestruction (modifier == " + modifier + ")")
	fortifyDestruction_xp += modifier
	debug.trace("Enchanting Awakened >>>>>>>>>>>>>>>>>>>>> LearnDestruction CALLED SUCCESSFULLY (modifier== " + modifier + "  total==" + fortifyDestruction_xp + ")")
EndFunction
Function LearnIllusion(float modifier = 1.0)
	debug.notification("LearnIllusion (modifier == " + modifier + ")")
	fortifyIllusion_xp += modifier
	debug.trace("Enchanting Awakened >>>>>>>>>>>>>>>>>>>>> LearnIllusion CALLED SUCCESSFULLY (modifier== " + modifier + "  total==" + fortifyIllusion_xp + ")")
EndFunction
Function LearnRestoration(float modifier = 1.0)
	debug.notification("LearnRestoration (modifier == " + modifier + ")")
	fortifyRestoration_xp += modifier
	debug.trace("Enchanting Awakened >>>>>>>>>>>>>>>>>>>>> LearnRestoration CALLED SUCCESSFULLY (modifier== " + modifier + "  total==" + fortifyRestoration_xp + ")")
EndFunction


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  LEARN RESISTANCE ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


Function LearnResistFire(float modifier = 1.0)
	debug.notification("ResistFire called successfully")
	debug.trace("Enchanting Awakened >>>>>>>>>>>>>>>>>>>>> ResistFire CALLED SUCCESSFULLY")
EndFunction
Function LearnResistFrost(float modifier = 1.0)
	debug.notification("ResistFrost called successfully")
	debug.trace("Enchanting Awakened >>>>>>>>>>>>>>>>>>>>> ResistFrost CALLED SUCCESSFULLY")
EndFunction
Function LearnResistShock(float modifier = 1.0)
	debug.notification("ResistShock called successfully")
	debug.trace("Enchanting Awakened >>>>>>>>>>>>>>>>>>>>> ResistShock CALLED SUCCESSFULLY")
EndFunction
Function LearnResistMagic(float modifier = 1.0)
	debug.notification("ResistMagic called successfully")
	debug.trace("Enchanting Awakened >>>>>>>>>>>>>>>>>>>>> ResistMagic CALLED SUCCESSFULLY")
EndFunction
Function LearnResistPoison(float modifier = 1.0)
	debug.notification("ResistPoison called successfully")
	debug.trace("Enchanting Awakened >>>>>>>>>>>>>>>>>>>>> ResistPoison CALLED SUCCESSFULLY (modifier == " + modifier + ")")
EndFunction










;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  LEARN UTILITIES ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Function UpdateHeavyArmorCount(int newCount)
	;will send number between 0 and 4 inclusive
	debug.trace("Enchanting Awakened >>>>>>>>>>>>>>>>>>>>> UpdateHeavyArmorCount CALLED SUCCESSFULLY (newCount == " + newCount + ")")
EndFunction
Function UpdateLightArmorCount(int newCount)
	debug.trace("Enchanting Awakened >>>>>>>>>>>>>>>>>>>>> UpdateLightArmorCount CALLED SUCCESSFULLY (newCount == " + newCount + ")")
EndFunction
