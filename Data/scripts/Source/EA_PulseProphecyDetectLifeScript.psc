Scriptname EA_PulseProphecyDetectLifeScript extends ActiveMagicEffect

;detect life must be pulse-casted in order to work properly
;for a long duration effect, like the Pulse Prophecy power.
;Otherwise the spell only checks its area of effect once
;when cast and wont detect anything outside of that radius

ObjectReference property playerRef auto
Spell property EA_EssenceEff_PulseProphecyDetectSpell auto


Event onEffectStart(Actor akTarget, Actor akCaster)
	if akTarget == playerRef
		EA_EssenceEff_PulseProphecyDetectSpell.cast(playerRef, playerRef)
		registerForSingleUpdate(1.9)
	endif
EndEvent


Event onUpdate()
	EA_EssenceEff_PulseProphecyDetectSpell.cast(playerRef, playerRef)
	registerForSingleUpdate(1.9)
EndEvent


Event onEffectFinish(Actor akTarget, Actor akCaster)
	unregisterForUpdate() ;technically not needed, spell should unregister by itself when the effect ends
EndEvent
