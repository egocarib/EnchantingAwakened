Scriptname EA_Learn_Utility_PoisonedIndicator extends EA_Learn_TemplateAME
{applied only when player is hit by a Poison Bloom or poison dart/gas trap}

Event OnEffectStart(Actor target, Actor caster)
    learnManager.LearnResistPoison(15.0)
EndEvent