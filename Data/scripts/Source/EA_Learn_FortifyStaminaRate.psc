Scriptname EA_Learn_FortifyStaminaRate extends EA_Learn_TemplateAME
;handles FortifyStamina & FortifyStaminaRate

GlobalVariable property EA_LearnActive_Stamina auto
GlobalVariable property EA_LearnActive_StaminaRate auto
GlobalVariable property EA_Learn_StaminaRateEffectSwitch auto

Event OnEffectStart(Actor target, Actor caster)
	bool shouldLearn = (EA_Learn_StaminaRateEffectSwitch.GetValue() == 1.0)
	if shouldLearn
		bool staminaActive = (EA_LearnActive_Stamina.GetValue() >= 1.0)
		bool staminaRateActive = (EA_LearnActive_StaminaRate.GetValue() >= 1.0)
		learnmanager.LearnStamina(staminaActive, staminaRateActive)
		EA_Learn_StaminaRateEffectSwitch.SetValue(0.0)
	else
		EA_Learn_StaminaRateEffectSwitch.SetValue(1.0)
	endif
EndEvent