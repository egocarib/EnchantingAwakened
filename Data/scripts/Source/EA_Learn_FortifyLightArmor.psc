Scriptname EA_Learn_FortifyLightArmor extends EA_Learn_TemplateAME

;Effect is active when conditions are met:
;  HasMagicEffect               EnchFortifyLightArmorConstantSelf   ==   1.00   AND
;  WornApparelHasKeywordCount   ArmorLight                          >=   1.00 

Spell property EA_LearnUtility_LightArmorCountUpdateSpell auto

Auto State Active
	Event OnHit(ObjectReference aggressor, Form source, Projectile proj, bool powAtk, bool snkAtk, bool bashAtk, bool hitBlocked)
		GoToState("Paused")
		if (source as Weapon)
			learnManager.LearnLightArmor()
			Utility.Wait(10.0)
		else
			Utility.Wait(5.0)
		endif
		GoToState("Active")
	EndEvent
EndState

Event OnEffectStart(Actor target, Actor caster)
	UpdateLightArmorCount()
EndEvent

Event OnObjectEquipped(Form baseObject, ObjectReference ref)
	if (baseObject as Armor)
		UpdateLightArmorCount()
	endif
EndEvent

Event OnObjectUnequipped(Form baseObject, ObjectReference ref)
	if (baseObject as Armor)
		UpdateLightArmorCount()
	endif
EndEvent

Function UpdateLightArmorCount()
	registerForSingleUpdate(3.0) ;equip event spamkiller (new registrations will cancel previous)
EndFunction

Event OnUpdate()
	EA_LearnUtility_LightArmorCountUpdateSpell.cast(playerRef, playerRef)
	;count light armor pieces and update number in main OnHit referenceAlias script
	;(using WornApparelHasKeywordCount condition functions, which have no easy script equivalent)
EndEvent