Scriptname EA_Learn_Waterbreathing extends EA_Learn_TemplateAME
{this effect only starts and remains active while the player is underwater
and below the required Z position - Z is set by EA_Learn_Utility_SwimProbe}

int timer = 1

Event OnEffectStart(Actor target, Actor caster)
	RegisterForSingleUpdate(2.0)
EndEvent

Event OnUpdate()
	timer += 1
	RegisterForSingleUpdate(1.0)
EndEvent

Event OnEffectFinish(Actor target, Actor caster)
	learnManager.LearnWaterbreathing(timer)
EndEvent