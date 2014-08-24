;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
;NEXT FRAGMENT INDEX 2
Scriptname EA_QF_LearnQuestKillActorEvent Extends Quest Hidden

;BEGIN FRAGMENT Fragment_1
Function Fragment_1()
;BEGIN CODE
int handle = ModEvent.Create("EA_OnKillActorEvent")
if (handle)
    ModEvent.Send(handle)
    debug.trace("Enchanting Awakened -------------------------------------------------- Sent Kill Actor Event")
else
    debug.trace("Enchanting Awakened: Error attempting to propagate EA_OnKillActorEvent")
endif
SetStage(20)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_0
Function Fragment_0()
;BEGIN CODE
Stop()
;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment
