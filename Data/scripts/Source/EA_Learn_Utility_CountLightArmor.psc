Scriptname EA_Learn_Utility_CountLightArmor extends ActiveMagicEffect

EA_Learn_OnHit property learnManager auto
int property pieceCount auto

Event OnEffectStart(Actor akTarget, Actor akCaster)
    learnManager.UpdateLightArmorCount(pieceCount)
EndEvent