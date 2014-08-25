Scriptname EA_Learn_FortifyPersuasion extends EA_Learn_TemplateAME

int persuasionTasks

Event OnEffectStart(Actor target, Actor caster)
	persuasionTasks  = Game.QueryStat("Houses Owned") * 200
	persuasionTasks += Game.QueryStat("Stores Invested In") * 100      ;~ 1670 points at level 25 (860 barter, 810 other points based on this formula)
	persuasionTasks += Game.QueryStat("Barters")                       ;(but keep in mind points only will count while wearing the correct enchantment...)
	persuasionTasks += Game.QueryStat("Persuasions") * 40
	persuasionTasks += Game.QueryStat("Bribes") * 60
	persuasionTasks += Game.QueryStat("Intimidations") * 80
	persuasionTasks += (playerRef.GetBaseActorValue("Speechcraft") * 10.0) as int
	GoToState("Active")
EndEvent

Event OnMenuClose(string menu)
	RegisterForSingleUpdate(15.0) ;prevent menu event spam
EndEvent
	
Event OnUpdate()
	DoLearn()
EndEvent

Event OnEffectFinish(Actor target, Actor caster)
	DoLearn()
EndEvent

State Active
	Function DoLearn()
		GoToState("Paused")
			int newTaskCount
			newTaskCount  = Game.QueryStat("Houses Owned") * 200
			newTaskCount += Game.QueryStat("Stores Invested In") * 100
			newTaskCount += Game.QueryStat("Barters")
			newTaskCount += Game.QueryStat("Persuasions") * 40
			newTaskCount += Game.QueryStat("Bribes") * 60
			newTaskCount += Game.QueryStat("Intimidations") * 80
			newTaskCount += (playerRef.GetBaseActorValue("Speechcraft") * 10.0) as int
			newTaskCount -= persuasionTasks

			learnManager.LearnPersuasion(newTaskCount)

			persuasionTasks += newTaskCount
		GoToState("Active")
	EndFunction
EndState

;EMPTY STATE
	Function DoLearn()
	EndFunction
;EMPTY STATE

Event OnInit()
	RegisterForMenu("Dialogue Menu")
	RegisterForMenu("BarterMenu")
EndEvent

Event OnPlayerLoadGame()
	RegisterForMenu("Dialogue Menu")
	RegisterForMenu("BarterMenu")
EndEvent