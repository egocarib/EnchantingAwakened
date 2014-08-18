Scriptname EA_Learn_TESTMOVE extends ActiveMagicEffect


;;This is only a testing script


Quest property EA_LearnQuestAntennaTEST auto
ReferenceAlias property TestActor auto

Event OnEffectStart(Actor akTarget, Actor akCaster)
    registerforupdate(4.0)
EndEvent

Event OnUpdate()
	EA_LearnQuestAntennaTEST.start()
	utility.wait(0.5)
	string ref = " [ref: none]"
	if (TestActor.getreference())
		ref = " [ref: " + (TestActor.getreference() as form).getName() + "]"
	endif
	EA_LearnQuestAntennaTEST.stop()
	debug.notification("LightLevel == " + game.getplayer().getLightLevel() as int + ref)
EndEvent



;for muffle, maybe like below 30 lightLevel. also account for combat -- so pause a few seconds after being hit or something.