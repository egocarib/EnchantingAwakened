Scriptname EA_Learn_ResistDisease extends EA_Learn_TemplateAME

;active only while in combat, so this will check at the beginning of each combat

;I should also implement a Story Manager event for player gaining a disease, then add experience as long as it lasts.

Quest           property  DiseaseAntenna          auto
ReferenceAlias  property  NearbyDiseaseSpreader1  auto
ReferenceAlias  property  NearbyDiseaseSpreader2  auto
ReferenceAlias  property  NearbyDiseaseSpreader3  auto

ObjectReference diseasedCreature1
ObjectReference diseasedCreature2
ObjectReference diseasedCreature3

Event OnEffectStart(Actor target, Actor caster)
    DiseaseAntenna.start()
    RegisterForSingleUpdate(1.0)
EndEvent

Event OnUpdate()
	if (NearbyDiseaseSpreader1.getReference() as Actor)
		diseasedCreature1 = NearbyDiseaseSpreader1.getReference()
		diseasedCreature2 = NearbyDiseaseSpreader2.getReference()
		diseasedCreature3 = NearbyDiseaseSpreader3.getReference()
		GoToState("Active")
	else
		GoToState("Disabled")
	endif
EndEvent

State Active
	Event OnHit(ObjectReference aggressor, Form source, Projectile proj, bool powAtk, bool snkAtk, bool bashAtk, bool hitBlocked)
		GoToState("Paused")
		if (aggressor == diseasedCreature1 || aggressor == diseasedCreature2 || aggressor == diseasedCreature3)
			learnManager.LearnResistDisease()
			Utility.Wait(7.0)
		endif
		Utility.Wait(3.0)
		GoToState("Active")
	EndEvent
EndState

Event OnEffectFinish(Actor target, Actor caster)
    DiseaseAntenna.stop()
EndEvent