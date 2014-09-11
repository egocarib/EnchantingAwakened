Scriptname EA_Learn_ResistPoison02 extends EA_Learn_TemplateAME
{advances learning whenever the player is hit by a typical "poisonous" creature or actor}

;active only while in combat, so this will check for poisoners at the beginning of each combat

Quest           property  PoisonAntenna    auto
ReferenceAlias  property  NearbyPoisoner1  auto
ReferenceAlias  property  NearbyPoisoner2  auto
ReferenceAlias  property  NearbyPoisoner3  auto

ObjectReference poisonAttacker1
ObjectReference poisonAttacker2
ObjectReference poisonAttacker3

Event OnEffectStart(Actor target, Actor caster)
    PoisonAntenna.start()
    RegisterForSingleUpdate(1.0)
EndEvent

Event OnUpdate()
	if (NearbyPoisoner1.getReference() as Actor)
		poisonAttacker1 = NearbyPoisoner1.getReference()
		poisonAttacker2 = NearbyPoisoner2.getReference()
		poisonAttacker3 = NearbyPoisoner3.getReference()
		GoToState("Active")
	else
		GoToState("Disabled")
	endif
EndEvent

State Active
	Event OnHit(ObjectReference aggressor, Form source, Projectile proj, bool powAtk, bool snkAtk, bool bashAtk, bool hitBlocked)
		GoToState("Paused")
		if (aggressor == poisonAttacker1 || aggressor == poisonAttacker2 || aggressor == poisonAttacker3)
			learnManager.LearnResistPoison()
			Utility.Wait(7.0)
		endif
		Utility.Wait(3.0)
		GoToState("Active")
	EndEvent
EndState

Event OnEffectFinish(Actor target, Actor caster)
    PoisonAntenna.stop()
EndEvent