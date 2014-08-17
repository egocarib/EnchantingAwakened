Scriptname EA_SpeedMultMGEFActivator extends ActiveMagicEffect

;This script applies an invisible carryweight modifier
;to the target of the magic effect, which will force
;the game to register any Speed Multiplier changes.

Event onEffectStart(Actor akTarget, Actor akCaster)
	akTarget.modActorValue("CarryWeight", 0.01)
EndEvent

Event onEffectFinish(Actor akTarget, Actor akCaster)
	akTarget.modActorValue("CarryWeight", -0.01)
EndEvent