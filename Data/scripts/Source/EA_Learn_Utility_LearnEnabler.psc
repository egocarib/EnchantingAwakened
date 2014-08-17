Scriptname EA_Learn_Utility_LearnEnabler extends ActiveMagicEffect

EA_Learn_Controller  property  learnManager   auto
int                  property  enchantTypeID  auto

;/
	enchantTypeID:
	``````````````
	0 = FortifyAlteration
	1 = FortifyConjuration
	2 = FortifyDestruction
	3 = FortifyIllusion
	4 = FortifyRestoration
	5 = FortifyMagicka
	6 = ResistFire  ?
	7 = ResistFrost ?
	8 = ResistShock ?
/;

Event OnEffectStart(Actor akTarget, Actor akCaster)
    learnManager.SetEnabled(enchantTypeID, true)
EndEvent

Event OnEffectFinish(Actor akTarget, Actor akCaster)
    learnManager.SetEnabled(enchantTypeID, false)
EndEvent