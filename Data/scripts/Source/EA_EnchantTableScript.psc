Scriptname EA_EnchantTableScript extends ReferenceAlias

EA_PCDisenchantingControl  property  playerTracker  auto
Actor                      property  playerRef      auto

;ActorValueInfo  property  EnchantingAVInfo           auto hidden
GlobalVariable  property  EA_ModSetupComplete        auto
GlobalVariable  property  EA_EnchTableNPCOverride    auto
GlobalVariable  property  EA_1stPersonMessages       auto
GlobalVariable  property  EA_EnchantMode             auto  ;Perk Conditioner (0 = single enchant mode) (1 = triple enchant mode)
GlobalVariable  property  EA_RemoveTripleDialog      auto  ;(0 = show toggle message) (1 = no message: triple) (2 = no message: single)
Message         property  EAInstallingMsg            auto
Message         property  EAOccupiedTableMsg         auto
Message         property  EATripleEnchantToggle      auto
Message         property  EATripleEnchantToggle1stP  auto
Sound           property  EA_UISelectionSND          auto  ;closest I can find to real menu sound... not sure where its hidden.
Perk[]          property  leveledPowerScalingPerks   auto
Perk            property  EA_ChaoticDissonance       auto  ;triple enchant perk
Perk            property  EA_DisenchantWeaponExpPerk auto  ;add extra experience for weapon disenchanting

;filterFlags retrieved from swf menu hook
int  property  WEAPON_BASIC               = 0x01  autoReadOnly ;item submenu
int  property  WEAPON_ENCHANTED           = 0x02  autoReadOnly ;disenchant submenu
int  property  ARMOR_BASIC                = 0x04  autoReadOnly ;item submenu
int  property  ARMOR_ENCHANTED            = 0x08  autoReadOnly ;disenchant submenu
int  property  ENCHANTMENT_EFFECT_WEAPON  = 0x10  autoReadOnly ;enchantment submenu
int  property  ENCHANTMENT_EFFECT_ARMOR   = 0x20  autoReadOnly ;enchantment submenu
int  property  SOUL_GEM                   = 0x40  autoReadOnly ;soul gem submenu

;float skImpOffset
;float tempOffset
int currentScalePerk
string[] disallowedItemNames ;used to prevent disenchanting of certain items in the crafting menu

Event OnInit()
	registerForSingleUpdate(0.2)
	debug.trace("Enchanting Awakened ::::::::::::::::::::: ENCHANT TABLE SCRIPT loaded")

	RegisterEvents()
EndEvent

Event OnUpdate()
	Game.GetFormFromFile(0x10fb9c, "Skyrim.esm").setPlayerKnows(false)
	Game.GetFormFromFile(0x10fb91, "Skyrim.esm").setPlayerKnows(false)
	Game.GetFormFromFile(0x10fb9d, "Skyrim.esm").setPlayerKnows(false)
	Game.GetFormFromFile(0x10fb95, "Skyrim.esm").setPlayerKnows(false)
	Game.GetFormFromFile(0x10fb96, "Skyrim.esm").setPlayerKnows(false)
	Game.GetFormFromFile(0x10fb97, "Skyrim.esm").setPlayerKnows(false)  ;DEBUG ONLY
	Game.GetFormFromFile(0x10fb92, "Skyrim.esm").setPlayerKnows(false)
	Game.GetFormFromFile(0x10fb93, "Skyrim.esm").setPlayerKnows(false)
	Game.GetFormFromFile(0x10fb94, "Skyrim.esm").setPlayerKnows(false)
	Game.GetFormFromFile(0x10fb98, "Skyrim.esm").setPlayerKnows(false)
	Game.GetFormFromFile(0x10fb99, "Skyrim.esm").setPlayerKnows(false)
	Game.GetFormFromFile(0x10fb9a, "Skyrim.esm").setPlayerKnows(false)
	Game.GetFormFromFile(0x10fb9b, "Skyrim.esm").setPlayerKnows(false)
	Game.GetFormFromFile(0x10fb9d, "Skyrim.esm").setPlayerKnows(false)
	utility.wait(1.0)
	playerRef.additem(Game.GetFormFromFile(0x0ABB26, "Skyrim.esm"), 1, true)
	playerRef.additem(Game.GetFormFromFile(0x0ACC6b, "Skyrim.esm"), 1, true)
	playerRef.additem(Game.GetFormFromFile(0x0acc82, "Skyrim.esm"), 1, true)
	playerRef.additem(Game.GetFormFromFile(0x0acc83, "Skyrim.esm"), 1, true)
	playerRef.additem(Game.GetFormFromFile(0x0acc87, "Skyrim.esm"), 1, true)
	playerRef.additem(Game.GetFormFromFile(0x0bf429, "Skyrim.esm"), 1, true)
EndEvent

Event OnPlayerLoadGame()
	RegisterEvents()
EndEvent

Function RegisterEvents()
	RegisterForModEvent("EA_EnchTableActivate", "OnEnchantTableActivated")
	RegisterForModEvent("EA_OnMenuFocusTypeChange", "OnMenuFocusTypeChange")
	RegisterForModEvent("EA_OnDisallowedItemSelect", "OnDisallowedItemSelect")
EndFunction


Event OnEnchantTableActivated(Form akTable)
	goToState("ActivatedState")
		debug.trace("Enchanting Awakened ::::::::::::::::::::: ENCHANT TABLE SCRIPT OnEnchantTableActivated event beginning...")
		ObjectReference objTable = akTable as ObjectReference
		if (!objTable.IsFurnitureInUse())

			;UPDATE POWER SCALING PERK BASED ON PLAYER LEVEL
			int lastPerk = currentScalePerk
			playerRef.removePerk(leveledPowerScalingPerks[lastPerk])
			int iLvl = ((playerRef.getActorValue("Enchanting") * 0.1) as int) - 1
			if iLvl > 14   ;(if Enchanting >= 160) [capped here for now]
				iLvl = 14
			elseif iLvl < 0  ;(if players Enchanting level is below 10 for some reason)
				iLvl = 0
			endif
			playerRef.addPerk(leveledPowerScalingPerks[iLvl])
			currentScalePerk = iLvl

			RegisterForMenu("Crafting Menu")


			playerTracker.PreAttachToTable(objTable)

			disallowedItemNames = new string[128]
			EA_Extender.GetFormNames(playerTracker.GetRestrictedItems(), disallowedItemNames)

			objTable.Activate(playerRef, true)


			if (playerRef.HasPerk(EA_ChaoticDissonance))
				if (EA_RemoveTripleDialog.GetValue() == 1) ;triple enchant mode
					EA_EnchantMode.SetValue(1)
				elseif (EA_RemoveTripleDialog.GetValue() == 2) ;single enchant mode
					EA_EnchantMode.SetValue(0)
				else ;messagebox to choose mode
					EA_RemoveTripleDialog.SetValue(0)
					displayToggleMenu()
				endIf
			endIf

			utility.waitmenumode(2.0) ;Safety wait 
		elseif EA_EnchTableNPCOverride.getValue() == 1
			objTable.Activate(playerRef, true)
		else
			EAOccupiedTableMsg.Show() ;"Someone else is using this"
		endif
	GoToState("")
EndEvent


Event OnMenuOpen(string kMenu)
	string EAMenuInstance = "_global.Main.EnchantingAwakenedMenuMonitor"

	string[] args = new string[2]
	args[0] = "EA_MenuMonitorContainer"
	args[1] = "-8080"

	debug.trace("Enchanting Awakened ::::::::::::::::::::: ENCHANT TABLE SCRIPT injecting swf into enchant menu")

	UI.InvokeStringA("Crafting Menu", "_root.createEmptyMovieClip", args) ; Create empty container clip
	UI.InvokeString("Crafting Menu", "_root.EA_MenuMonitorContainer.loadMovie", "EnchantingAwakened\\EnchantMenuMonitor.swf") ; Load SWF into container

	utility.waitmenumode(0.1) ;not sure if this is still necessary
	UI.InvokeStringA("Crafting Menu", EAMenuInstance + ".RegisterDisallowedItems", disallowedItemNames)
EndEvent


Event OnMenuClose(string kMenu)
	UnregisterForMenu("Crafting Menu")
	if hasExperiencePerk
		playerRef.removePerk(EA_DisenchantWeaponExpPerk)
		hasExperiencePerk = false
	endif
EndEvent


Event OnDisallowedItemSelect(string _eventName, string _itemName, float _null1, Form _null2)
	debug.notification("Disallowed Item Selected: " + _itemName)
	EA_UISelectionSND.play(playerRef)
EndEvent


bool hasExperiencePerk
Event OnMenuFocusTypeChange(string _eventName, string _itemName, float _itemCode, Form _null)

	if _itemCode == WEAPON_ENCHANTED ;Add extra experience for disenchanting weapons

		if !hasExperiencePerk
			playerRef.addPerk(EA_DisenchantWeaponExpPerk)
			hasExperiencePerk = true
		endif

	elseif hasExperiencePerk

		playerRef.removePerk(EA_DisenchantWeaponExpPerk)
		hasExperiencePerk = false

	endif

	;debug
		;in summary -- dropping the object while at table to get object ref is possible, but leads to slight blink of object that is visible
		;
		;	bool _debug = false
		; 	ObjectReference dropped
		;
		; 	; 	debug.messagebox("Would you like to remove the enchantment from " + _itemName + "?")
		; 	;	playerRef.removeitem(Game.GetFormFromFile(0x028433, "Dragonborn.esm")) ;TRY TO FIND OUT if displays in the same order as player inventory? or what... I think alphabetical, but how does it handle duplicate names? order by formID?
		; 		if _itemName == "Stinger"
		; 			dropped = playerRef.dropobject(Game.GetFormFromFile(0x012eb7, "Skyrim.esm"))
		; 			dropped.setEnchantment(none, 0)
		; 			dropped.setDisplayName(dropped.GetBaseObject().GetName())
		; 			dropped.activate(playerRef)
		;
		; 			UI.Invoke("Crafting Menu", "_global.Main.EnchantingAwakenedMenuMonitor.doStuff")
		; 		endif
		; 	; 	if playerRef.getItemCount(Game.GetFormFromFile(0x028433, "Dragonborn.esm"))
		; 	; 		dropped = playerRef.dropObject(Game.GetFormFromFile(0x028433, "Dragonborn.esm"))

EndEvent


function DisplayToggleMenu()
	int buttonSelected
	if EA_1stPersonMessages.getValue()
		buttonSelected = EATripleEnchantToggle1stP.Show()
	else
		buttonSelected = EATripleEnchantToggle.Show()
	endif

	if (!buttonSelected)
		EA_EnchantMode.SetValue(1)    ;triple enchant mode
	elseif (buttonSelected)
		EA_EnchantMode.SetValue(0)    ;single enchant mode
	endIf
endFunction


State ActivatedState
	Event OnEnchantTableActivated(Form akTable)
	EndEvent
EndState


Auto State NotInstalled
	Event OnEnchantTableActivated(Form akTable)
		if EA_ModSetupComplete.getValue()
			playerRef.addPerk(leveledPowerScalingPerks[0])
			GoToState("")
			OnEnchantTableActivated(akTable as ObjectReference)
		else
			EAInstallingMsg.show()
		endif
	EndEvent
EndState