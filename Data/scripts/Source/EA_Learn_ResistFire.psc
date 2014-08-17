Scriptname EA_Learn_ResistFire extends EA_Learn_TemplateAME

GlobalVariable property EA_Learn_ResistFireEffectSwitch auto

Event OnEffectStart(Actor target, Actor caster)
    EA_Learn_ResistFireEffectSwitch.SetValue(1.0)
    learnManager.LearnResistFire()
    Utility.Wait(15.0)
    EA_Learn_ResistFireEffectSwitch.SetValue(0.0)
EndEvent