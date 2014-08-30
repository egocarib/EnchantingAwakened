Scriptname EA_Learn_Utility_SwimProbe extends ActiveMagicEffect
{script to update water height, which is used to conditionalize waterbreathing learn ability}

;becomes active when player IsSwimming

;I tried registering for animation event SoundPlay.FSTSwimSwim, but turns out this was firing
;even deep underwater sometimes and resulted in waterheight getting set way below surface.

Actor           property  playerRef                           auto
GlobalVariable  property  EA_LearnUtility_CurrentWaterHeight  auto

Event OnEffectStart(Actor target, Actor caster)
	;record initial Z position. This is sometimes below true water surface
	;when jumping into the water from above, but still works well enough.
	float playerHeight = playerRef.GetPositionZ()
	;40 is max Z distance player must descend after IsSwimming condition
	;becomes true in order to ensure they are completely underwater.
	EA_LearnUtility_CurrentWaterHeight.SetValue(playerHeight - 40.0)
EndEvent

Event OnEffectFinish(Actor target, Actor caster)
	;this is to stall EA_Learn_Waterbreathing effect until the correct water
	;surface level is set during next swim event & confirm player is underwater
	EA_LearnUtility_CurrentWaterHeight.SetValue(-1000000000.0)
EndEvent