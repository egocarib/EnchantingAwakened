Scriptname EA_Learn_FortifySpeed02 extends EA_Learn_TemplateAME

;active when player is sprinting

int timer

Event OnEffectStart(Actor target, Actor caster)
    RegisterForSingleUpdate(1.0)
EndEvent

Event OnUpdate()
	timer += 1
	RegisterForSingleUpdate(1.0)
EndEvent

Event OnEffectFinish(Actor target, Actor caster)
    learnManager.LearnSpeed(timer)
EndEvent