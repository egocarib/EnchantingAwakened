Scriptname EA_Learn_Muffle extends ActiveMagicEffect



;;This is only a DRAFT VERSION



;Effect is active when conditions are met:
;  HasMagicEffect   EnchMuffleConstantSelf   ==   1.00   AND
;  GetLightLevel    NONE                     <   35.00


;active while indoors w/ dungeon, OR nighttime (gamehour), OR sneaking OR unpleasant outside

;;then check if sneaking, or low light, or undetected

;also could update armor counts and use that to modify amount


;sneaking or low light every 30 sec (or undetected by nearby actor)

;;ORs:
;sneak
;lightLevel < 20
;gameHour > 21
;gamehour < 5
;


;tier effects: global that controls time - set to +30 vs SecondsPassed,

  ;EnchMuffle + IsSneaking || GetLightLevel + SecondsPassed > Global
  ;EnchMuffle + GetLightLevel + SEcondsPassed > Global2-plus 10





EA_Learn_Controller  property  learnManager        auto
Quest                property  MuffleAntenna       auto
ReferenceAlias       property  NearbyUnawareActor  auto


Event OnEffectStart(Actor target, Actor caster)
	RegisterForSingleUpdate(30.0)
EndEvent

Event OnEffectFinish(Actor target, Actor caster)

EndEvent

Function TallyBadDeeds(bool tallyPicked) ;this isn't threadsafe, but not really important enough to matter
	int badFactor = 0

	if (tallyPicked)
		int pocketsAndLocks = Game.QueryStat("Locks Picked") + Game.QueryStat("Pockets Picked")
		badFactor += pocketsAndLocks - locksAndPockets
		locksAndPockets = pocketsAndLocks
	else
		int stealsAndSneaks = Game.QueryStat("Sneak Attacks") + Game.QueryStat("Items Stolen") / 4
		badFactor += stealsAndSneaks - sneaksAndSteals
		sneaksAndSteals = stealsAndSneaks
	endif

	if (badFactor > 0)
		learnManager.LearnSneak(badFactor * 6.0)
	endif
EndFunction


Event OnUpdate()
	SneakAntenna.start()
	utility.wait(1.0)

	if (NearbyHostileActor.getReference())
		learnManager.LearnSneak(1.0)
	else
		learnManager.LearnSneak(0.0)
	endif

	SneakAntenna.stop()

	RegisterForSingleUpdate(9.0)
EndEvent