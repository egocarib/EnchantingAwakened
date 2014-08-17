Scriptname EA_Learn_OnHit extends ReferenceAlias

float property LearnTotal     auto ;accumulated Learning points
float property LearnIncrement auto ;amount to add to LearnTotal

bool  property  isBlockLearning       auto
bool  property  isHeavyArmorLearning  auto
bool  property  isLightArmorLearning  auto

float  property  LearnTotal_FortifyBlock       auto
float  property  LearnTotal_FortifyHeavyArmor  auto
float  property  LearnTotal_FortifyLightArmor  auto

float  property  FortifyBlockPts       auto
float  property  FortifyHeavyArmorPts  auto
float  property  FortifyLightArmorPts  auto

; Function Activate(string learnType)
; 	SetLearningState(learnType, true)
; EndFunction

; Function Deactivate(string learnType)
; 	SetLearningState(learnType, false)
; EndFunction

; Function SetLearningState(string learnType, bool newBool)
; 	if (learnType == "FortifyBlock")
; 		isBlockLearning == newBool
; 	elseif (learnType == "FortifyHeavyArmor")
; 		isHeavyArmorLearning = newBool
; 	elseif (learnType == "FortifyLightArmor")
; 		isLightArmorLearning = newBool
; 	endif

; 	if (isBlockLearning)
; 		if (isHeavyArmorLearning || isLightArmorLearning)
; 			GoToState("Active_All")
; 		else
; 			GoToState("Active_Block")
; 		endif
; 	elseif (isHeavyArmorLearning || isLightArmorLearning)
; 		GoToState("Active_Armor")
; 	endif
; EndFunction


; State Active_Block
; 	Event OnHit(ObjectReference aggressor, Form source, Projectile proj, bool powAtk, bool snkAtk, bool bashAtk, bool hitBlocked)
; 		if (hitBlocked)
; 			LearnTotal_FortifyBlock += FortifyBlockPts
; 			Pause(3.0)
; 		else
; 			Pause(1.0)
; 		endif
; 	EndEvent
; EndState

; State Active_Both
; 	Event OnHit(ObjectReference aggressor, Form source, Projectile proj, bool powAtk, bool snkAtk, bool bashAtk, bool hitBlocked)

; 		if (source as Weapon) ; || bashAtk) [lets keep this simple]
; 			LearnTotal_FortifyLightArmor += FortifyLightArmorPts
; 			LearnTotal_FortifyHeavyArmor += FortifyHeavyArmorPts
; 			if (hitBlocked)
; 				LearnTotal_FortifyBlock += FortifyBlockPts
; 			endif
; 			Pause(3.0)

; 		elseif (hitBlocked)
; 			LearnTotal_FortifyBlock += FortifyBlockPts
; 			Pause(3.0)

; 		else
; 			Pause(1.0)

; 		endif
; 	EndEvent
; EndState




; State Paused
; 	Event OnHit(ObjectReference aggressor, Form source, Projectile proj, bool powAtk, bool snkAtk, bool bashAtk, bool hitBlocked)
; 	EndEvent
; EndState

; Function Pause(float pauseInterval)
; 	GoToState("Paused")
; 	Utility.Wait(pauseInterval)
; 	GoToState("Active")
; EndFunction


Function LearnBlock()
	debug.notification("LearnBlock called successfully")
	debug.trace("Enchanting Awakened >>>>>>>>>>>>>>>>>>>>> LearnBlock CALLED SUCCESSFULLY IN THE REFERENCE ALIAS")
EndFunction
Function LearnHeavyArmor()
	debug.notification("LearnHeavyArmor called successfully")
	debug.trace("Enchanting Awakened >>>>>>>>>>>>>>>>>>>>> LearnHeavyArmor CALLED SUCCESSFULLY IN THE REFERENCE ALIAS")
EndFunction
Function LearnLightArmor()
	debug.notification("LearnLightArmor called successfully")
	debug.trace("Enchanting Awakened >>>>>>>>>>>>>>>>>>>>> LearnLightArmor CALLED SUCCESSFULLY IN THE REFERENCE ALIAS")
EndFunction
Function LearnHealth(float modifier)
	debug.notification("LearnHealth called successfully")
	debug.trace("Enchanting Awakened >>>>>>>>>>>>>>>>>>>>> LearnHealth CALLED SUCCESSFULLY IN THE REFERENCE ALIAS (modifier == " + modifier + ")")
EndFunction
Function LearnHealRate(float modifier)
	debug.notification("LearnHealRate called successfully")
	debug.trace("Enchanting Awakened >>>>>>>>>>>>>>>>>>>>> LearnHealth CALLED SUCCESSFULLY IN THE REFERENCE ALIAS (modifier == " + modifier + ")")
EndFunction
Function LearnMagickaRate()
	debug.notification("LearnMagickaRate called successfully")
	debug.trace("Enchanting Awakened >>>>>>>>>>>>>>>>>>>>> LearnMagickaRate CALLED SUCCESSFULLY IN THE REFERENCE ALIAS")
EndFunction


Function UpdateHeavyArmorCount(int newCount)
	debug.trace("Enchanting Awakened >>>>>>>>>>>>>>>>>>>>> UpdateHeavyArmorCount CALLED SUCCESSFULLY IN THE REFERENCE ALIAS (newCount == " + newCount + ")")
EndFunction
Function UpdateLightArmorCount(int newCount)
	debug.trace("Enchanting Awakened >>>>>>>>>>>>>>>>>>>>> UpdateLightArmorCount CALLED SUCCESSFULLY IN THE REFERENCE ALIAS (newCount == " + newCount + ")")
EndFunction