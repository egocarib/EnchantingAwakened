;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
;NEXT FRAGMENT INDEX 8
Scriptname EA_PRKF_EnchantTableActivate Extends Perk Hidden

;BEGIN FRAGMENT Fragment_0
Function Fragment_0(ObjectReference akTargetRef, Actor akActor)
;BEGIN CODE
;debug.notification("Enchanting Awakened ::::: Activating Enchanting Table...")
debug.trace("Enchanting Awakened ::::::::::::::::::::: ENCHANT TABLE PERK sending table activation event...")
int eventCode = ModEvent.Create("EA_EnchTableActivate")
if (eventCode)
  ModEvent.PushForm(eventCode, akTargetRef)
  ModEvent.Send(eventCode)
else
  debug.trace("Enchanting Awakened ::::: Enchant Table Activation Event Error [akTargetRef = " + akTargetRef.getFormID() + "]")
endIf
;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment
