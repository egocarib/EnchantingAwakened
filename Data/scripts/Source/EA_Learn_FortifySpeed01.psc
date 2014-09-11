Scriptname EA_Learn_FortifySpeed01 extends EA_Learn_GenericArmorEffect

;active when player is not sprinting

Function DoLearn(int amount)
	learnManager.LearnSpeed(amount)
EndFunction