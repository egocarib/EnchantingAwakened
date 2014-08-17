Scriptname EA_Learn_FortifyHealRate extends EA_Learn_TemplateAME

;Effect is active when conditions are met:
;  HasMagicEffect         EnchFortifyHealRateConstantSelf   ==   1.00   AND
;  GetGlobalValue         EA_Learn_HealRateEffectSwitch     ==   0.00   OR
;  GetActorValuePercent   Health                            >    0.95   AND
;  GetGlobalValue         EA_Learn_HealRateEffectSwitch     ==   1.00   OR
;  GetActorValuePercent   Health                            <    0.35   AND

GlobalVariable property EA_Learn_HealRateEffectSwitch auto

Event OnEffectStart(Actor target, Actor caster)
	bool shouldLearn = (EA_Learn_HealRateEffectSwitch.GetValue() == 1.0)
	if shouldLearn
		learnmanager.LearnHealRate()
		EA_Learn_HealRateEffectSwitch.SetValue(0.0)
	else
		EA_Learn_HealRateEffectSwitch.SetValue(1.0)
	endif
EndEvent