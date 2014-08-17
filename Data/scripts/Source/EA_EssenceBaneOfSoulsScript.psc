Scriptname EA_EssenceBaneOfSoulsScript extends ActiveMagicEffect

Spell property baneSpell auto
Spell property baneSpellWeak auto ;half strength spell used against skeletons and draugr
Spell property abSkeleton auto
Spell property abDraugr auto
objectReference property playerRef auto

;/
Event onEffectStart(Actor akTarget, Actor akCaster)
	debug.notification("BaneOfSouls Effect STARTED")
EndEvent

Event onEffectFinish(Actor akTarget, Actor akCaster)
	debug.notification("BaneOfSouls Effect FINISHED")
EndEvent
/;

Event onHit(ObjectReference akAggressor, Form akSource, Projectile akProjectile, bool abPowerAttack, bool abSneakAttack, bool abBashAttack, bool abHitBlocked)
	Actor akAct = akAggressor as Actor
	if akAct
		if akAct.isHostileToActor(playerRef as actor)
			if akAct.hasSpell(abDraugr) || akAct.hasSpell(abSkeleton)
				akAct.dispelSpell(baneSpellWeak)
				baneSpellWeak.cast(playerRef, akAggressor)
			else
				akAct.dispelSpell(baneSpell)
				baneSpell.cast(playerRef, akAggressor)
			endif
		endif
	endif
EndEvent