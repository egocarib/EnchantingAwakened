Scriptname EA_Learn_FortifyHealth extends EA_Learn_TemplateAME

;Effect is active when conditions are met:
;  HasMagicEffect         EnchFortifyHealthConstantSelf   ==   1.00   AND
;  GetActorValuePercent   Health                          <    0.50

Keyword property MagicRestoreHealth    auto
int     property hitStateFlag   = 0x01 autoreadonly
int     property magicStateFlag = 0x02 autoreadonly
int              currentState   = 0x03
MagicEffect      cachedMgef
Actor            cachedAggressor

Auto State EventState3
	Event OnHit(ObjectReference aggressor, Form source, Projectile proj, bool powAtk, bool snkAtk, bool bashAtk, bool hitBlocked)
		PauseLearnHit(aggressor as Actor)
	EndEvent
	Event OnMagicEffectApply(ObjectReference caster, MagicEffect mgef)
	    PauseLearnMagic(mgef)
	EndEvent
EndState
State EventState2
	Event OnMagicEffectApply(ObjectReference caster, MagicEffect mgef)
	    PauseLearnMagic(mgef)
	EndEvent
EndState
State EventState1
	Event OnHit(ObjectReference aggressor, Form source, Projectile proj, bool powAtk, bool snkAtk, bool bashAtk, bool hitBlocked)
		PauseLearnHit(aggressor as Actor)
	EndEvent
EndState

Function PauseLearnHit(Actor aggressor)
	currentState -= hitStateFlag
	GoToState("EventState" + currentState)

	if ((aggressor) && (aggressor == cachedAggressor || aggressor.isHostileToActor(playerRef)))
		cachedAggressor = aggressor
		learnManager.LearnHealth(0.1)
	endif
	Utility.Wait(5.0)

	currentState += hitStateFlag
	GoToState("EventState" + currentState)
EndFunction

Function PauseLearnMagic(MagicEffect mgef)
	currentState -= magicStateFlag
	GoToState("EventState" + currentState)

	if (mgef == cachedMgef || mgef.hasKeyword(MagicRestoreHealth))
		cachedMgef = mgef
		learnManager.LearnHealth(1.0) ;bonus experience when healing while low on health
	endif
	Utility.Wait(5.0)

	currentState += magicStateFlag
	GoToState("EventState" + currentState)
EndFunction