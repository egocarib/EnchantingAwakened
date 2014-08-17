Scriptname EA_Learn_FortifyPickpocket extends EA_Learn_TemplateAME

;Effect is active when conditions are met:
;  HasMagicEffect         EnchFortifyPickpocketConstantSelf   ==   1.00   AND
;  IsPlayerActionActive   11 [PICKPOCKET]                     ==   1.00

;variables get re-initialized every time the effect starts
float experience
int pocketsPicked

Event OnEffectStart(Actor akTarget, Actor akCaster)
	RegisterForMenu("ContainerMenu")
	OnUpdate()
EndEvent

Event OnUpdate()
	experience += 1.0
	RegisterForSingleUpdate(1.0)
EndEvent

Event OnMenuOpen(string menu)
    pocketsPicked = Game.QueryStat("Pockets Picked")
EndEvent

Event OnMenuClose(string menu)
    experience += (Game.QueryStat("Pockets Picked") - pocketsPicked) * 10.0
EndEvent

Event OnEffectFinish(Actor akTarget, Actor akCaster)
	learnManager.LearnPickpocket(experience)
EndEvent