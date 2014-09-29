Scriptname EA_Learn_EffectInformant extends ActiveMagicEffect






;;
;;              NOW DEPRICATED       -      (using internal plugin to detect enchantment equip events instead of attaching this to all MGEFs)
;;







;There was a time when I considered enabling this for all actors... but really not worth the headache.

Form thisHereThing

Event OnEffectStart(Actor target, Actor caster)
    ;fun fact - You can call Game.GetFormFromFile 682 times and be finished
    ;with all those before a single call to Game.GetPlayer() returns
    if (Game.GetFormFromFile(0x14, "Skyrim.esm") == (target as Form))
        thisHereThing = GetBaseObject() as Form
        LearnInform(true)
    endif
EndEvent

Event OnEffectFinish(Actor target, Actor caster)
    if (thisHereThing)
        LearnInform(false)
    endif
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