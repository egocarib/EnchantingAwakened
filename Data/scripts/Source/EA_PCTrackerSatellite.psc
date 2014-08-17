Scriptname EA_PCTrackerSatellite extends ReferenceAlias

MiscObject property EA_NullItem auto


Event OnItemRemoved(Form akBaseItem, int aiItemCount, ObjectReference akItemReference, ObjectReference akDestContainer)
  debug.trace("Enchanting Awakened ::::::::::::::::::::: ITEM TRACKER attempting to send OnTrackedItemRemoved event back to main Player Alias...")
  int eventCode = ModEvent.Create("EA_TrackedItemRemoved")
  if (eventCode)
    ModEvent.PushForm(eventCode, akBaseItem)
    ModEvent.Send(eventCode)
  else
    debug.trace("Enchanting Awakened ::::: Tracking Error OnItemRemoved [akBaseItem = " + akBaseItem.getFormID() + "]")
  endIf
EndEvent


Function FilterMultipleForms(Form[] filterForms)
  int i = 0
  int max = filterForms.Length
  while (filterForms[i] && i < max)
    AddInventoryEventFilter(filterForms[i])
    i += 1
  endWhile
EndFunction


Function ScrubListener()
  debug.trace("Enchanting Awakened ::::::::::::::::::::: ITEM TRACKER ScrubListener() called, resetting filters")
  RemoveAllInventoryEventFilters()
  AddInventoryEventFilter(EA_NullItem)
EndFunction


Auto State Uninitialized
  Function ScrubListener()
    debug.trace("Enchanting Awakened ::::::::::::::::::::: ITEM TRACKER loaded......")
    GoToState("")
    ScrubListener()
  EndFunction

  Function FilterMultipleForms(Form[] filterForms)
    ScrubListener()
    FilterMultipleForms(filterForms)
  EndFunction

  Event OnItemRemoved(Form akBaseItem, int aiItemCount, ObjectReference akItemReference, ObjectReference akDestContainer)
  EndEvent
EndState