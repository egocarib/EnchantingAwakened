Scriptname EA_Learn_EffectInformant extends ActiveMagicEffect

Form thisHereThing

Event OnEffectStart(Actor target, Actor caster)
    thisHereThing = GetBaseObject() as Form
    LearnInform(true)
EndEvent

Event OnEffectFinish(Actor target, Actor caster)
    LearnInform(false)
EndEvent


Function LearnInform(bool starting)
    int eventCode = ModEvent.Create("EA_LearnInform")
    if (eventCode)
    	ModEvent.PushForm(eventCode, thisHereThing)
    	ModEvent.PushBool(eventCode, starting)
    	ModEvent.Send(eventCode)
    else
		debug.trace("Enchanting Awakened ::: Error attempting to propagate \"EA_LearnInform\" event [TYPE: " + starting + "]")
    endif
EndFunction