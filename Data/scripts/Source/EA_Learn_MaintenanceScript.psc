Scriptname EA_Learn_MaintenanceScript extends ReferenceAlias

EA_PCDisenchantingControl property MainQuestRef auto

Formlist  property  EA_Tier1_EnchantmentsList         auto
Formlist  property  EA_Tier2_EnchantmentsList         auto
Formlist  property  EA_Tier3_EnchantmentsList         auto
Formlist  property  EA_Tier3_ExclusiveAetherEnchants  auto
Formlist  property  EA_Tier3_ExclusiveChaosEnchants   auto
Formlist  property  EA_Tier3_ExclusiveCorpusEnchants  auto

Formlist  property  EA_v2_Tier1_EnchantmentsAllVariations  auto
Formlist  property  EA_v2_Tier2_EnchantmentsAllVariations  auto
Formlist  property  EA_v2_Tier3_EnchantmentsAllVariations  auto



Event OnInit()
	InitPerkPowerArrays()
	RegisterForSingleUpdate(1.0)
EndEvent

Event OnUpdate()
    utility.waitmenumode(30.0) ;allow buffer for perk respec during install
    GoToState("")
    SetPerkPowerMults()
EndEvent

Event OnPlayerLoadGame()
	GoToState("Inactive")
		utility.waitmenumode(1.0) ;in case perk stage fragments get called each game load? not sure.
	GoToState("")
	SetPerkPowerMults()
EndEvent


Function SetPerkPowerMults()
	EA_Extender.GetIniPerkPowerVals(baseLearnValuesByPerkState, maxLearnValuesByPerkState)
	OnUpdateLearnPerkMultipliers(MainQuestRef.PerkStateCore)
	RegisterForModEvent("EA_UpdateLearnPerkMultipliers", "OnUpdateLearnPerkMultipliers")
EndFunction





float[] property baseLearnValuesByPerkState auto hidden
float[] property maxLearnValuesByPerkState auto hidden

Function InitPerkPowerArrays()
	baseLearnValuesByPerkState = new float[12] ;power of the enchantment without any learning experience
	maxLearnValuesByPerkState = new float[12] ;power the enchantment can reach with full learning experience
	;These values are now read from EnchantingAwakened.ini and then these arrays are filled by EA_Extender.GetIniPerkPowerVals()
EndFunction




Function LinkLearnPerks(EA_Learn_Controller controller)
	LearnPerks = controller.LearnPerks
EndFunction

Perk[] property LearnPerks auto hidden;filled with all 60 learn perks in CK, in order (tier01 level01 -> tier03 level20)
bool LearnMultLOCK = false

Event OnUpdateLearnPerkMultipliers(int soulShaperPerksUnlocked) ; 0 = none, 1 = SoulShaper01, 2 = SS02, 3 = SS03

	;this function sets perk entry multipliers so that they scale fluidly from the base value to the max value
	;across the 20 levels of potential experience gained. Based on the base/max enchantment power values set in
	;InitPerkPowerArrays. This event is called from EA_QF_PerkGainUpdates as each SS perk is unlocked
	;
	;formula:	baseValue + ((maxValue - baseValue) / 20 * listNumber)

	while LearnMultLOCK
		utility.waitmenumode(0.1)
	endWhile
	LearnMultLOCK = true

		;Retrieving this value here just in case, otherwise thread races could make multiple calls to this event
		;get processed out of order (perk stage changes that send this event can fire multiple times successively)
		soulShaperPerksUnlocked = MainQuestRef.PerkStateCore

		if (soulShaperPerksUnlocked > 3) ;error check, should never happen
			soulShaperPerksUnlocked = 3
		endif

		float[] newModifiers = new float[60]

		int perkBaseState = soulShaperPerksUnlocked * 3

		int i = 0
		while i < 60
			float listNumber = ((i % 20) + 1) as float
			int   perkState  = (i / 20) + perkBaseState
			float baseVal    = baseLearnValuesByPerkState[perkState]
			float valRange   = maxLearnValuesByPerkState[perkState] - baseVal

			newModifiers[i] = (baseVal + (valRange / 20.0 * listNumber)) / baseVal

			debug.trace("Enchanting Awakened   ###   newModifiers[" + i + "] = " + newModifiers[i])

			i += 1
		endWhile

		EA_Extender.SetPerkEntryValues(LearnPerks, newModifiers)

	LearnMultLOCK = false
EndEvent

Auto State Inactive
	Event OnUpdateLearnPerkMultipliers(int soulShaperPerksUnlocked)
	EndEvent
EndState