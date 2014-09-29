Scriptname EA_Learn_FortifyMagic extends EA_Learn_TemplateAME

GlobalVariable[]  property  typeEnabled  auto ;Globals indicating if the effect is learn-enabled (player is wearing an enchantment with that effect)

int     spellType
Form[]  cachedSpells
bool[]  isDelaying
bool[]  isDeactivated

Auto State Active
	Event OnSpellCast(Form casted)
    	GoToState("Paused")
		    if (casted as Spell)
		    	spellType = cachedSpells.find(casted)
		    	if (spellType < 0)
		    		spellType = EA_Extender.GetSpellSkillNumber(casted as Spell)
		    	endif
		    	if (spellType >= 0)
		    		cachedSpells[spellType] = casted
		    		if (!isDelaying[spellType])
					    SendModEvent("EA_DelaySpellTypeLearning", "", spellType)
			    		learnManager.LearnMagic(spellType, casted)
		    		endif
		    	endif
		    endif
		    Utility.WaitMenuMode(1.0)
    	GoToState("Active")
	EndEvent
EndState


Event OnDelaySpellType(string evnName, string strArg, float numArg, Form sender)
	int type = numArg as int
	isDelaying[type] = true
	Utility.Wait(5.0)
	isDelaying[type] = isDeactivated[type]
EndEvent

Event OnUpdateActiveEffects(string evnName, string strArg, float numArg, Form sender)
	int i = 5
	while (i)
		i -= 1
		isDeactivated[i] = (typeEnabled[i].GetValue() < 1.0)
		isDelaying[i] = isDeactivated[i]
	endWhile
EndEvent


Event OnInit()
    isDelaying    = new bool[5]
    isDeactivated = new bool[5]
    cachedSpells  = new Form[5]
    OnPlayerLoadGame()
    OnUpdateActiveEffects("", "", 0, none)
EndEvent

Event OnPlayerLoadGame()
    RegisterForModEvent("EA_DelaySpellTypeLearning", "OnDelaySpellType")
    RegisterForModEvent("EA_UpdateActiveLearnEffects", "OnUpdateActiveEffects")
EndEvent