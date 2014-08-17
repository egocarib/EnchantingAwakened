Scriptname EA_Learn_FortifyBlock extends EA_Learn_TemplateAME

;Effect is active when conditions are met:
;  HasMagicEffect   EnchFortifyBlockConstantSelf   ==   1.00   AND
;  IsBlocking       NONE                           ==   1.00

Auto State Active
	Event OnHit(ObjectReference aggressor, Form source, Projectile proj, bool powAtk, bool snkAtk, bool bashAtk, bool hitBlocked)
		GoToState("Paused")
		if (hitBlocked)
			learnManager.LearnBlock()
			Utility.Wait(3.0)
		else
			Utility.Wait(1.0)
		endif
		GoToState("Active")
	EndEvent
EndState