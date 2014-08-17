Scriptname EA_SoulstrikerCloakScript extends ActiveMagicEffect  

Spell property EA_Essence_SoulstrikerAppliedSpell auto
objectReference cloakSource
objectReference cloakVictim


Event OnEffectStart(Actor akTarget, Actor akCaster)
	cloakSource = akCaster as objectReference
	cloakVictim = akTarget as objectReference
EndEvent


Event onHit(ObjectReference akAggressor, Form akSource, Projectile akProjectile, bool abPowerAttack, bool abSneakAttack, bool abBashAttack, bool abHitBlocked)
	if akAggressor == cloakSource
		EA_Essence_SoulstrikerAppliedSpell.cast(cloakSource, cloakVictim)
	endif
EndEvent