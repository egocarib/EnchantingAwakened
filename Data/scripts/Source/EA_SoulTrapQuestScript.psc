Scriptname EA_SoulTrapQuestScript extends Quest
{EA replacement soul trap effect quest}


;---PROPERTIES-------------------------------------------------------------------------------------------------------------------------
  
  bool property ShouldUseAzuraFirst = true auto hidden ;MCM option
  bool property NPCShouldUseAzuraFirst = true auto hidden ;MCM

  Formlist property EA_AzuraFillableGemForms auto


  ImageSpaceModifier property vanillaTrapImod auto
  Sound property vanillaTrapSoundFX auto
  VisualEffect property vanillaTargetVFX auto
  VisualEffect property vanillaCasterVFX auto 				;Soul Trap FX
  EffectShader property vanillaCasterFXS auto
  EffectShader property vanillaTargetFXS auto
  EffectShader property EA_SoulTrapFailureFXS auto
  EffectShader property EA_SoulTrapExtraEssenceFXS auto

  Actor property playerRef auto
  ObjectReference property playerObj auto

  Keyword property ActorTypeNPC auto

  SoulGem[] property fullGemsBase auto			; 0 = petty   1 = lesser   2 = common   3 = greater   4 = grand   5-9 = azura's star (petty-grand versions)
  SoulGem[] property emptyGemsBase auto 		; 0 = petty   1 = lesser   2 = common   3 = greater   4 = grand   5-9 = azura's star (duplicates of vanilla empty)
  int[] property emptyGemsCount auto hidden 	; 0 = petty   1 = lesser   2 = common   3 = greater   4 = grand   5 = azura's star
		;Indexical Referents:
		int property petty = 0 autoReadOnly
		int property lesser = 1 autoReadOnly
		int property common = 2 autoReadOnly
		int property greater = 3 autoReadOnly
		int property grand = 4 autoReadOnly
		int property azurasStar = 5 autoReadOnly
		int property azurasStarPetty = 5 autoReadOnly
		int property azurasStarLesser = 6 autoReadOnly
		int property azurasStarCommon = 7 autoReadOnly
		int property azurasStarGreater = 8 autoReadOnly
		int property azurasStarGrand = 9 autoReadOnly

  int property currentAzurasStarSize auto hidden; 0 = empty   1 = petty    2 = lesser   3 = common    4 = greater [no need to track grand]
  int property currentAzurasStarCharge auto hidden ;3000 = grand
  int[] property soulEnergyAmount auto hidden   ; 0 = 0       1 = 250      2 = 500      3 = 1000      4 = 2000     5 = 3000
  int[] property RemoveException auto hidden ;used when we don't want gem tracking script to react to removed item



  Perk property EA_EssenceGambit auto
  Perk property EA_EssenceModulation auto
  Perk property EA_EssenceNemesis auto

  Message[] property EASoulTrapSuccessMsg auto
  			;0 = EASoulTrapSuccessMsgPetty
  			;1 = EASoulTrapSuccessMsgLesser
  			;2 = EASoulTrapSuccessMsgCommon
  			;3 = EASoulTrapSuccessMsgGreater
  			;4 = EASoulTrapSuccessMsgGrand
  Message[] property EASoulTrapSuccessExtraMsg auto ;currently used message (2nd Person by default)
  			;1 = EASoulTrapSuccessExtraMsgLesser
  			;2 = EASoulTrapSuccessExtraMsgCommon
  			;3 = EASoulTrapSuccessExtraMsgGreater
  			;4 = EASoulTrapSuccessExtraMsgGrand
  Message[] property EASoulTrapSuccessExtraMsg2ndP auto ;second person messages
  			;1 = EASoulTrapSuccessExtraMsgLesser
  			;2 = EASoulTrapSuccessExtraMsgCommon
  			;3 = EASoulTrapSuccessExtraMsgGreater
  			;4 = EASoulTrapSuccessExtraMsgGrand
  Message[] property EASoulTrapSuccessExtraMsg1stP auto ;first person messages
  			;1 = EASoulTrapSuccessExtraMsgLesser1stP
  			;2 = EASoulTrapSuccessExtraMsgCommon1stP
  			;3 = EASoulTrapSuccessExtraMsgGreater1stP
  			;4 = EASoulTrapSuccessExtraMsgGrand1stP
  Message 	property EASoulTrapFailEssenceGambitMsg auto
  Message 	property EASoulTrapFailNoGemMsg auto


  Spell[] 		 property essenceNemesisSpells auto  ;all Essence Nemesis boost spells
  MagicEffect[] property essenceNemesisEffects auto ;effects associated with each EN spell, in same order
  Message[] 	 property essenceNemesisMsgs auto    ;message to display upon granting a particular EN spell
  EffectShader  property EA_EssenceNemesisKickstartFXShader auto ;FX for EN boost

  
  bool  property trapLock = false auto hidden


;---LOCALS-----------------------------------------------------------------------------------------------------------------------------
  int 	grandLvl = 38
  int 	greaterLvl = 28	;actor level thresholds for soul size (faster than querying game setting values)
  int 	commonLvl = 16
  int  	lesserLvl = 4

;  int 	currentEnchLvl
  int 	enchLvlCheck
  bool	extraBool
  bool 	trapLockNPC

  objectReference currentVictim

  ;PERK EFFECT VARIABLES (affect next soul trap)
  int 	EGValue = 0		 ;(Essence Gambit) 	    0 = normal soul trap,    12 = trap will fill a larger gem
  bool 	EGbool  = false ;(Essence Gambit) 	false = normal soul trap,  true = soul trap will fail
  bool 	ENbool  = false ;(Essence Nemesis) 	false = normal soul trap,  true = trap will grant stat boost



Event OnInit()
	EmptyGemsCount = new int[6]
	RemoveException = new int[1]
	soulEnergyAmount = new int[6]
	soulEnergyAmount[0] = 0
	soulEnergyAmount[1] = 250
	soulEnergyAmount[2] = 500
	soulEnergyAmount[3] = 1000
	soulEnergyAmount[4] = 2000
	soulEnergyAmount[5] = 3000
EndEvent


function SoulTrapCreature(Actor victim)
	
	int vLvl = victim.getLevel()
	if EGbool && (vLvl < grandLvl || utility.randomInt(0, 1)) 	;50% chance not to fail for grand size soul steal
		while trapLOCK
			utility.wait(0.2)
		endWhile
		trapLock = true
		calcEssencePerkEffects()
		EA_SoulTrapFailureFXS.Play(victim, 2.3)
		trapLock = false
		EASoulTrapFailEssenceGambitMsg.show()
		grantHalfXPGain()


	else
		while trapLOCK
			utility.wait(0.2)	;LOCK to prevent processing more than one soul trap simultaneously
		endWhile
		trapLOCK = true

		currentVictim = victim as objectReference

		bool useAzura = ShouldUseAzuraFirst && (emptyGemsCount[azurasStar] > 0 || currentAzurasStarSize > 0)
		

		; MAIN SOUL TRAP LOGIC BLOCK
		;-------------------------------------------------------------------------Petty----->
		if vLvl < lesserLvl - EGValue
			if emptyGemsCount[petty] && !useAzura
				extraBool = false
				fillGemTrap(petty)
				grantFullXPGain()
			elseif currentAzurasStarSize
				extraBool = false
				fillGemTrap(petty, addToCurrentAzura = true)
				grantFullXPGain()
			elseif emptyGemsCount[azurasStar]
				extraBool = false
				fillGemTrap(azurasStarPetty)
				grantFullXPGain()
			else
				trapLOCK = false
				EASoulTrapFailNoGemMsg.show()
				EA_SoulTrapFailureFXS.Play(currentVictim, 2.3)
				grantHalfXPGain()
			endif
		;-------------------------------------------------------------------------Lesser---->
		elseif vLvl < commonLvl - EGValue
			if emptyGemsCount[lesser] && !useAzura
				extraBool = EGValue as bool
				fillGemTrap(lesser)
				grantFullXPGain()
			elseif currentAzurasStarSize
				extraBool = EGValue as bool
				fillGemTrap(lesser, addToCurrentAzura = true)
				grantFullXPGain()
			elseif emptyGemsCount[azurasStar]
				extraBool = EGValue as bool
				fillGemTrap(azurasStarLesser)
				grantFullXPGain()
			elseif EGbool && emptyGemsCount[petty]
				extraBool = false
				fillGemTrap(petty)
				grantFullXPGain()
			else
				trapLOCK = false
				EASoulTrapFailNoGemMsg.show()
				EA_SoulTrapFailureFXS.Play(currentVictim, 2.3)
				grantHalfXPGain()
			endif
		;-------------------------------------------------------------------------Common---->
		elseif vLvl < greaterLvl - EGValue
			if emptyGemsCount[common] && !useAzura
				extraBool = EGValue as bool
				fillGemTrap(common)
				grantFullXPGain()
			elseif currentAzurasStarSize
				extraBool = EGValue as bool
				fillGemTrap(common, addToCurrentAzura = true)
				grantFullXPGain()
			elseif emptyGemsCount[azurasStar]
				extraBool = EGValue as bool
				fillGemTrap(azurasStarCommon)
				grantFullXPGain()
			elseif EGbool && emptyGemsCount[lesser]
				extraBool = false
				fillGemTrap(lesser)
				grantFullXPGain()
			else
				trapLOCK = false
				EASoulTrapFailNoGemMsg.show()
				EA_SoulTrapFailureFXS.Play(currentVictim, 2.3)
				grantHalfXPGain()
			endif
		;-------------------------------------------------------------------------Greater--->
		;											  (if EGValue is 12, change it to 10)
		elseif vLvl < grandLvl - math.floor((EGValue as float) * 0.9)
			if emptyGemsCount[greater] && !useAzura
				extraBool = EGValue as bool
				fillGemTrap(greater)
				grantFullXPGain()
			elseif currentAzurasStarSize
				extraBool = EGValue as bool
				fillGemTrap(greater, addToCurrentAzura = true)
				grantFullXPGain()
			elseif emptyGemsCount[azurasStar]
				extraBool = EGValue as bool
				fillGemTrap(azurasStarGreater)
				grantFullXPGain()
			elseif EGbool && emptyGemsCount[common]
				extraBool = false
				fillGemTrap(common)
				grantFullXPGain()
			else
				trapLOCK = false
				EASoulTrapFailNoGemMsg.show()
				EA_SoulTrapFailureFXS.Play(currentVictim, 2.3)
				grantHalfXPGain()
			endif
		;-------------------------------------------------------------------------Grand----->
		else
			if emptyGemsCount[grand] && (!useAzura || emptyGemsCount[azurasStar] == 0) ;fill grand gem instead of already partially filled azura
				extraBool = EGValue as bool
				fillGemTrap(grand)
				grantFullXPGain()
			elseif emptyGemsCount[azurasStar]
				extraBool = EGValue as bool
				fillGemTrap(azurasStarGrand)
				grantFullXPGain()
			elseif (vLvl < grandLvl) && emptyGemsCount[greater]
				extraBool = false
				fillGemTrap(greater)
				grantFullXPGain()
			else
				trapLOCK = false
				EASoulTrapFailNoGemMsg.show()
				EA_SoulTrapFailureFXS.Play(currentVictim, 2.3)
				grantHalfXPGain()
			endif
		endif
	endif
endFunction


function fillGemTrap(int gemSize, bool addToCurrentAzura = false)
	int soulSize = gemSize % 5 ;in case of azura
	calcEssencePerkEffects()

  ;--------------------------------------SOUL TRAP SUCCESS FX----------------------------------------------
	vanillaTrapSoundFX.play(playerObj)           			 ; play sound from caster
	vanillaTrapImod.apply()                   				 ; apply isMod at full strength
	vanillaTargetVFX.Play(currentVictim, 4.7, playerObj) 	 ; play TargetVFX and face them towards the caster
	vanillaCasterVFX.Play(playerObj, 5.9, currentVictim) 	 ; play CasterVFX and face them towards the victim
	if extraBool														 ; play conditionalized Effect Shaders:
		EA_SoulTrapExtraEssenceFXS.Play(currentVictim, 1.2) ;
		EASoulTrapSuccessExtraMsg[soulSize].show()  			 ; You draw forth extra essence! <Size> soul captured!
	else 																	 ;
		vanillaTargetFXS.Play(currentVictim, 2.0) 			 ;
		EASoulTrapSuccessMsg[soulSize].show()		 			 ; <Size> soul captured!
	endif 																 ;
	vanillaCasterFXS.Play(playerObj, 3.0) 						 ;
  ;--------------------------------------------------------------------------------------------------------

	if ENbool
		grantStatBoostShort(soulSize)
	endif

	if (addToCurrentAzura)
		gemSize += 1 ;(offset to correctly correlate currentAzurasStarSize & gemSize)
		currentAzurasStarCharge += soulEnergyAmount[gemSize]
		if (currentAzurasStarCharge >= soulEnergyAmount[currentAzurasStarSize + 1])
			int azuraIndex = currentAzurasStarSize + 4 ;offset
			RemoveException[0] = RemoveException[0] + 1 ;flag this removal for gem tracking script
			playerObj.removeItem(fullGemsBase[azuraIndex], 1, true)
			while (currentAzurasStarSize < 5) && (currentAzurasStarCharge >= soulEnergyAmount[currentAzurasStarSize + 1])
				currentAzurasStarSize += 1
				azuraIndex += 1
			endWhile
			if (currentAzurasStarSize == 5)
				currentAzurasStarCharge = 0 ;reset
				currentAzurasStarSize = 0 ;reset
			endif
			trapLOCK = false
			playerObj.addItem(fullGemsBase[azuraIndex], 1, true)
		else
			trapLOCK = false
		endif

	else ;not adding to a pre-existing filled azura star:
		playerObj.removeItem(emptyGemsBase[gemSize], 1, true)
		if (gemSize > 4 && gemSize < 9) ;azura's star petty-greater
			currentAzurasStarSize = (gemSize - 4)
			currentAzurasStarCharge = soulEnergyAmount[currentAzurasStarSize]
		endif
		trapLOCK = false
		playerObj.addItem(fullGemsBase[gemSize], 1, true)

	endif
endFunction


function SoulTrapHuman(Actor victim)

	if EGbool && utility.randomInt(0, 1) ;50% less chance to fail for grand size soul steal
		while trapLOCK 			 ;
			utility.wait(0.2)		 ;
	   endWhile						 ; LOCK
	   trapLock = true 			 ;
	   calcEssencePerkEffects() 
	   trapLock = false 			 

		EASoulTrapFailEssenceGambitMsg.show()
		EA_SoulTrapFailureFXS.Play(victim, 2.3)
		grantHalfXPGain()

	elseif playerRef.trapSoul(victim)
		while trapLOCK 					;
			utility.wait(0.2)				;
		endWhile								; LOCK
		trapLock = true 					;
		calcEssencePerkEffects() 		

		;-----------------------------------SOUL TRAP SUCCESS FX---------------------------------------
		vanillaTrapSoundFX.play(playerObj)            ; play sound from caster
		vanillaTrapImod.apply()                   	 ; apply isMod at full strength
		vanillaTargetVFX.Play(victim, 4.7, playerObj) ; play TargetVFX and face them towards the caster
		vanillaCasterVFX.Play(playerObj, 5.9, victim) ; play CasterVFX and face them towards the victim	
		vanillaTargetFXS.Play(victim, 2.0) 			 	 ; play basic EffectShader	
		vanillaCasterFXS.Play(playerObj, 3.0) 			 ;
		;----------------------------------------------------------------------------------------------

		if ENbool 
			trapLOCK = false
			grantStatBoostShort(grand) 
		else 									
			trapLock = false
		endif
		grantFullXPGain()

	else 	; I assume trapSoul() sends its own message about not having the right size gem?
		while trapLOCK 			 ;
			utility.wait(0.2)		 ;
	   endWhile						 ; LOCK
	   trapLock = true 			 ;
	   calcEssencePerkEffects() 
	   trapLock = false 			 

		EA_SoulTrapFailureFXS.Play(victim, 2.3)
		grantHalfXPGain()
	endif
endFunction


function NPCSoulTrap(Actor victim, Actor caster)
	if victim.hasKeyword(ActorTypeNPC)
		if caster.TrapSoul(victim) == true
			trapSuccessFXforNPC(victim, caster)
		else
			EA_SoulTrapFailureFXS.Play(victim, 2.3)
		endif
	else
		int gemSize
		int vLvl = victim.getLevel()
		if vLvl < lesserLvl
			gemSize = 0
		elseif vLvl < commonLvl
			gemSize = 1
		elseif vLvl < greaterLvl
			gemSize = 2
		elseif vLvl < grandLvl
			gemSize = 3
		else
			gemSize = 4
		endif
		while trapLockNPC
			utility.wait(0.2)
		endWhile
		trapLockNPC = true

		int azuraCount = -1
		bool azuraFirst = false
		if NPCShouldUseAzuraFirst
			azuraCount = caster.getItemCount(EA_AzuraFillableGemForms)
			azuraFirst = azuraCount as bool
		endif

		;Normal Soul Gem
		if (!azuraFirst) && caster.getItemCount(emptyGemsBase[gemSize])
			caster.removeItem(emptyGemsBase[gemSize], 1, true)
			trapLockNPC = false
			caster.addItem(fullGemsBase[gemSize], 1, true)
			trapSuccessFXforNPC(victim, caster)

		;Azura's Star Variant
		  ;[Working under assumption that only 1 azura's star exists. Otherwise weird stuff will happen, though probably not game-breaking]
		elseif (azuraCount > 0) || ((azuraCount == -1) && caster.getItemCount(EA_AzuraFillableGemForms))

			;find gem held, then add new charge, and decide whether to increase gem size or not
			SoulGem oldGem = none
			SoulGem newGem = none

			if caster.getItemCount(emptyGemsBase[5]) ;empty azura star
				oldGem = emptyGemsBase[5]
				currentAzurasStarCharge = soulEnergyAmount[gemSize + 1]
				newGem = fullGemsBase[gemSize + 5]
			else ;add to a partially filled azura's star
				int i = 5
				while i < 9
					if caster.getItemCount(fullGemsBase[i])
						oldGem = fullGemsBase[i]
						currentAzurasStarCharge += soulEnergyAmount[gemSize + 1]
						int newGemSize = i - 4
						while (newGemSize < 5) && (currentAzurasStarCharge >= soulEnergyAmount[newGemSize + 1])
							newGemSize += 1
						endWhile
						newGemSize += 4
						newGem = fullGemsBase[newGemSize]
						if (newGemSize == 9) ;grand
							currentAzurasStarCharge = 0 ;reset
						endif
						i = 8 ;force loop exit
					endif
					i += 1
				endWhile
			endif

			if (oldGem != none) ;check just in case
				if (oldGem != newGem)
					caster.removeItem(oldGem)
					caster.addItem(newGem)
				endif
				trapLockNPC = false
				trapSuccessFXforNPC(victim, caster)
			else
				trapLockNPC = false
				EA_SoulTrapFailureFXS.Play(victim, 2.3)
			endif
		else
			trapLockNPC = false
			EA_SoulTrapFailureFXS.Play(victim, 2.3)
		endif
	endif
endFunction


function trapSuccessFXforNPC(Actor victim, Actor caster);, bool tookExtraEssence)
	vanillaTrapSoundFX.play(caster)           		; play sound from caster
	vanillaTrapImod.apply()                   		; apply isMod at full strength
	vanillaTargetVFX.Play(victim, 4.7, caster) 		; play TargetVFX and face them towards the caster
	vanillaCasterVFX.Play(caster, 5.9, victim) 		; play CasterVFX and face them towards the victim
	vanillaTargetFXS.Play(victim, 2.0) 					; play EffectShaders
	vanillaCasterFXS.Play(caster, 3.0) 					;
endFunction


function grantStatBoostShort(int soulSize)
	;grant Essence Nemesis perk absorbed power 
	;display essenceNemesisMsgs[]  ("<Name> power absorbed!")

	if soulSize < utility.randomInt(-1, 4) 	;grand soul = 100% chance this boost will occur,
		return 											;greater = 83%, common = 67%, lesser = 50%, petty = 33%
	endif 												;(less likely to get boosted from a skeever than a human)

	EA_EssenceNemesisKickstartFXShader.play(playerObj, 3.0)
	utility.wait(0.95)

	int numSpells = essenceNemesisSpells.Length
	int randSpell = utility.randomInt(0, (numSpells - 1))
	if !playerRef.hasMagicEffect(essenceNemesisEffects[randSpell])
		essenceNemesisSpells[randSpell].cast(playerObj, playerObj)
		essenceNemesisMsgs[randSpell].show()
	else ;try to pick different random spell. number of attempts capped as a failsafe
		int maxAttempts = 5
		while playerRef.hasMagicEffect(essenceNemesisEffects[randSpell]) && maxAttempts
			maxAttempts -= 1
			randSpell = utility.randomInt(0, (numspells - 1))
		endWhile
		essenceNemesisSpells[randSpell].cast(playerObj, playerObj)
		essenceNemesisMsgs[randSpell].show()
	endif
endFunction



;these XP gain settings seem to be good levels for "normal" play. I'd personally prefer them to be slighly less,
; but the same is true of general enchanting XP gain, so I will let the skill mult preferences/options adjust
; both of them for players who would like to.
function grantFullXPGain()
	;Base XP granted for successful soul trap. Although this amount increases based on level, it actually decreases
	; quite noticeably as far as the PERCENTAGE it grants towards what is needed to get to the next skill level.
	game.advanceSkill("Enchanting", (0.05 + 0.0022 * playerRef.getActorValue("Enchanting")))
	game.incrementStat("Souls Trapped")
endFunction

function grantHalfXPGain()
	;About half as much XP granted if soul trap only partially succeeds (e.g. player doesn't have right size gem)
	game.advanceSkill("Enchanting", (0.025 + 0.0011 * playerRef.getActorValue("Enchanting")))
		;(note: this seems to grant slightly less than half, cant figure out how the game formula works exactly.)
endFunction



;=======================================================================================================================>>>
; ESSENCE PERK EFFECTS Calculation Script ===============================================================================>>>
;=======================================================================================================================>>>
;  calcEssencePerkEffects() is called to recalculate Essence Perk-related effect variables
;  every time that the player uses a Soul Trap or gains an Enchanting skill level. State
;  changes handled in perk quest script. Formula notes at the end of this script segment.

float property essNemCustomMult = 1.0 auto hidden


;empty state, no Essence perks unlocked
function calcEssencePerkEffects()
endFunction

;only Essence Gambit unlocked
State CalcStateEssenceGambit
	function calcEssencePerkEffects()
		EGValue = 0
		EGbool = false 	;reset values
		float calcLvlMax = playerRef.GetActorValue("Enchanting")

		if calcLvlMax > 180.0
		calcLvlMax = 180.0
		endif
			float extraSoulPct = 0.0043 * calcLvlMax - 0.1

		if calcLvlMax > 130.0
		calcLvlMax = 130.0
		endif
			float failurePct = (0.08 - calcLvlMax / 2000.0) * (1.2 - calcLvlMax / 200.0)

		;Set Essence Gambit Variables
		float randNum = utility.randomFloat()
		if (randNum < failurePct)
			EGbool = true
		elseif (randNum < (extraSoulPct + failurePct))
			EGValue = 12
		endif
	endFunction
EndState

;only Essence Nemesis unlocked
State CalcStateEssenceNemesis
	function calcEssencePerkEffects()
		ENbool = false 	;reset value
		float calcLvlMax = playerRef.GetActorValue("Enchanting")

		if calcLvlMax > 180.0
		calcLvlMax = 180.0
		endif
			float statBoostPct = (calcLvlMax - 25.0) / 4000.0 * essNemCustomMult

		;Set Essence Nemesis Variables
		if utility.randomFloat() < statBoostPct
			ENbool = true
		endif
	endFunction
EndState

;both Essence perks are unlocked
State CalcStateEssenceBoth
	function calcEssencePerkEffects()
		EGValue = 0
		EGbool = false 	;reset values
		ENbool = false
		float calcLvlMax = playerRef.GetActorValue("Enchanting")

		if calcLvlMax > 180.0
		calcLvlMax = 180.0
		endif
			float extraSoulPct = 0.0043 * calcLvlMax - 0.1
			float statBoostPct = (calcLvlMax - 25.0) / 4000.0 * essNemCustomMult

		if calcLvlMax > 130.0
		calcLvlMax = 130.0
		endif
			float failurePct = (0.08 - calcLvlMax / 2000.0) * (1.2 - calcLvlMax / 200.0)

		;Set Essence Gambit Variables
		float randNum = utility.randomFloat()
		if (randNum < failurePct)
			EGbool = true
		elseif (randNum < (extraSoulPct + failurePct))
			EGValue = 12
		endif

		;Set Essence Nemesis Variables
		if utility.randomFloat() < statBoostPct
			ENbool = true
		endif
	endFunction
EndState

;Essence Perk Effect Formula Notes:

		;ESSENCE GAMBIT >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
		;
		;    -EXTRA ESSENCE % formula = 0.0043 * EnchLvl - 0.1
		;			lvl35 = 0.0505		lvl80  = 0.244		lvl140 = 0.502
		;			lvl40 = 0.072 		lvl100 = 0.33 		lvl160 = 0.588
		;			lvl60 = 0.158 		lvl120 = 0.416		lvl180 = 0.674 (CAPPED MAX)
		;    -FAILURE % formula = (.08 - enchlvl / 2000) * (1.2 - enchLvl / 200)
		;			lvl35 = .064 		lvl80  = .032 		lvl130 = 0.008 (CAPPED MIN)
		;			lvl40 = .060		lvl100 = .021		lvl140 = 0.008 (1 in 125 chance to fail)
		;			lvl60 = .045 		lvl120 = .012     lvl... = 0.008
		;    -RECHARGE WEAP ON KILL % formula = (0.0012 * EnchLvl)  [12% at level 100]
		;			!NOW HANDLED VIA PERK ENTRY POINTS

		;ESSENCE NEMESIS >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
		;
		;	  -STAT BOOST % formula = (enchLvl - 25) / 4000
		;			lvl 65  = 1% (.01)
		;			lvl 105 = 2% (.02)
		;			lvl 145 = 3% (.03)
		;			lvl 185 = 4% (CAPPED)
		;	  -RECHARGE WEAP ON KILL % formula = (.00035 * EnchLvl)  [3.5% at level 100]
		;			!NOW HANDLED VIA PERK ENTRY POINTS

;=======================================================================================================================>>>
; END ESSENCE PERK EFFECTS Calculation Script ===========================================================================>>>
;=======================================================================================================================>>>



;Variables and function used to pass along message to player trying to trap human soul without correct Essence perk:
Message property EASoulTrapFailNoHumanMsg auto ;message used (2nd person by default)
Message property EASoulTrapFailNoHumanMsg1stP auto ;1st person variant
Message property EASoulTrapFailNoHumanMsg2ndP auto ;2nd person variant

Function sendNoHumanSoulTrapMessage() ;called from soul trap effect script. Throttles "You cant trap human souls" message spam.
	float nowTime = utility.getCurrentRealTime()
	if (nowTime - msgTimer) > 30.0
		EASoulTrapFailNoHumanMsg.show()
	endif
	msgTimer = nowTime
endFunction

float msgTimer = -30.0
Function resetMessageTimer()
	msgTimer = -30.0
EndFunction




;Called by MCM Config to swap the type of messages shown during soul trap:
Function setSoulTrapMessageType(bool mType)
	if mType ;first person messages
		EASoulTrapSuccessExtraMsg[1] = EASoulTrapSuccessExtraMsg1stP[1]
		EASoulTrapSuccessExtraMsg[2] = EASoulTrapSuccessExtraMsg1stP[2]
		EASoulTrapSuccessExtraMsg[3] = EASoulTrapSuccessExtraMsg1stP[3]
		EASoulTrapSuccessExtraMsg[4] = EASoulTrapSuccessExtraMsg1stP[4]
		EASoulTrapFailNoHumanMsg = EASoulTrapFailNoHumanMsg1stP
	else ;second person messages
		EASoulTrapSuccessExtraMsg[1] = EASoulTrapSuccessExtraMsg2ndP[1]
		EASoulTrapSuccessExtraMsg[2] = EASoulTrapSuccessExtraMsg2ndP[2]
		EASoulTrapSuccessExtraMsg[3] = EASoulTrapSuccessExtraMsg2ndP[3]
		EASoulTrapSuccessExtraMsg[4] = EASoulTrapSuccessExtraMsg2ndP[4]
		EASoulTrapFailNoHumanMsg = EASoulTrapFailNoHumanMsg2ndP
	endif
endfunction