Scriptname EA_Learn_FortifyHealth extends EA_Learn_TemplateAME

;Effect is active when conditions are met:
;  HasMagicEffect         EnchFortifyHealthConstantSelf   ==   1.00   AND
;  GetActorValuePercent   Health                          <    0.50

float timer

Event OnEffectStart(Actor target, Actor caster)
    timer = Game.GetRealHoursPassed()
EndEvent

Event OnEffectFinish(Actor target, Actor caster)
    learnManager.LearnHealth((Game.GetRealHoursPassed() - timer) * 3600.0) ;convert to seconds
EndEvent