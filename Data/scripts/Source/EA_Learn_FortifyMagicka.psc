Scriptname EA_Learn_FortifyMagicka extends EA_Learn_TemplateAME

;Effect is active when conditions are met:
;  HasMagicEffect   EnchFortifyMagickaConstantSelf   ==   1.00

Auto State Active
	Event OnSpellCast(Form casted)
	    GoToState("Paused")
	    	if (casted as Spell)
	    		learnManager.LearnMagicka()
				Utility.Wait(15.0)
			else ;potion/ingredient/enchantment
				Utility.Wait(5.0)
			endif
	    GoToState("Active")
	EndEvent
EndState