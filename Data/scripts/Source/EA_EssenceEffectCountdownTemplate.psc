Scriptname EA_EssenceEffectCountdownTemplate extends ActiveMagicEffect

;this script allows Essence Modulation absorbed powers to have a duration
;in GAME TIME instead of real time. The script assumes the inputted spell
;has a duration of a certain number of days (it updates every 24 hours).

;It will update the player with a new version of the spell each day, also
;displaying a message to the screen indicating the remaining time of the
;spell, and playing any visual FX filled into the appropriate properties.
;In the current setup, the new version of the spell is the same, but has
;a new description that indicates its remaining duration to the player
;when viewed in the Magic Effects UI



;SPELLs -------------------------------------------->
  Spell[]  property spellList auto ;a list of spells to apply daily, indexed in the order they should be applied, beginning at array element 0
  Spell    property controllingSpell auto ;the spell that this controller effect originates from

;MSGs ---------------------------------------------->
  Formlist property spellMsgs auto
	;0  <Name> power removed.
	;1  <Name> power: One day remaining.
	;2  <Name> power: Two days remaining.
	;3  <Name> power: Three days remaining.
	;4  <Name> power: Four days remaining.
	;5  <Name> power: Five days remaining.
	;6  <Name> power: Six days remaining.
	;7  <Name> power: Seven days remaining.
  Message  property EAEssenceAllPowersDispelMsg auto
  Message  property EAEssenceAllPowersDispelMsg1stP auto
	;The last of your absorbed essence escapes.
  GlobalVariable property ShowAbsorbedPowerDailyMsg auto
  	;player can toggle this to 0 to remove daily messages
  GlobalVariable property EA_1stPersonMessages auto
    ;player can toggle between 1st & 2nd person messages

;FX ------------------------------------------------>
  EffectShader property EA_EssenceModulationStartFX auto
  EffectShader property EA_EssenceModulationDailyFX auto
  EffectShader property EA_EssenceModulationFinishFX auto

;LOCALS -------------------------------------------->
  Actor spellTarget
  int totalSpells
  int currentSpell = 0
  int lastCastSpell = 0
  bool dispelled = false


Event onInit()
	totalSpells = spellList.Length
EndEvent


Event onEffectStart(Actor akTarget, Actor akCaster)
	spellTarget = akTarget
	spellTarget.addSpell(spellList[currentSpell], true) ;sends addspell message, in addition to absorb message already sent by trap script.
	EA_EssenceModulationStartFX.play(spellTarget, 15.0)
	registerForSingleUpdateGameTime(24.0)
EndEvent


Event onUpdateGameTime()
	currentSpell += 1

	if currentSpell == totalSpells
		dispelled = true
		spellTarget.removeSpell(spellList[lastCastSpell])
		EA_EssenceModulationFinishFX.play(spellTarget, 6.0)
    if EA_1stPersonMessages.getValue()
      EAEssenceAllPowersDispelMsg1stP.show()
    else
		  EAEssenceAllPowersDispelMsg.show() 					;show universal dispel message
    endif
		utility.wait(1.5)
		(spellMsgs.getAt(0) as Message).show() 				;show effect-specific dispel message
		spellTarget.removeSpell(controllingSpell) 			;spell sequence finished; dispel this controller effect
		;dispel() 
		return
	endif

	registerForSingleUpdateGameTime(24.0)

	;avoid displaying message in the middle of combat
	while spellTarget.isInCombat() && !dispelled
		utility.wait(50.0)
	endwhile

	;wait for player to exit any menus
	utility.wait(0.001)

	;fringe case IF check -- if combat has prevented message from displaying more than a whole day, make
	;sure spell is still active & avoid double-casting/messaging if there are any stacked update events
	if !dispelled && !spellTarget.hasSpell(spellList[currentSpell])
		spellTarget.addSpell(spellList[currentSpell], false)
		spellTarget.removeSpell(spellList[lastCastSpell])
		lastCastSpell = currentSpell
		if ShowAbsorbedPowerDailyMsg.getValue()
			EA_EssenceModulationDailyFX.play(spellTarget, 8.0) ;daily FX
			utility.wait(1.5)
			(spellMsgs.getAt(totalSpells - currentSpell) as Message).show() ;daily countdown message
		endif
	endif
EndEvent


Event onEffectFinish(Actor akTarget, Actor akCaster)
	if spellTarget.hasSpell(spellList[lastCastSpell]) ;in case this controller effect somehow gets dispelled early
		spellTarget.dispelspell(spellList[lastCastSpell]) 
		(spellMsgs.getAt(0) as Message).show() ;show effect ending message
	endif
	unregisterForUpdateGameTime() ;this shouldn't be necessary, but better to be safe.
EndEvent