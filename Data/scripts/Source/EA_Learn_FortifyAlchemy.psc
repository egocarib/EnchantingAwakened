Scriptname EA_Learn_FortifyAlchemy extends EA_Learn_TemplateAME

int alchemyTasks

Event OnEffectStart(Actor target, Actor caster)
	alchemyTasks  = Game.QueryStat("Potions Mixed")
	alchemyTasks += Game.QueryStat("Potions Used")
	alchemyTasks += Game.QueryStat("Poisons Mixed")
	alchemyTasks += Game.QueryStat("Poisons Used")
	alchemyTasks += Game.QueryStat("Ingredients Harvested")
	alchemyTasks += Game.QueryStat("Ingredients Eaten")
	RegisterForSingleUpdate(1200.0)
	GoToState("Active")
EndEvent

Event OnUpdate()
	DoLearn()
	RegisterForSingleUpdate(1200.0)
EndEvent

Event OnEffectFinish(Actor target, Actor caster)
	DoLearn()
EndEvent

State Active
	Function DoLearn()
		GoToState("Paused")
			int newTaskCount
			newTaskCount  = Game.QueryStat("Potions Mixed")
			newTaskCount += Game.QueryStat("Potions Used")
			newTaskCount += Game.QueryStat("Poisons Mixed")
			newTaskCount += Game.QueryStat("Poisons Used")
			newTaskCount += Game.QueryStat("Ingredients Harvested")
			newTaskCount += Game.QueryStat("Ingredients Eaten")
			newTaskCount -= alchemyTasks

			learnManager.LearnAlchemy(newTaskCount)

			alchemyTasks += newTaskCount
		GoToState("Active")
	EndFunction
EndState

;EMPTY STATE
	Function DoLearn()
	EndFunction
;EMPTY STATE