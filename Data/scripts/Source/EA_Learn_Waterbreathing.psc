Scriptname EA_Learn_Waterbreathing extends EA_Learn_TemplateAME
{this effect only starts and remains active while the player is underwater
and below the required Z position - Z is set by EA_Learn_Utility_SwimProbe}

int timer = 0

Event OnEffectStart(Actor target, Actor caster)
	RegisterForSingleUpdate(3.0)
EndEvent

Event OnUpdate()
	timer += 3
	RegisterForSingleUpdate(3.0)
EndEvent

Event OnEffectFinish(Actor target, Actor caster)
	if (timer == 0)
		timer = 1
	endif
	learnManager.LearnWaterbreathing(timer)
EndEvent