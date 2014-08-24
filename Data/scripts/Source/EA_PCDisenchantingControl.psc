Scriptname EA_PCDisenchantingControl extends ReferenceAlias
{item tracker to prevent disenchanting without relevant perks}

	EA_PCTrackerSatellite  property  TrackerSatellite       auto
	Actor                  property  playerRef              auto
	GlobalVariable         property  EA_ModSetupComplete    auto ;Player can't activate Enchanting Table or choose Perks until true

	;PerkState variables are updated via perk quest script fragments whenever a new perk is gained:
	int            property  PerkStateCore                  auto hidden ;0 = NO SoulShaper perks   1 = SoulShaper01    2 = SoulShaper02   3 = SoulShaper03
	int            property  PerkStateSpecial               auto hidden ;0 = NO specialist perks   1 = AetherStrider   2 = ChaosMaster    3 = CorpusGuardian
	Formlist[]     property  PerkLinkedEnchantmentsCore     auto
	Formlist[]     property  PerkLinkedEnchantmentsSpecial  auto
	Enchantment[]  property  PerkLinkedEnchantmentsALL      auto ;All known enchantments, checked against possible custom enchantments added by other mods
	Keyword        property  MagicDisallowEnchanting        auto

	Form[]         RestrictedItems
	Keyword[]      RestrictedKeywords
	Enchantment[]  RestrictedEnchants
	int            rINDEX ;master index for Restricted arrays, kept always at the next open spot in array.

	;MCM options
	GlobalVariable property EA_ShowDisenchantableItems auto

	;constants for ProcessPlayerItems():
	int property INSTALL = 0x06 autoreadonly
	int property SCRUB   = 0x04 autoreadonly
	int property REBUILD = 0x02 autoreadonly
	int property REDUCE  = 0x01 autoreadonly

	;constants for EA_Extender.CheckFormForEnchantment (used in OnItemAdded)
	int property kForm            = 0 autoreadonly
	int property kBaseEnchantment = 1 autoreadonly
	int property kKeyword         = 2 autoreadonly


Event OnInit()
	registerForSingleUpdate(0.001)
EndEvent

Auto State InitState
	Event OnUpdate()
		ProcessPlayerItems(INSTALL)
		RegisterForModEvent("EA_TrackedItemRemoved", "OnTrackedItemRemoved")
		EA_ModSetupComplete.setValue(1.0)
		GoToState("")
	EndEvent

	Event OnItemAdded(Form akBaseItem, int aiItemCount, ObjectReference akItemReference, ObjectReference akSourceContainer)
		while (GetState() == "InitState")
			utility.waitmenumode(1.0)
		endWhile
		OnItemAdded(akBaseItem, aiItemCount, akItemReference, akSourceContainer)
	EndEvent
	Function UpdateRestrictions()
	EndFunction
EndState


Event OnPlayerLoadGame()
	RegisterForModEvent("EA_TrackedItemRemoved", "OnTrackedItemRemoved")
EndEvent


Form[] Function GetRestrictedItems()
	return RestrictedItems
EndFunction


;;Potential problem/ or thing to keep in mind: If I allow unlearning of enchantments, players may still have player-enchanted
;;version of the enchantment. Could they learn the enchantment from that then? or are all player enchants non-disencchantable?
;;the CheckFormForEnchantment below obviously doesn't check player-enchantments, only enchantments on the base form.

Event OnItemAdded(Form akBaseItem, int aiItemCount, ObjectReference akItemReference, ObjectReference akSourceContainer)
	if (akBaseItem as Armor || akBaseItem as Weapon)
		Form[] addedItemData = new Form[3] ; [item form, base enchantment, 0-index keyword]
		if (EA_Extender.CheckFormForEnchantment(akBaseItem, addedItemData))
			if (!CanDisenchant(addedItemData[kBaseEnchantment] as Enchantment))
				AddRestriction(addedItemData)
			endif
		endIf
	endif
EndEvent



Event OnTrackedItemRemoved(Form akBaseItem)
	debug.trace("Enchanting Awakened ::::::::::::::::::::: OnTrackedItemRemoved triggered -- " + akBaseItem.getName())
	rLOCK = true
		int testIndex = RestrictedItems.find(akBaseItem)
		if testIndex >= 0 && !playerRef.getItemCount(akBaseItem)
			debug.trace("Enchanting Awakened :::::::::::::::::::::   " + akBaseItem.getName() + " found at index " + testIndex + " of RestrictedItems[], beginning removal")
			rINDEX -= 1
			RestrictedItems[testIndex] = RestrictedItems[rINDEX]
			RestrictedKeywords[testIndex] = RestrictedKeywords[rINDEX]
			RestrictedEnchants[testIndex] = RestrictedEnchants[rINDEX]
			RestrictedItems[rINDEX] = none
			RestrictedKeywords[rINDEX] = none
			RestrictedEnchants[rINDEX] = none
			TrackerSatellite.RemoveInventoryEventFilter(akBaseItem)
			debug.trace("Enchanting Awakened :::::::::::::::::::::   FILTER: removed filter " + akBaseItem.getName() + " from Removal Tracker")
		endIf
	rLock = false
EndEvent


bool scrubKeywords = false
Function PreAttachToTable(ObjectReference akTable) ;Called from enchanting table
	debug.trace("Enchanting Awakened ::::::::::::::::::::: Attaching to table, lock engaged....")
	rLOCK = true

		scrubKeywords = (EA_ShowDisenchantableItems.GetValue() != 1.0)
		if (scrubKeywords)
			EA_Extender.SetFormArrayNthKeyword(RestrictedItems, 0, MagicDisallowEnchanting)
			debug.trace("Enchanting Awakened :::::::::::::::::::::   Changed Keyword for " + rIndex + " items to MagicDisallowEnchanting")
		endif

		GoToState("EnchantingState") ;Lock ends when this state finishes
EndFunction



State EnchantingState
	Event OnGetUp(ObjectReference akFurniture)
		debug.trace("Enchanting Awakened :::::::::::::::::::::   Getting up from table...")

		if (scrubKeywords)
			EA_Extender.SetFormArrayNthKeywordArray(RestrictedItems, 0, RestrictedKeywords)
			debug.trace("Enchanting Awakened :::::::::::::::::::::   Changed Keyword for " + rIndex + " items back to normal")
		endif

		GoToState("") ;release lock
	EndEvent

	Event OnEndState()
		rLOCK = false
	EndEvent
EndState



bool Function CanDisenchant(Enchantment baseEnch)
	;check if current Soul Shaper perks allow access to this enchantment:
	int list = PerkStateCore
	while list
		if PerkLinkedEnchantmentsCore[list].hasForm(baseEnch)
			debug.trace("Enchanting Awakened ::::::::::::::::::::: CanDisenchant returning true for enchantment " + (baseEnch as form).getName())
			return true
		endif
		list -= 1
	endWhile

	;check master perks to account for any style-exclusive enchantments:
	if PerkLinkedEnchantmentsSpecial[PerkStateSpecial].hasForm(baseEnch)
		debug.trace("Enchanting Awakened ::::::::::::::::::::: CanDisenchant returning true for enchantment " + (baseEnch as form).getName())
		return true
	endif 

	;allow disenchanting of any modded/custom enchantments once the first perk is unlocked. Also, don't
	;track player-enchanted items, game won't allow disenchanting of them anyway even if player would respec.
	debug.trace("Enchanting Awakened ::::::::::::::::::::: CanDisenchant returning " + (PerkStateCore && (PerkLinkedEnchantmentsALL.find(baseEnch) < 0)) + " for enchantment " + (baseEnch as form).getName())
	return PerkStateCore && (PerkLinkedEnchantmentsALL.find(baseEnch) < 0)

	;POSSIBLE FEATURE:
	;;if I implement enchantment learning, I could also add an MCM option to only allow
	;;disenchant of items that the player has "learned" a little about by using them.
EndFunction


Function AddRestriction(Form[] itemData)
	int n = RestrictedItems.find(itemData[kForm])
	if n < 0 ;only add new forms
		if rINDEX < 128
			rLOCK = true
				RestrictedItems[rINDEX] = itemData[kForm]
				RestrictedEnchants[rINDEX] = itemData[kBaseEnchantment] as Enchantment
				RestrictedKeywords[rINDEX] = itemData[kKeyword] as Keyword
				TrackerSatellite.AddInventoryEventFilter(itemData[kForm])
				debug.trace("Enchanting Awakened :::::::::::::::::::::   FILTER: added filter " + itemData[kForm].getName() + " to Removal Tracker")
				rINDEX += 1
			rLOCK = false
			;debug.notification("EnchantingAwakened :::::::::: Item added to RestrictedItems Array at Index " + (rINDEX - 1) + " [" + itemData[kForm].getName() + "]")
			debug.trace("Enchanting Awakened :::::::::::::::::::::   Item added to RestrictedItems Array at Index " + (rINDEX - 1) + " [" + itemData[kForm].getName() + "] [" + RestrictedEnchants[(rINDEX - 1)] + "] [" + RestrictedKeywords[(rINDEX - 1)] + "]")
		else
			debug.trace("Enchanting Awakened ::: Item Tracking Error - Reached end of RestrictedItems array trying to add " + itemData[kForm].getName())
		endif
	endif
EndFunction



int lastPerkUpState
Function UpdateRestrictions() ;called when a new perk affecting enchant permissions is gained, also called on game load (since perk quest has "allow repeated stages")
	debug.trace("Enchanting Awakened ::::::::::::::::::::: UpdateRestrictions called (Perk Gained/Removed)")
	rLOCK = true
		if lastPerkUpState > PerkStateCore ;Respec / Perk removed
			debug.trace("Enchanting Awakened ::::::::::::::::::::: Player has respec'd / removed perks...")
			lastPerkUpState = PerkStateCore
			ProcessPlayerItems(SCRUB + REBUILD + REDUCE)
		else ;Perk Added
			lastPerkUpState = PerkStateCore
			ProcessPlayerItems(REDUCE)
		endif
	rLOCK = false
Endfunction



; Function ReevaluateInventory()
; 	debug.trace("Enchanting Awakened ::::::::::::::::::::: ReevaluateInventory called")
; 	TrackerSatellite.ScrubListener()
; 	while rINDEX
; 		rINDEX -= 1
; 		RestrictedItems[rINDEX] = none
; 		RestrictedKeywords[rINDEX] = none
; 		RestrictedEnchants[rINDEX] = none
; 	endWhile

; 	ProcessPlayerItems(true)
; 	ProcessPlayerItems(false)

; 	rLOCK = false
; EndFunction



Function ProcessPlayerItems(int process)
	if (process >= SCRUB) ;0x04
		debug.trace("Enchanting Awakened ::::::::::::::::::::: SCRUBBING")
		TrackerSatellite.ScrubListener()
		RestrictedItems = new Form[128]
		RestrictedKeywords = new Keyword[128]
		RestrictedEnchants = new Enchantment[128]
		process -= SCRUB
	endif

	if (process >= REBUILD) ;0x02
		debug.trace("Enchanting Awakened ::::::::::::::::::::: REBUILDING")
		;Fill arrays with player's enchanted items & associated data
		EA_Extender.GetEnchantedForms(playerRef, RestrictedItems, RestrictedEnchants, true, true)
		EA_Extender.GetFormArrayNthKeywords(RestrictedItems, 0, RestrictedKeywords)
		rINDEX = RestrictedItems.find(none)
		TrackerSatellite.FilterMultipleForms(RestrictedItems)
		process -= REBUILD
	endif

	if (process >= REDUCE) ;0x01
		debug.trace("Enchanting Awakened ::::::::::::::::::::: REDUCING")
		int n = rINDEX
		while n
			n -= 1
			if canDisenchant(RestrictedEnchants[n])
				TrackerSatellite.RemoveInventoryEventFilter(RestrictedItems[n])
				debug.trace("Enchanting Awakened :::::::::::::::::::::   FILTER: removed filter " + RestrictedItems[n].getName() + " from Removal Tracker")
				rINDEX -= 1
				RestrictedItems[n] = RestrictedItems[rINDEX]
				RestrictedKeywords[n] = RestrictedKeywords[rINDEX]
				RestrictedEnchants[n] = RestrictedEnchants[rINDEX]
				RestrictedItems[rINDEX] = none
				RestrictedKeywords[rINDEX] = none
				RestrictedEnchants[rINDEX] = none
			endif
		endWhile
	endif
EndFunction



; bool Function IsPlayerEnchant(Enchantment e)
; 	debug.trace("Enchanting Awakened ::::::::::::::::::::: IsPlayerEnchant(" + (e as form).GetName() + ") == " + (Math.RightShift((e as form).GetFormID(), 24) == 0xFF))
; 	return Math.RightShift((e as form).GetFormID(), 24) == 0xFF
; EndFunction


bool rLOCKval
bool property rLOCK hidden
	Function Set(bool bVal)
		if !bVal
			rLOCKval = false
		else
			while rLOCKval
				debug.trace(":::::::::::::::::::::::::::::::::::::::::::: >>>>>>>> rLOCK waiting <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<")
				utility.waitmenumode(0.1)
			endWhile
			rLOCKval = true
		endif
	EndFunction
EndProperty