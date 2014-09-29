;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
;NEXT FRAGMENT INDEX 12
Scriptname EA_QF_PerkGainUpdates Extends Quest Hidden

;BEGIN FRAGMENT Fragment_1
Function Fragment_1()
;BEGIN CODE
;soul shaper 02
debug.trace("=================== Perk Fragment Stage 20 running (soulShaper02) [initialized == " + initialized + "]")
if (initialized)
  MainQuestRef.PerkStateCore = 2
  MainQuestRef.UpdateRestrictions()
endif
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_2
Function Fragment_2()
;BEGIN CODE
;no enchanting perks
debug.trace("=================== Perk Fragment Stage 0 running (no perks) [initialized == " + initialized + "]")
MainQuestRef.PerkStateCore = 0
MainQuestRef.PerkStateSpecial[1] = false
MainQuestRef.PerkStateSpecial[2] = false
MainQuestRef.PerkStateSpecial[3] = false
if (initialized)
  MainQuestRef.UpdateRestrictions()
endif
SoulTrapQuest.GoToState("")
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_0
Function Fragment_0()
;BEGIN CODE
;soul shaper 01
debug.trace("=================== Perk Fragment Stage 10 running (soulShaper01) [initialized == " + initialized + "]")
if (initialized)
  MainQuestRef.PerkStateCore = 1
  MainQuestRef.UpdateRestrictions()
endif
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_11
Function Fragment_11()
;BEGIN CODE
;essence nemesis
SoulTrapQuest.GoToState("CalcStateEssenceNemesis")
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_9
Function Fragment_9()
;BEGIN CODE
;essence gambit
debug.trace("=================== Perk Fragment Stage 90 running (essenceGambit) [initialized == " + initialized + "]")
if (initialized)
  SoulTrapQuest.GoToState("CalcStateEssenceGambit")
endif
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_7
Function Fragment_7()
;BEGIN CODE
;corpus guardian
debug.trace("=================== Perk Fragment Stage 53 running (corpusGuardian)")
MainQuestRef.PerkStateSpecial[3] = true
MainQuestRef.PerkStateSpecial[2] = PlayerRef.HasPerk(EA_ChaosMaster)
MainQuestRef.PerkStateSpecial[1] = PlayerRef.HasPerk(EA_AetherStrider)

MainQuestRef.UpdateRestrictions()
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_3
Function Fragment_3()
;BEGIN CODE
;soul shaper 03
debug.trace("=================== Perk Fragment Stage 30 running (soulShaper03) [initialized == " + initialized + "]")
if (initialized)
  MainQuestRef.PerkStateCore = 3
  MainQuestRef.UpdateRestrictions()
endif
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_5
Function Fragment_5()
;BEGIN CODE
;aether strider
debug.trace("=================== Perk Fragment Stage 51 running (aetherStrider)")
MainQuestRef.PerkStateSpecial[3] = PlayerRef.HasPerk(EA_CorpusGuardian)
MainQuestRef.PerkStateSpecial[2] = PlayerRef.HasPerk(EA_ChaosMaster)
MainQuestRef.PerkStateSpecial[1] = true
MainQuestRef.UpdateRestrictions()
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_6
Function Fragment_6()
;BEGIN CODE
;chaos master
debug.trace("=================== Perk Fragment Stage 52 running (chaosMaster)")
MainQuestRef.PerkStateSpecial[3] = PlayerRef.HasPerk(EA_CorpusGuardian)
MainQuestRef.PerkStateSpecial[2] = true
MainQuestRef.PerkStateSpecial[1] = PlayerRef.HasPerk(EA_AetherStrider)
MainQuestRef.UpdateRestrictions()
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_10
Function Fragment_10()
;BEGIN CODE
;essence nemesis
debug.trace("=================== Perk Fragment Stage 91 running (essenceNemesis)")
SoulTrapQuest.GoToState("CalcStateEssenceBoth")
;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment


EA_PCDisenchantingControl Property MainQuestRef  Auto
EA_SoulTrapQuestScript Property SoulTrapQuest Auto

Actor property PlayerRef Auto

Bool Property initialized = False Auto  

Perk Property EA_ChaosMaster auto
Perk Property EA_CorpusGuardian auto
Perk Property EA_AetherStrider auto