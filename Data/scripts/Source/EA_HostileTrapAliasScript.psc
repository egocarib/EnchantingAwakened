Scriptname EA_HostileTrapAliasScript extends ReferenceAlias
{playerAlias forced into this ref upon entering cell with trap}


Actor property playerRef auto
Keyword property ActorTypeNPC auto
Keyword property ActorTypeCreature auto

Spell[] property fullTrapBoostSpells auto
Spell[] property halfTrapBoostSpells auto
  
; FX -------------------------------------------------------->>
  VisualEffect property EA_GemAbsorbCasterVFX auto
  VisualEffect property EA_GemAbsorbTargetVFX auto
  VisualEffect property EA_SwirlsAroundGemVFX auto
  EffectShader property EA_HostileTrapAbsorbFXS auto
  Explosion 	property EA_TrapGemExplosion01 auto
  Explosion 	property EA_TrapGemExplosion02 auto
  Explosion 	property EA_TrapGemExplosionFinal auto
  Hazard 		property EA_TrapGemSparksHaz auto
  Hazard 		property EA_TrapGemGlowHaz auto
  Sound 			property EA_TrapGemSoundLoopSparks auto
  Sound 			property EA_TrapGemSoundLoopAmbient auto

; MSGs ------------------------------------------------------>>
  Message property EATrapSensedMsg auto ;2nd person by default
  Message property EATrapEngagedMsg auto
  Message property EATrapDisengagedMsg auto
  Message property EATrapNoAbsorbMsg auto
  Message property EATrapHalfAbsorbMsg auto
  Message property EATrapFullAbsorbMsg auto

    ;variants
	  Message property EATrapSensedMsg1stP auto ;1st person variant
	  Message property EATrapEngagedMsg1stP auto
	  Message property EATrapNoAbsorbMsg1stP auto
	  Message property EATrapHalfAbsorbMsg1stP auto
	  Message property EATrapFullAbsorbMsg1stP auto

	  Message property EATrapSensedMsg2ndP auto ;2nd person variant
	  Message property EATrapEngagedMsg2ndP auto
	  Message property EATrapNoAbsorbMsg2ndP auto
	  Message property EATrapHalfAbsorbMsg2ndP auto
	  Message property EATrapFullAbsorbMsg2ndP auto

; TRAP PROPERTIES ------------------------------------------->>
  Formlist property EA_HostileTrapEffectsList auto
  objectReference property trapPedestal auto hidden
  objectReference property trapGem auto hidden
  bool property trapDisarmed auto hidden

; SCRIPTS --------------------------------------------------->>
  trapSoulGemController gemScript
  EA_HostileSoulGemTrapScript trapScript

; LOCAL ----------------------------------------------------->>
  objectReference sparkHaz 		;LOCAL FX instances
  objectReference glowHaz 			;
  int sparkSoundInstance 			;
  int glowSoundInstance 			;

  float fHealRateFar = 0.50 		;SETTINGS
  float fHealRateNear = 2.30 		;
  float fBaseUpdateTime = 1.0 	;

  float healRateMod 					;tracks HealRate modifications
  bool trapSensed 					;has player sensed the trap?
  bool activeFX 						;are FX active?






Function runSetup()
	gemScript = trapGem as trapSoulGemController 					;  SETUP gemScript properties
	trapScript = trapPedestal as EA_HostileSoulGemTrapScript
	gemScript.playerHasSpecialPerk = true 							;
	gemScript.gemActivated = false 									;
;	gemScript.ActorTypeNPC = ActorTypeNPC 							; DEPRICATED
;	gemScript.ActorTypeCreature = ActorTypeCreature 				; DEPRICATED
;	gemScript.playerRef = playerRef as objectReference 				; Now set by trapsoulgemcontroller instead
	gemScript.playerTrapAlias = self as EA_HostileTrapAliasScript 	;
	if playerRef.getActorValue("SpeedMult") > 100.0
		fBaseUpdateTime = fBaseUpdateTime * (100.0 / playerRef.getActorValue("SpeedMult")) 
		;ensures consistency between player speed and update intervals for recurring distance checks
		;(shouldn't break anything if a distance check is missed, so not worth checking every update)
	endif
	registerForSingleUpdate(0.01)
EndFunction



Event onUpdate()
	
	float trapDist

	if trapDisarmed ;set to true by gemScript when it becomes disarmed
;		debug.notification("TRAP DISARMED!!!!!!!!!!!!!")
		gemScript.gemActivated = true
		bootAlias()
		return

	elseif nearbyTraps[1] ;there is at least one other trap present, make sure we're still tracking the closest one:
		int nearestIndex = -1
		float nearestDist = 0.0
		while NTLock
			utility.wait(0.05)
		endWhile
		NTLock = true
			int tNum
			while nearbyTraps[tNum] && tNum < 7 ;change if array size changes
				if nearbyTraps[tNum] == trapPedestal ;currently tracked trap
					trapDist = playerRef.getDistance(trapGem)
				else
					float dCheck = nearbyTraps[tNum].getDistance(playerRef)
					if dCheck < nearestDist || !nearestDist
						nearestDist = dCheck
						nearestIndex = tNum
					endif
				endif 
				tNum += 1
			endWhile

			if (nearestDist < trapDist) && nearestDist
				if activeFX
					disableFX()
					activeFX = false
				endif
				NTLock = false
				(nearbyTraps[nearestIndex] as EA_HostileSoulGemTrapScript).handshakePlayer()
				return 
			endif
		NTLock = false

	else
		trapDist = playerRef.getDistance(trapGem)
	endif



	if trapDist < 5000.0 ;(cell width is 4096 units, PC sprint speed should be below 500 units/sec)

		if trapDist < 800.0 
			if trapScript.PlayerSeesMe
				EATrapEngagedMsg.show() ;You begin absorbing strength from the gem.
				playerRef.modActorValue("HealRate", fHealRateNear)
				healRateMod += fHealRateNear
				goToState("trapEngaged")
				registerForSingleUpdate(1.0 * fBaseUpdateTime)
			else
				registerForSingleUpdate(0.4)
			endif

		elseif trapDist < 3000.0
			if !trapSensed
				EATrapSensedMsg.show() ;You sense hostile soul gem energy nearby.
				trapSensed = true
			endif
			if !activeFX
				if !sparkHaz
					sparkHaz = trapGem.placeAtMe(EA_TrapGemSparksHaz)
					sparkHaz.setScale(0.1)
					sparkSoundInstance = EA_TrapGemSoundLoopSparks.Play(trapGem)
				endif
				if !healRateMod
					playerRef.modActorValue("HealRate", fHealRateFar)
					healRateMod += fHealRateFar
				endif
				activeFX = true
			endif
			registerForSingleUpdate(0.4 * fBaseUpdateTime)

		else ;3000.0 < trapDist < 5000.0
			if healRateMod
				playerRef.modActorValue("HealRate", -healRateMod)
				healRateMod = 0
			endif
			registerForSingleUpdate(0.8 * fBaseUpdateTime)

		endif

	else ;trap is more than a cell-length away
		if activeFX
			disableFX()
			activeFX = false
		endif
		registerForSingleUpdate(3.0 * fBaseUpdateTime)
	endif
endEvent





; trapEngaged STATE VARIABLES ------------------------------->>
  int engageTimer
  int engageTimerOffset
  int property explodeCount auto hidden
  bool absorbFX
; ----------------------------------------------------------->>


State trapEngaged

	Event onBeginState()
;		debug.notification("trap has been engaged. HealRate: " + playerRef.getActorValue("HealRate"))
		sparkHaz.disable()
		sparkHaz.delete()
		sparkHaz = trapGem.placeAtMe(EA_TrapGemSparksHaz)	;replace/reset the pre-existing FX
		sparkHaz.setScale(0.1) 
		engageTimer = 0
		engageTimerOffset = 0 										;reset counters
		explodeCount = 0
	EndEvent



	Event onUpdate()

		if trapDisarmed ;set to true by gemScript when it becomes disarmed
			gemScript.gemActivated = true
			bootAlias()
			return

		else
			engageTimer += 1

			if engageTimer == 3    ;start absorbFX after 3 seconds
				EA_GemAbsorbTargetVFX.play(trapGem, akFacingObject = playerRef)
				EA_GemAbsorbTargetVFX.play(trapGem, akFacingObject = playerRef) ;double it up for better visual effect
				EA_GemAbsorbCasterVFX.play(playerRef, akFacingObject = trapGem)
				EA_HostileTrapAbsorbFXS.play(playerRef)
				absorbFX = true
			endIf

			;randomize time between explosions, and thereby also the progress towards fully absorbing gem's power
			if utility.randomInt(0, 10) < engageTimer - engageTimerOffset
				float trapDist = playerRef.getDistance(trapGem)

				;------------------- player has left the vicinity of the gem trap -----------------------
				if trapDist > 1500.0
					playerRef.modActorValue("HealRate", -fHealRateNear)
					healRateMod -= fHealRateNear
					if absorbFX
						EA_GemAbsorbTargetVFX.stop(trapGem)
						EA_GemAbsorbCasterVFX.stop(playerRef)
						EA_HostileTrapAbsorbFXS.stop(playerRef)
						absorbFX = false
						EATrapDisengagedMsg.show() ;The soul gem's energy fades with distance.
					endif
					goToState("")

				;------------------ player is still near the gem trap, proceed with FX ------------------
				else
					float randScale = utility.randomFloat(0.3, 1.0)
					if utility.randomInt(0, 1) ;randomly choose one of the two explosions to play
						objectReference explo = trapGem.placeAtMe(EA_TrapGemExplosion01) as objectReference
						explo.setScale(randScale)
					else
						objectReference explo = trapGem.placeAtMe(EA_TrapGemExplosion02) as objectReference
						explo.setScale(randScale)
					endif
					explodeCount += 1
					engageTimerOffset = engageTimer
				endif

				;------------------------------------- FX finale ----------------------------------------
				if explodeCount == 2 && !trapDisarmed
					float fInterval = utility.randomFloat(0.3, 0.45)
					int iDelay = utility.randomInt(14, 28)
					int iFinaleBegin = utility.randomInt(4, 10)
					while iDelay					;while loop to keep monitoring trap for potential disable
						iDelay -= 1
						utility.wait(fInterval)
						if trapDisarmed			;if trap disabled, jump straight to finale FX
							iDelay = 0
						elseif iDelay == iFinaleBegin
							EA_SwirlsAroundGemVFX.play(trapGem)
						endif
					endWhile
					objectReference explo = trapGem.placeAtMe(EA_TrapGemExplosionFinal)
					;explo.setScale(utility.randomfloat(0.7, 1.0)) ;too much script time
					explodeCount = 3 ;enable the player to be able to grab the gem sooner
					gemScript.goToState("disarmed")
					disableFX()
					grantAbsorbedPowerFull() ;grant power to player
					if trapDisarmed
						EA_SwirlsAroundGemVFX.stop(trapGem)
						;gemJump()
						return
					endif
					;if trap isn't disarmed, wait for a bit for player to touch it, then force gemJump...
					glowHaz = trapGem.placeAtMe(EA_TrapGemGlowHaz)
					glowSoundInstance = EA_TrapGemSoundLoopAmbient.play(trapGem)
					;utility.wait(1.2)
					;EA_SwirlsAroundGemVFX.stop(trapGem)
					iDelay = utility.randomInt(40, 150)
					int iInc
					while iInc < iDelay
						iInc += 1
						if iInc == iDelay
							gemJump()
							return
						elseif trapDisarmed
							EA_SwirlsAroundGemVFX.stop(trapGem)
							return 
						elseif iInc == 30
							EA_SwirlsAroundGemVFX.stop(trapGem)
						endif
						utility.wait(0.10)
					endWhile
				endif
			endif

			registerForSingleUpdate(1.0)

		endif
	EndEvent
EndState



Function grantAbsorbedPowerFull()
	;GRANT FULL-STRENGTH ABSORBED POWER

	if utility.getCurrentGameTime() < playersLastHalfBoost + 3.0 ;player has already absorbed a half-strength power recently,
		grantAbsorbedPowerHalf()											 ;grant them another half-strength power instead of a full one
		return
	endif

	EATrapFullAbsorbMsg.show() ; You've completely absorbed the gem's energy.

	int numSpells = fullTrapBoostSpells.Length
	int randSpell = utility.randomInt(0, (numSpells - 1))
	if !playerRef.hasSpell(fullTrapBoostSpells[randSpell])
		playerRef.addspell(fullTrapBoostSpells[randSpell], false)
	else ;pick different random spell. number of attempts capped as a failsafe to avoid
		  ;an infinite loop if player somehow would add all of them to their character.
		int maxAttempts = 15
		while playerRef.hasSpell(fullTrapBoostSpells[randSpell]) && maxAttempts
			maxAttempts -= 1
			randSpell = utility.randomInt(0, (numspells - 1))
		endWhile
		if maxAttempts
			playerRef.addspell(fullTrapBoostSpells[randSpell], false)
		endif
	endif

	playerBoostedAlready = true
	registerForSingleUpdateGameTime(72.0)
EndFunction



Function grantAbsorbedPowerHalf()
	;GRANT HALF-STRENGTH ABSORBED POWER

	EATrapHalfAbsorbMsg.show()  ; Your link to the gem is broken off early.

	int numSpells = halfTrapBoostSpells.Length
	int randSpell = utility.randomInt(0, (numSpells - 1))
	if !playerRef.hasSpell(halfTrapBoostSpells[randSpell])
		playerRef.addspell(halfTrapBoostSpells[randSpell], false)
	else ;pick different random spell. number of attempts capped as a failsafe to avoid
		  ;an infinite loop if player somehow would add all powers to their character.
		int maxAttempts = 15
		while playerRef.hasSpell(halfTrapBoostSpells[randSpell]) && maxAttempts
			maxAttempts -= 1
			randSpell = utility.randomInt(0, (numspells - 1))
		endWhile
		if maxAttempts
			playerRef.addspell(halfTrapBoostSpells[randSpell], false)
		endif
	endif

	if utility.getCurrentGameTime() >= playersLastHalfBoost + 3.0
		playersLastHalfBoost = utility.getCurrentGameTime()
	else
		playerBoostedAlready = true
		registerForSingleUpdateGameTime(72.0)
	endif
EndFunction



Function gemJump()
	;------------------------------------  HAVOK GEM  --------------------------------------------
	if trapGem.isEnabled() ;make sure player didn't grab it already
		float zOffset = trapGem.getHeadingAngle(playerRef)
		float newZ = trapGem.GetAngleZ() + zOffset + utility.randomfloat(-35.0, 35.0)
		float havokForce = (playerRef.getDistance(trapGem) / 12.0)
		if havokForce < 10.0
			havokForce = 10.0
		endif
		;objectReference explo = trapGem.placeAtMe(EA_TrapGemExplosion01)
		;explo.setScale(0.05)
		;utility.wait(0.1)
		;explo.disable()
		;explo.delete()
		trapGem.SetMotionType(1)
		trapGem.ApplyHavokImpulse(math.sin(newZ), math.cos(newZ), (math.sin(88.0) * -1.0), havokForce)
	;---------------------------------------------------------------------------------------------

		gemScript.gemActivated = true
	endif

	bootAlias()
EndFunction



Function disableFX() ;general function to disable any active FX
	if healRateMod
		playerRef.modActorValue("HealRate", -healRateMod)
		healRateMod = 0
	endIf
	if sparkHaz
		sparkHaz.disable()
		sparkHaz.delete()
		sparkHaz = none
		Sound.stopInstance(sparkSoundInstance)
	endif
	if glowHaz
		glowHaz.disable()
		glowHaz.delete()
		glowHaz = none
		Sound.stopInstance(glowSoundInstance)
	endif
	if absorbFX
		EA_GemAbsorbTargetVFX.stop(trapGem)
		EA_GemAbsorbCasterVFX.stop(playerRef)
		EA_HostileTrapAbsorbFXS.stop(playerRef)
		absorbFX = false
	endif
	activeFX = false
EndFunction



Function bootAlias() ;will grant a partial boost to player if trap was disarmed before absorb finished (the full boost is handled in gemJump() function)
;								if no traps left in area, boots player from alias and stops all processing
;								if traps left but player can't absorb anymore, will send to idleTracking state
;								if traps left and player CAN absorb more, will find the closest trap and set up to be absorbed by player

	unregisterForUpdate() ;kill the alias script
	disableFX()

	if explodeCount == 1
		grantAbsorbedPowerHalf()
	endif

	;reset remaining variables that might need it
	trapSensed = false
	fBaseUpdateTime = 1.0

	if updateTrackedTrapsList() ;are there still any active traps nearby?
		if playerBoostedAlready
			goToState("idleTracking")
		else
			;SEARCH FOR NEAREST TRAP AND SET IT INTO MOTION
			findNearestTrapAndHandshakePlayer()
		endif

	else
		goToState("")
		self.clear()
		;debug.notification("player Booted from Alias")
	endif

EndFunction



;============================== WHILE ABSORBING ENERGY, GRANT PLAYER REGEN BOOSTS WHEN HIT BY TRAP TO LESSEN DAMAGE THEY TAKE ==========================
bool regenBoostActive

Event onMagicEffectApply(ObjectReference akCaster, MagicEffect akEffect)
	if EA_HostileTrapEffectsList.HasForm(akEffect) && !regenBoostActive && !playerBoostedAlready
		regenBoostActive = true
		;debug.notification("Hit by Trap, Regen Boost Applied!")
		playerRef.modActorValue("HealRate", 15.0)
		utility.wait(utility.randomFloat(1.0, 2.0))
		playerRef.modActorValue("HealRate", -15.0)
		utility.wait(utility.randomFloat(0.8, 1.6)) ;seemed overpowered on concentration-type trap spells, maybe this will help.
		regenBoostActive = false
	endif
EndEvent
;=======================================================================================================================================================




;///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////;
;																																																				;
;																			TRACKING  FUNCTIONS 																											;
;																																																				;
;			The following functions are used primarily to track and differentiate between multiple traps when there are more than one in an area. 					;
;																																																				;
;																																																				;
;///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////;

;----------------------------------------------------------------------------------------------->
bool NTLock
objectReference[] nearbyTraps
bool playerBoostedAlready 				;if true, player can't receive further gem trap boosts for 3 days
float playersLastHalfBoost = -3.0   ;used to track half-strength boosts gained from trap gems
;----------------------------------------------------------------------------------------------->


Event onInit()
	nearbyTraps = new objectReference[7]   ;highest number of traps in any vanilla or dragonborn cell (haven't checked dawnguard yet)
EndEvent



bool Function registerThisTrapWithPlayerAlias(objectReference chkTrap) ;called by traps when they attach to cell
	while NTLock
		utility.wait(0.1) ;LOCK
	endWhile
	NTLock = true
	 int tIndex = nearbyTraps.Find(none)
	 if tIndex >= 0
		 nearbyTraps[tIndex] = chkTrap
		 NTLock = false
		 return true 
	 else 
		 NTLock = false
	 	 return false
	 endif
EndFunction



bool Function checkIfValidTrapForPlayer(objectReference chkTrap) ;called by traps to check if they can be absorbed by player
; TRUE IF:	- this is the closest trap to player, and
;				- this trap is NOT in disarmed state, and
;				- player has not already gained a full trap boost today

	int chkTrapIndex
	int shortIndex = -1
	float shortDist
	int trapCount = 0
	while NTLock
		utility.wait(0.1) ;LOCK
	endWhile
	NTLock = true
	while trapCount < 7 ;change this if array size changes
		if nearbyTraps[trapCount]
			if (nearbyTraps[trapCount].getLinkedRef() as trapSoulGemController).getState() != "inMagicTrap" ;trap is disarmed
				nearbyTraps[trapCount] == none
				;----------------------------SHIFT ARRAY ELEMENTS DOWN
				int shiftNum = trapCount + 1
				while nearbyTraps[shiftNum] && shiftNum < 7
					nearbyTraps[(shiftNum - 1)] = nearbyTraps[shiftNum]
					nearbyTraps[shiftNum] = none
					shiftNum += 1
				endWhile ;--------------------------------------------
				;dont increment trapCount this time (need to check same index)
			else
				float thisDist = nearbyTraps[trapCount].getDistance(playerRef)
				if thisDist < shortDist || !shortDist
					shortDist = thisDist
					shortIndex = trapCount
				endif
				if nearbyTraps[trapCount] == chkTrap
					chkTrapIndex = trapCount
				endif
				trapCount += 1 
			endif
		else
			trapCount = 8 ; force loop exit, 'none' encountered
		endif 
	endWhile
	NTLock = false

	if playerBoostedAlready
		if shortDist ;there is at least one valid trap in array, begin idleTracking
			goToState("idleTracking")
			self.forceRefTo(playerRef) ;I just realized the player probably doesn't even have to be put in this alias for
			;										anything in this script to work, but we may as well keep things consistent, eh?
		endIf
		return false
	endif

	if chkTrapIndex == shortIndex
		return true
	endif 

	return false
EndFunction



;Bugfix function to break any ongoing loops in updateTrackedTrapsList()
Function TrackedTrapsUnlocker()
	int i = 7
	while i
		i -= 1
		nearbyTraps[i] = none
	endwhile
Endfunction



bool Function updateTrackedTrapsList() ;returns true if any traps are still left in tracking array (i.e. nearby, and not disarmed)

	bool hasTrap
	int trapCount
	while NTLock
		utility.wait(0.1) ;LOCK
	endWhile
	NTLock = true
	while trapCount < 7 ;change this if array size changes
		if nearbyTraps[trapCount]
			;check gem because this might be called right away after gem is disabled, trapBase may not have registered disarm yet:
			if ((nearbyTraps[trapCount].getLinkedRef() as trapSoulGemController).getState() == "disarmed") || !((nearbyTraps[trapCount] as MagicTrap).isLoaded)
				nearbyTraps[trapCount] = none
				;----------------------------SHIFT ARRAY ELEMENTS DOWN
				int shiftNum = trapCount + 1
				while nearbyTraps[shiftNum] && shiftNum < 7
					nearbyTraps[(shiftNum - 1)] = nearbyTraps[shiftNum]
					nearbyTraps[shiftNum] = none
					shiftNum += 1
				endWhile ;--------------------------------------------
				;dont increment trapCount this time (need to check same index)
			else
				hasTrap = true
				trapCount += 1
			endIf
		else
			trapCount = 8 ;force loop exit, 'none' encountered
		endif
	endWhile
	NTLock = false

	return hasTrap
EndFunction



Function findNearestTrapAndHandshakePlayer() ;finds the nearest active trap and performs the set-up required to allow player to absorb energy from it
	float shortDist = nearbyTraps[0].getDistance(playerRef)
	int shortIndex
	int trapCount = 1
	while NTLock
		utility.wait(0.1) ; LOCK
	endWhile
	NTLock = true
	while nearbyTraps[trapCount] && trapCount < 7 ;change if array size changes
		float thisDist = nearbyTraps[trapCount].getDistance(playerRef)
		if thisDist < shortDist
			shortIndex = trapCount
			shortDist = thisDist
		endif
		trapCount += 1
	endWhile
	NTLock = false
	goToState("")
	(nearbyTraps[shortIndex] as EA_HostileSoulGemTrapScript).handshakePlayer()
EndFunction



;============================= IDLE TRACKING STATE ===================================================================================================;
;																																					  ;
; The idle tracking state is used when the player has already absorbed the maximum amount of energy in a 3 day period from soul gem traps. This state ;
; will continue to monitor nearby traps, occasionally sending a message to the player letting them know that they can't absorb any more energy today  ;
;																																					  ;
;=====================================================================================================================================================;

State idleTracking

	Event onBeginState()
		registerForSingleUpdate(5.0) ;may be right next to another trap, but wait to convey message, player will already be getting boost messages
	EndEvent

	Event onUpdate()

		if !nearbyTraps[0]
			unregisterForUpdate()
			goToState("")
			self.clear()
			return
		endif

		float shortDist = nearbyTraps[0].getDistance(playerRef)
		int shortIndex
		int trapCount = 1
		while NTLock
			utility.wait(0.1) ; LOCK
		endWhile
		NTLock = true
		while nearbyTraps[trapCount] && trapCount < 7 ;change if array size changes
			float thisDist = nearbyTraps[trapCount].getDistance(playerRef)
			if thisDist < shortDist
				shortIndex = trapCount
				shortDist = thisDist
			endif
			trapCount += 1
		endWhile
		NTLock = false

		if shortDist < 800.0
			EATrapNoAbsorbMsg.show() ;You can't absorb any more gem energy today.
			registerForSingleUpdate(120.0)
			return
		elseif shortDist > 1600.0
			registerForSingleUpdate(6.0)
			return
		else ;800 <= shortDist <= 1600
			registerForSingleUpdate(3.0)
		endIf
	EndEvent

EndState



Event OnUpdateGameTime() ;called 72 hours after player gains a boost. Resets the bool to allow player to absorb new traps and gain new boosts.
	playerBoostedAlready = false
	if nearbyTraps[0] && getState() == "idleTracking"
			unregisterForUpdate()
			findNearestTrapAndHandshakePlayer()
	endif
EndEvent






;Called by MCM Config to swap the type of messages shown near hostile traps:
Function setHostileTrapMessageType(bool mType)
	if mType ;1st person
	  EATrapSensedMsg = EATrapSensedMsg1stP
	  EATrapEngagedMsg = EATrapEngagedMsg1stP
	  EATrapNoAbsorbMsg = EATrapNoAbsorbMsg1stP
	  EATrapHalfAbsorbMsg = EATrapHalfAbsorbMsg1stP
	  EATrapFullAbsorbMsg = EATrapFullAbsorbMsg1stP
	else ;2nd person
	  EATrapSensedMsg = EATrapSensedMsg2ndP
	  EATrapEngagedMsg = EATrapEngagedMsg2ndP
	  EATrapNoAbsorbMsg = EATrapNoAbsorbMsg2ndP
	  EATrapHalfAbsorbMsg = EATrapHalfAbsorbMsg2ndP
	  EATrapFullAbsorbMsg = EATrapFullAbsorbMsg2ndP
	endif
endFunction 