Scriptname EA_EssenceNemesisFinishFX extends ActiveMagicEffect

EffectShader property EA_EssenceNemesisFinishFXShader auto

Event onEffectFinish(Actor akTarget, Actor akCaster)
  EA_EssenceNemesisFinishFXShader.play(akTarget, 4.0)
EndEvent