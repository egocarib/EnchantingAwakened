Scriptname EA_Learn_Muffle extends EA_Learn_GenericArmorEffect

int underhandedDeeds

Event OnEffectStart(Actor target, Actor caster)
	underhandedDeeds = Game.QueryStat("Sneak Attacks") + Game.QueryStat("Locks Picked")
	parent.OnEffectStart(target, caster)
EndEvent

Function DoLearn(int amount) ;OVERRIDE THIS FUNCTION IF EXTENDING
	int underhandedUpdate = Game.QueryStat("Sneak Attacks") + Game.QueryStat("Locks Picked")
	if (underhandedUpdate > underhandedDeeds)
		amount += ((underhandedUpdate - underhandedDeeds) * 20)
		underhandedDeeds = underhandedUpdate
	endif
	learnManager.LearnMuffle(amount)
EndFunction



;OLD VERSION NOTES---------------------------------->
; effective when:
;  GetLightLevel    NONE                     <   35.00
;active while indoors w/ dungeon, OR nighttime (gamehour), OR sneaking OR unpleasant outside
;then check if sneaking, or low light, or undetected
;also could update armor counts and use that to modify amount
;OR
;lightLevel < 20
;gameHour > 21
;gamehour < 5