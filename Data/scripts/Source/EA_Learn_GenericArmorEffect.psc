Scriptname EA_Learn_GenericArmorEffect extends EA_Learn_TemplateAME
{generic template for unknown/simple armor effects: learn over time}

int timer

Event OnEffectStart(Actor target, Actor caster)
    RegisterForSingleUpdate(60.0)
EndEvent

Event OnUpdate()
	timer += 1
	if (timer >= 20) ;update every 20 minutes
		ProcessLearned()
	endif
	RegisterForSingleUpdate(60.0)
EndEvent

Event OnEffectFinish(Actor target, Actor caster)
	ProcessLearned()
EndEvent

Function ProcessLearned()
	int learnAmount = timer
	timer = 0
	DoLearn(learnAmount)
EndFunction

Function DoLearn(int amount) ;OVERRIDE THIS FUNCTION IF EXTENDING
	learnManager.LearnUnknownEffect(amount)
EndFunction