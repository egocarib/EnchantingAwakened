Scriptname EA_Learn_ResistFrost extends EA_Learn_TemplateAME

GlobalVariable property EA_Learn_ResistFrostEffectSwitch auto

Event OnEffectStart(Actor target, Actor caster)
    EA_Learn_ResistFrostEffectSwitch.SetValue(1.0)
    learnManager.LearnResistFrost()
    Utility.Wait(15.0)
    EA_Learn_ResistFrostEffectSwitch.SetValue(0.0)
EndEvent