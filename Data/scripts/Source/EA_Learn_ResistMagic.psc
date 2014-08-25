Scriptname EA_Learn_ResistMagic extends EA_Learn_TemplateAME

MagicEffect cachedMgef
bool        hostile

Auto State Active
	Event OnMagicEffectApply(ObjectReference caster, MagicEffect mgef)
		GoToState("Paused")
			if (caster != playerRef)
				if (mgef != cachedMgef)
					hostile = mgef.isEffectFlagSet(0x01) ;hostile
					cachedMgef = mgef
				endif
				if (hostile) ;hostile
					learnManager.LearnResistMagic()
				endif
				Utility.Wait(10.0)
			endif
			Utility.Wait(5.0)
	    GoToState("Active")
	EndEvent
EndState