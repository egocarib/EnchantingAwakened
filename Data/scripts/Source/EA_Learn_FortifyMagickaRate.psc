Scriptname EA_Learn_FortifyMagickaRate extends EA_Learn_TemplateAME

;Effect is active when conditions are met:
;  HasMagicEffect         EnchFortifyMagickaRateConstantSelf   ==   1.00   AND
;  GetGlobalValue         EA_Learn_MagickaRateEffectSwitch     ==   0.00   OR
;  GetActorValuePercent   Magicka                              >    0.95   AND
;  GetGlobalValue         EA_Learn_MagickaRateEffectSwitch     ==   1.00   OR
;  GetActorValuePercent   Magicka                              <    0.20

GlobalVariable property EA_Learn_MagickaRateEffectSwitch auto

Event OnEffectStart(Actor target, Actor caster)
	bool shouldLearn = (EA_Learn_MagickaRateEffectSwitch.GetValue() == 1.0)
	if shouldLearn
		learnmanager.LearnMagickaRate()
		EA_Learn_MagickaRateEffectSwitch.SetValue(0.0)
	else
		EA_Learn_MagickaRateEffectSwitch.SetValue(1.0)
	endif
EndEvent