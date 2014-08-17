Scriptname EA_Learn_Utility_CountHeavyArmor extends ActiveMagicEffect

EA_Learn_OnHit property learnManager auto
int property pieceCount auto

Event OnEffectStart(Actor akTarget, Actor akCaster)
    learnManager.UpdateHeavyArmorCount(pieceCount)
EndEvent