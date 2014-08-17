Scriptname EA_DynamicRobeMagickaRegen extends ActiveMagicEffect
{makes magicka regen for robes scale with Enchanting level and Perks}


;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
;										  >>>
;  FORTIFY MAGICKA REGEN				  >>>
;  MASTER FORMULA						  >>>
;										  >>>
;     y = 8.7(b^x)+c					  >>>
;										  >>>
;  where:								  >>>
;    y = Fortify Regen %				  >>>
;    x = EnchLvl						  >>>
;    c = 0.5 * EnchLvl					  >>>
;    b = 1.0279 - (0.00009 * EnchLvl)	  >>>
;										  >>>
;										  >>>
;										  >>>
;   Here is a calculated preview:		  >>>
;										  >>>
;   EnchLvl   Fortify %   				  >>>
;   -------   ---------   				  >>>
;   10        16  %       				  >>>
;   20        24  %       				  >>>
;   30        33  %       				  >>>
;   40        43  %       	 			  >>>
;   50        52  %       	 			  >>>
;   60        63  %       	 			  >>>
;   70        74  %       				  >>>
;   80        85  %       				  >>>
;   90        96  %       				  >>>
;   100       106 %       				  >>>
;   110       117 %       				  >>>
;   120       126 %       	 			  >>>
;   130       135 %       	 			  >>>
;   140       143 %       				  >>>
;   150       149 %       	 		      >>>
;   200		  162 %						  >>>
;						 			      >>>
;	these are BASE values that will also  >>>
;   be affected by perk power increases	  >>>
;										  >>>
;	Example: with soulshaper 3/3,		  >>>
;	aetherseeker 3/3, and aetherstrider,  >>>
;	Fortify Conjuration and Magicka       >>>
;	Regen will yield a 175% Regen Rate	  >>>
;	at level 100 enchanting	(and higher   >>>
;   if combining two regen enchants)      >>>
;										  >>>
;   With level 200 enchanting, a corpus   >>>
;   enchanter will achieve 400% regen.    >>>
;										  >>>
;   With level 200 enchanting, an aether  >>>
;   enchanter will achieve 530% regen if  >>>
;   combining the two aether-based magic  >>>
;   & regen enchantments on a single      >>>
;   item, & this is the max possible % 	  >>>
;										  >>>
;   Whenever more than one fortify magic  >>>
;   and regen buff is placed on a single  >>>
;   item, the effects are added together  >>>
;   after being scaled as follows:        >>>
;     most powerful effect:  FULL POWER   >>>
;     second most powerful:  2/3 POWER    >>>
;     third most powerful:   1/3 POWER    >>>
;										  >>>
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>



; Properties
Perk Property EA_SoulShaper02 auto
Perk Property EA_SoulShaper03 auto
Perk Property EA_AetherSeeker01 auto
Perk Property EA_AetherSeeker02 auto
Perk Property EA_AetherSeeker03 auto
Perk Property EA_AetherStrider auto
Perk Property EA_ChaosDisciple01 auto
Perk Property EA_ChaosDisciple02 auto
Perk Property EA_ChaosDisciple03 auto
Perk Property EA_ChaosMaster auto
Perk Property EA_ChaoticDissonance auto
Perk Property EA_CorpusScholar01 auto
Perk Property EA_CorpusScholar02 auto
Perk Property EA_CorpusScholar03 auto
Perk Property EA_CorpusGuardian auto
Perk Property EA_GuardiansVigor auto

FormList Property EA_AetherRobeMGEFList auto
FormList Property EA_ChaosRobeMGEFList auto
FormList Property EA_CorpusRobeMGEFList auto

Spell[] Property RegenSpellArray auto

Actor Property PlayerRef auto

GlobalVariable Property ShowMagickaRegenBuffs auto
GlobalVariable property EA_RobeRegenCalcActiveBool auto

Message Property EARobesMagRegenRateMsg auto


; Locals
float EnchLvl    		;Player's current (unbuffed) Enchanting Level
float CRR        		;C.R.R. = Calculated Regen Rate
int SpellIndex

int[] numEffectsByType   ; 0 - tally of Aether effects,   1 = tally of Corpus effects,   2 = tally of Chaos effects
	int property aether = 0 autoreadonly
	int property corpus = 1 autoreadonly
	int property chaos = 2 autoreadonly
float[] effectMultipliers  ;holds individual multipliers for each fortify magic/regen enchantment on this item
int eMultIndex



Event onInit()
	numEffectsByType = new int[3]
	effectMultipliers = new float[3]
EndEvent


Event onEffectStart(Actor akTarget, Actor akCaster)
	if (akTarget == playerRef)

		if !EA_RobeRegenCalcActiveBool.GetValue()
			EA_RobeRegenCalcActiveBool.SetValue(1.0)   ;when multiple robe regen enchants are on a single item, this lets only one script do the calculations
		else
			return
		endif


		;classify all active effects by the enchanting school they are associated with:
			int iEffects
			int FLsize
			FLsize = EA_AetherRobeMGEFList.GetSize()
			While (FLsize > 0)
				FLsize -= 1
				if (PlayerRef.HasMagicEffect(EA_AetherRobeMGEFList.GetAt(FLsize) as MagicEffect))
					numEffectsByType[aether] = numEffectsByType[aether] + 1
					iEffects += 1
				endif
			endWhile

			FLsize = EA_CorpusRobeMGEFList.GetSize()
			While (FLsize > 0)
				FLsize -= 1
				if (PlayerRef.HasMagicEffect(EA_CorpusRobeMGEFList.GetAt(FLsize) as MagicEffect))
					numEffectsByType[corpus] = numEffectsByType[corpus] + 1
					iEffects += 1
				endif
			endWhile

			FLsize = EA_ChaosRobeMGEFList.GetSize()
			While (FLsize > 0)
				FLsize -= 1
				if (PlayerRef.HasMagicEffect(EA_ChaosRobeMGEFList.GetAt(FLsize) as MagicEffect))
					numEffectsByType[chaos] = numEffectsByType[chaos] + 1
					iEffects += 1
				endif
			endWhile


		;set baseline multipliers based on Soul Shaper perk bonuses
			;if (PlayerRef.HasPerk(EA_SoulShaper03))
				while iEffects 								;the rest is commented out because players can now only
					iEffects -= 1 							;use this enchantment if they have the EA_SoulShaper03
					effectMultipliers[iEffects] = 1.10 		;perk. Thus, the multiplier should always be 1.10
				endWhile
			;elseif (PlayerRef.HasPerk(EA_SoulShaper02))
			;	while iEffects
			;		iEffects -= 1
			;		effectMultipliers[iEffects] = 1.05
			;	endWhile
			;else
			;	while iEffects
			;		iEffects -= 1
			;		effectMultipliers[iEffects] = 1.00
			;	endWhile
			;endif


	    ;compute all school-specific perk multipliers
	    	float calcMult
	    	;AETHER------------------------------------------------------------------------->
	    	if numEffectsByType[aether]
	    		calcMult = 1.0

				if (PlayerRef.HasPerk(EA_AetherSeeker03))
					calcMult *= 1.15
				elseif (PlayerRef.HasPerk(EA_AetherSeeker02))
					calcMult *= 1.10
				elseif (PlayerRef.HasPerk(EA_AetherSeeker01))
					calcMult *= 1.05
				endif

				if (PlayerRef.HasPerk(EA_AetherStrider))
					calcMult *= 1.30
				elseif (PlayerRef.HasPerk(EA_ChaosMaster) || PlayerRef.HasPerk(EA_CorpusGuardian))
					calcMult *= 0.80
				endif

	    		;apply this mult to all aether effects in the list
	    		while numEffectsByType[aether]
	    			numEffectsByType[aether] = numEffectsByType[aether] - 1
	    			effectMultipliers[eMultIndex] = effectMultipliers[eMultIndex] * calcMult
	    			eMultIndex += 1
	    		endWhile
	    	endif

	    	;CORPUS------------------------------------------------------------------------->
	    	if numEffectsByType[corpus]
	    		calcMult = 1.0

				if (PlayerRef.HasPerk(EA_CorpusScholar03))
					calcMult *= 1.15
				elseif (PlayerRef.HasPerk(EA_CorpusScholar02))
					calcMult *= 1.10
				elseif (PlayerRef.HasPerk(EA_CorpusScholar01))
					calcMult *= 1.05
				endif

				if (PlayerRef.HasPerk(EA_CorpusGuardian))
					calcMult *= 1.30
				elseif (PlayerRef.HasPerk(EA_AetherStrider) || PlayerRef.HasPerk(EA_ChaosMaster))
					calcMult *= 0.80
				endif

				;Guardian's Vigor Perk bonus
				if (PlayerRef.HasPerk(EA_GuardiansVigor))
					calcMult *= 1.5
				endif

				;apply this mult to all corpus effects in the list
	    		while numEffectsByType[corpus]
	    			numEffectsByType[corpus] = numEffectsByType[corpus] - 1
	    			effectMultipliers[eMultIndex] = effectMultipliers[eMultIndex] * calcMult
	    			eMultIndex += 1
	    		endWhile
	    	endif

	    	;CHAOS-------------------------------------------------------------------------->
	    	if numEffectsByType[chaos]
	    		calcMult = 1.0

				if (PlayerRef.HasPerk(EA_ChaosDisciple03))
					calcMult *= 1.15
				elseif (PlayerRef.HasPerk(EA_ChaosDisciple02))
					calcMult *= 1.10
				elseif (PlayerRef.HasPerk(EA_ChaosDisciple01))
					calcMult *= 1.05
				endif

				if (PlayerRef.HasPerk(EA_ChaosMaster))
					calcMult *= 1.30
				elseif (PlayerRef.HasPerk(EA_AetherStrider) || PlayerRef.HasPerk(EA_CorpusGuardian))
					calcMult *= 0.80
				endif

	    		;apply this mult to all chaos effects in the list
	    		while numEffectsByType[chaos]
	    			numEffectsByType[chaos] = numEffectsByType[chaos] - 1
	    			effectMultipliers[eMultIndex] = effectMultipliers[eMultIndex] * calcMult
	    			eMultIndex += 1
	    		endWhile
	    	endif


	    ;handle further calculations required when there are multiple effects present
	    	if (eMultIndex > 1) ;more than one fortify magic & regen effect was sensed

	    		;if this was from a triple enchant, reduce power (as per the perk)
	    		if (playerRef.hasPerk(EA_ChaoticDissonance))
		    		effectMultipliers[0] = effectMultipliers[0] * 0.75
		    		effectMultipliers[1] = effectMultipliers[1] * 0.75  ;technically these should be 0.70, but this results in more satisfying totals
		    		effectMultipliers[2] = effectMultipliers[2] * 0.75
		    	endif

		    	;rearrange the mults in correct order from highest to lowest
		    	float tempMult
		    	if effectMultipliers[0] >= effectMultipliers[1]
		    		if effectMultipliers[0] >= effectMultipliers[2]
		    			if effectMultipliers[2] >= effectMultipliers[1]
		    				;0-2-1
		    				tempMult = effectMultipliers[1]
		    				effectMultipliers[1] = effectMultipliers[2]
		    				effectMultipliers[2] = tempMult
		    			else
		    				;0-1-2
		    			endif
		    		else
		    			;2-0-1
		    			tempMult = effectMultipliers[2]
		    			effectMultipliers[2] = effectMultipliers[1]
		    			effectMultipliers[1] = effectMultipliers[0]
		    			effectMultipliers[0] = tempMult
		    		endif
		    	else
		    		if effectMultipliers[1] >= effectMultipliers[2]
		    			if effectMultipliers[2] >= effectMultipliers[0]
		    				;1-2-0
		    				tempMult = effectMultipliers[0]
		    				effectMultipliers[0] = effectMultipliers[1]
		    				effectMultipliers[1] = effectMultipliers[2]
		    				effectMultipliers[2] = tempMult
		    			else
		    				;1-0-2
		    				tempMult = effectMultipliers[0]
		    				effectMultipliers[0] = effectMultipliers[1]
		    				effectMultipliers[1] = tempMult
		    			endif
		    		else
		    			;2-1-0
		    			tempMult = effectMultipliers[0]
		    			effectMultipliers[0] = effectMultipliers[2]
		    			effectMultipliers[2] = tempMult
		    		endif
		    	endif

		    	;reduce the power of secondary effects for computing total regeneration
		    		;effect 1 = full power,    effect 2 = 2/3 power,    effect 3 = 1/3 power
		    	effectMultipliers[1] = effectMultipliers[1] * 0.6667
		    	effectMultipliers[2] = effectMultipliers[2] * 0.3333
	    	endif


	    ;FINAL CALCULATIONS using pre-computed multipliers

	    	;since this value will stick for awhile, get BASE AV, to avoid caculating with any temporary buffs
			EnchLvl = PlayerRef.GetBaseActorValue("Enchanting")
			;fortify magicka regen master formula
			CRR = 8.7 * Math.pow((1.0279 - (0.00009 * EnchLvl)), EnchLvl) + 0.5 * EnchLvl

			float totalRegenPower
			while eMultIndex
				eMultIndex -= 1
				totalRegenPower += (effectMultipliers[eMultIndex] * CRR)
			endWhile


		;now that totalRegenPower has been calculated, need to use it to determine the correct spell
			SpellIndex = (totalRegenPower * 0.1) as int 				;divide by 10 and round down to the nearest int
			
			int SpellIndexLength = RegenSpellArray.Length
			if (SpellIndex >= SpellIndexLength)							;regen bonus currently capped at 400%
				SpellIndex = SpellIndexLength - 1
			endif
		
			;add the spell
			if EA_RobeRegenCalcActiveBool.getValue() 					;if player has removed the enchanted item during calculation, withhold the spell
				PlayerRef.AddSpell(RegenSpellArray[SpellIndex], false)
				EA_RobeRegenCalcActiveBool.setValue(0.0)
			endif
			if (ShowMagickaRegenBuffs.GetValue() as bool)  				;globalVariable-based option to display regen rate upon equip
				EARobesMagRegenRateMsg.show((SpellIndex * 10) as float)
			endif


	else ;item was equipped by an NPC (e.g. a follower)
		;this ought to yield a decent regen rate in most situations:
		float adjustedLevel = (akTarget.getLevel() as float) * 2.0
		float adjustedEnchLvl = akTarget.getActorValue("Enchanting") * 2.0
		adjustedLevel += adjustedEnchLvl
		SpellIndex = (adjustedLevel * 0.1) as int
		akTarget.AddSpell(RegenSpellArray[SpellIndex], false)
	endif
EndEvent



Event OnEffectFinish(Actor akTarget, Actor akCaster)
	if akTarget == playerRef
		EA_RobeRegenCalcActiveBool.setValue(0.0)
	endif
	;remove the spell
	akTarget.RemoveSpell(RegenSpellArray[SpellIndex])
EndEvent

