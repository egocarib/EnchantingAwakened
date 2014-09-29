Scriptname EA_Learn_FortifySmithing extends EA_Learn_TemplateAME

ActorValueInfo      smithingAVI
int       property  kID_Smithing = 10         autoreadonly
Keyword   property  CraftingSmithingForge     auto
Keyword[] property  altSmithKeys              auto

Form  recentCraftedItem01
Form  recentCraftedItem02
float currentXP
float forgeExperienceModifier = 1.0
float miscExperienceModifier = 0.5


Event OnMenuOpen(string menu)
	UnregisterForUpdate()
	ObjectReference workbench = playerRef.GetFurnitureReference()
	if (workbench.HasKeyword(CraftingSmithingForge))
		GoToState("CraftingForgeState")
	elseif (workbench.HasKeyword(altSmithKeys[0])  ;/CraftingSmithingArmorTable/;      \
		||  workbench.HasKeyword(altSmithKeys[1])  ;/CraftingSmithingSharpeningWheel/; \
		||  workbench.HasKeyword(altSmithKeys[2])  ;/CraftingTanningRack/;             \
		||  workbench.HasKeyword(altSmithKeys[3])) ;/CraftingSmelter/;
		GoToState("CraftingOtherState")
	endif
EndEvent

Event OnMenuClose(string menu)
	GoToState("")
	RegisterForSingleUpdate(600.0)
EndEvent

Event OnUpdate()
	;reset forge modifier after ten minutes away from craft stations
	forgeExperienceModifier = 1.0
EndEvent


State CraftingForgeState
	Event OnItemAdded(Form baseItem, int count, ObjectReference itemRef, ObjectReference destination)
	    if (baseItem as Weapon || baseItem as Armor) ;new item crafted by player
			if (baseItem == recentCraftedItem01)
				forgeExperienceModifier *= 0.92 ;must rotate 3+ items or experience will decrease exponentially
			elseif (baseItem == recentCraftedItem02)
				forgeExperienceModifier *= 0.95 ;less severe decrease when rotating at least two items
				recentCraftedItem02 = recentCraftedItem01
				recentCraftedItem01 = baseItem
			else ;new item crafted different from previous two, restore skill gain to full amount
				forgeExperienceModifier = 1.0
				recentCraftedItem02 = recentCraftedItem01
				recentCraftedItem01 = baseItem
			endif
			learnManager.LearnSmithing(forgeExperienceModifier)
	    endif
	EndEvent
EndState

State CraftingOtherState
	Event OnBeginState()
		currentXP = smithingAVI.GetSkillExperience()
		miscExperienceModifier = 0.5 ;reset
		RegisterForModEvent("EA_CraftAltEvent", "OnMonitorAlternativeCrafting")
		SendModEvent("EA_CraftAltEvent", "", 0.0)
	EndEvent

	;grant XP whenever player completes a crafting action that nets them Smithing experience
	Event OnMonitorAlternativeCrafting(string evnName, string strArg, float numArg, Form sender)
	    UnregisterForModEvent("EA_CraftAltEvent")
		int safteyLimiter = 0
		int craftCount = 0
		while ((GetState() == "CraftingOtherState") && safteyLimiter < 1800)
			utility.waitmenumode(1.0)
			float checkXP = smithingAVI.GetSkillExperience()
			if (checkXP > currentXP)
				learnManager.LearnSmithing(miscExperienceModifier)
				miscExperienceModifier *= 0.95
				currentXP = checkXP
				craftCount += 1
			endif
			safteyLimiter += 1
		endWhile
		;restore forge experience modifier, since player varied things up --->
		if (craftCount >= 3)
			forgeExperienceModifier = 1.0
		elseif (craftCount > 0)
			forgeExperienceModifier += (((1.0 - forgeExperienceModifier) / 3.0) * (craftCount as float))
		endif
	EndEvent
EndState

;EMPTY STATE
Event OnMonitorAlternativeCrafting(string evnName, string strArg, float numArg, Form sender)
EndEvent
;EMPTY STATE

Event OnInit()
    RegisterForMenu("Crafting Menu")
    smithingAVI = ActorValueInfo.GetActorValueInfoByID(kID_Smithing)
EndEvent

Event OnPlayerLoadGame()
    RegisterForMenu("Crafting Menu")
EndEvent