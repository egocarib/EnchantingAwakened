Scriptname EA_SpecialEquipTracker extends ReferenceAlias

;script used to track equip events on the player and respond to
;them in order to maintain compatibility with various mods. Used
;to prevent backpack carryweight enchants from being dispelled,
;etcetera. MCM menu option to exclude items that use custom slots.

;send to active state when MCM option is flagged
State Active
  Bool Function EquippedInCustomSlot()
    return (LastEq.getSlotMask() >= 16384) ;slot 44, the beginning of custom modded equipment slots
  EndFunction

  Event OnObjectEquipped(Form akBaseObject, ObjectReference akReference)
    LastEq = akBaseObject as Armor
  EndEvent
EndState

Armor LastEq
bool Function EquippedInCustomSlot()
  return false
EndFunction

Event OnObjectEquipped(Form akBaseObject, ObjectReference akReference)
EndEvent



; Event Oninit()
;   goToState("Active")
; EndEvent                    ;for testing