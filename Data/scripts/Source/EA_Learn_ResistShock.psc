Scriptname EA_Learn_ResistShock extends EA_Learn_TemplateAME

GlobalVariable property EA_Learn_ResistShockEffectSwitch auto

Event OnEffectStart(Actor target, Actor caster)
    EA_Learn_ResistShockEffectSwitch.SetValue(1.0)
    learnManager.LearnResistShock()
    Utility.Wait(15.0)
    EA_Learn_ResistShockEffectSwitch.SetValue(0.0)
EndEvent