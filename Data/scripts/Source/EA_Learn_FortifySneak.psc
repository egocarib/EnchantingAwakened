Scriptname EA_Learn_FortifySneak extends EA_Learn_TemplateAME

;Effect is active when conditions are met:
;  HasMagicEffect   EnchFortifySneakConstantSelf   ==   1.00   AND
;  IsSneaking       NONE                           ==   1.00

Quest                property  SneakAntenna        auto
ReferenceAlias       property  NearbyHostileActor  auto
int                            locks
int                            pockets
int                            sneaksAndSteals


Event OnEffectStart(Actor target, Actor caster)
	sneaksAndSteals = Game.QueryStat("Sneak Attacks") + Game.QueryStat("Items Stolen") / 4 ;items stolen == less naughty
	RegisterForMenu("ContainerMenu")
	RegisterForMenu("Lockpicking Menu")
	RegisterForSingleUpdate(4.0)
EndEvent

Event OnEffectFinish(Actor target, Actor caster)
	;UnregisterForMenu("ContainerMenu")
	;UnregisterForMenu("Lockpicking Menu")
	int newBadness = Game.QueryStat("Sneak Attacks") + Game.QueryStat("Items Stolen") / 4
	int badFactor = newBadness - sneaksAndSteals
	if (badFactor > 0)
		learnManager.LearnSneak(badFactor * 6.0)
	endif
EndEvent

Event OnMenuOpen(string menu)
	locks = Game.QueryStat("Locks Picked")
	pockets = Game.QueryStat("Pockets Picked")
EndEvent

Event OnMenuClose(string menu)
	int badFactor = Game.QueryStat("Locks Picked") + Game.QueryStat("Pockets Picked") - locks - pockets
	if (badFactor > 0)
		sneaksAndSteals += pockets ;every pickpocket counts toward "Items Stolen", so offset that here
		learnManager.LearnSneak(badFactor * 6.0)
	endif
EndEvent



Event OnUpdate()
	SneakAntenna.start() ;search for nearby hostile actor
	utility.wait(1.0)
	if (NearbyHostileActor.getReference())
		learnManager.LearnSneak()
	else
		learnManager.LearnSneak(idling = true)
	endif
	SneakAntenna.stop()
	RegisterForSingleUpdate(10.0)
EndEvent

Event OnPlayerLoadGame()
	RegisterForMenu("ContainerMenu")
	RegisterForMenu("Lockpicking Menu")
EndEvent