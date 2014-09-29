Scriptname EA_ConfigMenu extends SKI_ConfigBase

  Actor property playerRef auto
  bool property queueReequipWarning auto hidden

;IMPORT PERKS
  Perk Property EA_SoulShaper02 auto
  Perk Property EA_SoulShaper03 auto
  Perk Property EA_AetherSeeker01 auto
  Perk Property EA_AetherSeeker02 auto
  Perk Property EA_AetherSeeker03 auto
  Perk Property EA_StormfluxForesight01 auto
  Perk Property EA_StormfluxForesight02 auto
  Perk Property EA_AetherStrider auto
  Perk Property EA_ChaosDisciple01 auto
  Perk Property EA_ChaosDisciple02 auto
  Perk Property EA_ChaosDisciple03 auto
  Perk Property EA_FlamesOfUnrest01 auto
  Perk Property EA_FlamesOfUnrest02 auto
  Perk Property EA_ChaosMaster auto
  Perk Property EA_CorpusScholar01 auto
  Perk Property EA_CorpusScholar02 auto
  Perk Property EA_CorpusScholar03 auto
  Perk Property EA_GlacialIntrospection01 auto
  Perk Property EA_GlacialIntrospection02 auto
  Perk Property EA_CorpusGuardian auto
  Perk Property EA_GuardiansVigor auto
  Perk Property EA_EssenceGambit auto
  Perk Property EA_EssenceModulation auto
  Perk Property EA_EssenceNemesis auto

;GLOBAL VAR SETTINGS
  GlobalVariable property EnchantSkillGainSetting auto
  GlobalVariable property EnchantPowerMultSetting auto
  GlobalVariable property ShowMagickaRegenBuffs auto
  GlobalVariable property ShowAbsorbedPowerDailyMsg auto
  GlobalVariable property AddedWeaponDisenchantXP auto
  GlobalVariable property ParalysisPercentChance auto
  GlobalVariable property RemoveEnchantmentDialog auto
  GlobalVariable property EA_EnchTableNPCOverride auto
  GlobalVariable property EA_InstalledOverOldVersion auto
  GlobalVariable property EA_DangerousGemTraps auto ;not filled property in current build
  GlobalVariable property EA_EnchantMode auto ;not filled property in current build

;VARIABLES USED FOR SETTINGS PAGE
  int tog_Settings_SkillGain = 5
  int tog_Settings_STSkillGain = 5 ;???   ;MAKE THESE ALL INTO SLIDERS INSTEAD OF THESE DUMB STRING SETS..
  int tog_Settings_PowerMult = 5

;VARIABLES USED FOR PERKS PAGE
  bool tog_Perks_Respec
  bool tog_Perks_HideBonuses
  bool tog_Perks_ShowLvlBonus

  string curStyle ;current enchanting style specialization, if any
  float enchLvl ;current enchanting level
  float lvlMult ;skill multiplier garnered from Enchanting level
  float lvlMultx ;charge multiplier garnered from Enchanting level
  float baseMult ;base (for non-affiliated enchants added by other mods & soul trap)
  float baseMultx ;base mult for CHARGES produced on weapon enchants
  float soulTrapChargeMult ;increases with essence perks
  float aetherMult ;magnitude
  float aetherMultx ;charges
  float aetherSpec ;shock/magic special
  float corpusMult ;magnitude
  float corpusMultx ;charges
  float corpusSpec ;frost special
  float corpusSpecWeap ;guardian's vigor
  float corpusSpecArmor ;guardian's vigor
  float chaosMult ;magnitude
  float chaosMultx ;charges
  float chaosSpec ;fire special
  float essNemBase ;base chance for essence nemesis to trigger

;VARIABLES USED FOR UNINSTALL PAGE
  bool tog_Uninstalled

;MENU CHOICE ARRAYS
  string[] EnchSkillSetting 
  string[] EnchPowerSetting
  string[] TripleEnchMenuSetting

;LANGUAGE VARIABLE
  string CurLanguage = "Language English" ;ensure updates dont override translation

Event onConfigInit()
  EnchSkillSetting = new string[11]
    EnchSkillSetting[0] = "0.10x"
    EnchSkillSetting[1] = "0.20x"
    EnchSkillSetting[2] = "0.40x"
    EnchSkillSetting[3] = "0.60x"
    EnchSkillSetting[4] = "0.80x"
    EnchSkillSetting[5] = "1.00x"
    EnchSkillSetting[6] = "1.25x"
    EnchSkillSetting[7] = "1.50x"
    EnchSkillSetting[8] = "2.00x"
    EnchSkillSetting[9] = "2.50x"
    EnchSkillSetting[10] = "3.00x"
  EnchPowerSetting = new string[11]
    EnchPowerSetting[0] = "0.50x"
    EnchPowerSetting[1] = "0.60x"
    EnchPowerSetting[2] = "0.70x"
    EnchPowerSetting[3] = "0.80x"
    EnchPowerSetting[4] = "0.90x"
    EnchPowerSetting[5] = "1.00x"
    EnchPowerSetting[6] = "1.25x"
    EnchPowerSetting[7] = "1.50x"
    EnchPowerSetting[8] = "1.75x"
    EnchPowerSetting[9] = "2.00x"
    EnchPowerSetting[10] = "2.50x"
  TripleEnchMenuSetting = new string[3]
    TripleEnchMenuSetting[0] = "Ask Each Session"
    TripleEnchMenuSetting[1] = "Always Triple Enchant"
    TripleEnchMenuSetting[2] = "Always Single Enchant"
  Pages = new string[5]
    Pages[0] = "Settings"
   ; Pages[1] = "Inventory" - wont work: wanted to show all currently held un-disenchantable items,
   ;                           but I made noDisenchantItemArray a local variable only... need to wait for v2
    Pages[1] = "Learning"
    Pages[2] = "Perks" ;respec option
    Pages[3] = "About"
    Pages[4] = "Uninstall"
    ;ADD: Leveled List options - add or remove items from leveled lists (can "remove" just by setting associated level
    ;      ridiculously high with next SKSE update)

    tog_Settings_SkillGain = EnchantSkillGainSetting.getValue() as int
    tog_Settings_PowerMult = EnchantPowerMultSetting.getValue() as int
EndEvent



Event onConfigOpen()
  ;version check
  int temp = game.GetModByName("EnchantingAwakenedRequiem.esp")
  if temp < 255 && temp > 0
    RequiemLoaded = true
  else
    RequiemLoaded = false 
  endif

  ;query variables
  EA_DangerousGemTraps = game.getFormFromFile(0x18571c, "EnchantingAwakened.esp") as GlobalVariable
  EA_EnchantMode = game.getFormFromFile(0x01a7e9, "EnchantingAwakened.esp") as GlobalVariable

  ;determine player's current enchanting style specialization
    if playerRef.hasPerk(EA_StormfluxForesight01)
      curStyle = "Aether"
    elseif playerRef.hasPerk(EA_EssenceGambit)
      if playerRef.hasPerk(EA_EssenceModulation)
        curStyle = "Corpus"
      elseif playerRef.hasPerk(EA_FlamesOfUnrest01)
        curStyle = "Chaos"
      else
        curStyle = "Unchosen"
      endif 
    else
      curStyle = "Unchosen"
    endif 

  ;reset perk-based multipliers
    lvlMult = 1.0 ;skill multiplier garnered from Enchanting level
    lvlMultx = 1.0 ;charge multiplier garnered from Enchanting level
    baseMult = 1.0 ;base (for non-affiliated enchants added by other mods & soul trap)
    baseMultx = 1.0 ;base mult for CHARGES produced on weapon enchants
    soulTrapChargeMult = 1.0 ;increases with essence perks
    aetherMult = 1.0 ;magnitude
    aetherMultx = 1.0 ;charges
    aetherSpec = 1.0 ;shock/magic special
    corpusMult = 1.0 ;magnitude
    corpusMultx = 1.0 ;charges
    corpusSpec = 1.0 ;frost special
    corpusSpecWeap = 0.0 ;guardian's vigor
    corpusSpecArmor = 0.0 ;guardian's vigor
    chaosMult = 1.0 ;magnitude
    chaosMultx = 1.0 ;charges
    chaosSpec = 1.0 ;fire special
    essNemBase = 0.0 ;essence nemesis power

  ;recalculate perk-based multipliers
    if playerRef.hasPerk(EA_SoulShaper03)
      baseMult *= 1.10
    elseif playerRef.hasPerk(EA_SoulShaper02)
      baseMult *= 1.05
    endif 
    if playerRef.hasPerk(EA_AetherSeeker01)
      if playerRef.hasPerk(EA_AetherSeeker03)
        aetherMult *= 1.15
        aetherMultx *= 1.75
      elseif playerRef.hasPerk(EA_AetherSeeker02)
        aetherMult *= 1.10
        aetherMultx *= 1.50
      else
        aetherMult *= 1.05
        aetherMultx *= 1.25
      endif
      if playerRef.hasPerk(EA_StormfluxForesight02)
        aetherSpec = 1.15
      elseif playerRef.hasPerk(EA_StormfluxForesight01)
        aetherSpec = 1.10
      endif
      if playerRef.hasPerk(EA_AetherStrider)
        aetherMult *= 1.30
        aetherMultx *= 1.50
        chaosMult *= 0.80
        corpusMult *= 0.80
      endif
    endif
    if playerRef.hasPerk(EA_ChaosDisciple01)
      if playerRef.hasPerk(EA_ChaosDisciple03)
        chaosMult *= 1.15
        chaosMultx *= 1.75
      elseif playerRef.hasPerk(EA_ChaosDisciple02)
        chaosMult *= 1.10
        chaosMultx *= 1.50
      else
        chaosMult *= 1.05
        chaosMultx *= 1.25
      endif
      if playerRef.hasPerk(EA_FlamesOfUnrest02)
        chaosSpec = 1.15
      elseif playerRef.hasPerk(EA_FlamesOfUnrest01)
        chaosSpec = 1.10
      endIf
      if playerRef.hasPerk(EA_ChaosMaster)
        chaosMult *= 1.30
        chaosMultx *= 1.50
        aetherMult *= 0.80
        corpusMult *= 0.80
      endif 
    endif
    if playerRef.hasPerk(EA_CorpusScholar01)
      if playerRef.hasPerk(EA_CorpusScholar03)
        corpusMult *= 1.15
        corpusMultx *= 1.75
      elseif playerRef.hasPerk(EA_CorpusScholar02)
        corpusMult *= 1.10
        corpusMultx *= 1.50
      else
        corpusMult *= 1.05
        corpusMultx *= 1.25
      endif
      if playerRef.hasPerk(EA_GlacialIntrospection02)
        corpusSpec = 1.15
      elseif playerRef.hasPerk(EA_GlacialIntrospection01)
        corpusSpec = 1.10
      endIf
      if playerRef.hasPerk(EA_CorpusGuardian)
        corpusMult *= 1.30
        corpusMultx *= 1.50
        chaosMult *= 0.80
        aetherMult *= 0.80
        if playerRef.hasPerk(EA_GuardiansVigor)
          corpusSpecWeap = 1.50
          corpusSpecArmor = 2.50
        endif 
      endIf
    endif
    if playerRef.hasPerk(EA_EssenceGambit)
      if playerRef.hasPerk(EA_EssenceModulation)
        soulTrapChargeMult *= 1.50
        baseMultx *= 1.65
      elseif playerRef.hasPerk(EA_EssenceNemesis)
        soulTrapChargeMult *= 1.50
        if enchLvl > 180.0
          essNemBase = 3.875
        else 
          essNemBase = (enchLvl - 25.0) / 40.0
        endif
      else
        soulTrapChargeMult *= 1.20
      endif 
    elseif playerRef.hasPerk(EA_EssenceModulation)
      baseMultx *= 1.65
      if playerRef.hasPerk(EA_EssenceNemesis)
        soulTrapChargeMult *= 1.50
        if enchLvl > 180.0
          essNemBase = 3.875
        else 
          essNemBase = (enchLvl - 25.0) / 40.0
        endif
      else
        soulTrapChargeMult *= 1.20
      endif
    endif
    
    ;vanilla formula for Enchanting Level modifier to enchantment magnitudes. Based on UESP formula
    ; data (http://www.uesp.net/wiki/Skyrim:Enchanting_Effects)
    enchLvl = playerRef.getActorValue("Enchanting")
    lvlMult = 1 + (enchLvl / 100) * (enchLvl / 100 - 0.14) / 3.4

    ;formula for enchanting level modifier to charges created on a weapon:
    ; this formula uses a level 15 baseline, since you already get a 1.38x bonus for level 15 enchanting
    ; already, which seems silly to include. So this determines the multiplier compared to the default
    ; level 15 bonus. Based on UESP formula data (http://www.uesp.net/wiki/Skyrim:Enchanting_Effects)
    lvlMultx = 0.7261387212474 / ((1.0 - enchLvl / 200.0) / (1.0 + math.sqrt(enchLvl / 200.0)))
EndEvent


Event onConfigClose()
  EnchantSkillGainSetting.setValue(tog_Settings_SkillGain)
  EnchantPowerMultSetting.setValue(tog_Settings_PowerMult)
  if tog_Uninstalled == false
    tog_Perks_Respec = false
  endif
EndEvent



Event OnPageReset(string kpage)
   {Called when a new page is selected, including the initial empty page}

  if kpage == ""
    LoadCustomContent("EnchantingAwakened/EA_Logo.dds", 0, 0)
    return
  elseif kpage == "About"
    LoadCustomContent("EnchantingAwakened/EA_About.dds", 0, 0)
  else
    UnloadCustomContent()
  endIf

  if (queueReequipWarning)
    queueReequipWarning = false
    ShowMessage("Important Note:\nEnchanting Awakened detected that you were wearing enchanted items when you installed the mod. To ensure that all mod features to work correctly, you will want to unequip & then re-equip these items now that installation is complete.")
  endif

  if kpage == "Settings" 
    SetCursorPosition(0)
    SetCursorFillMode(TOP_TO_BOTTOM)
    SetTitleText("Settings")
      addHeaderOption("Multipliers")
      addMenuOptionST("opSkillMult", "Enchanting Skill Gain Rate", EnchSkillSetting[tog_Settings_SkillGain])
      ;addMenuOptionST("opSTSkillMult", "Soul Trap Skill Gain Rate", "100%", OPTION_FLAG_DISABLED)
      addMenuOptionST("opPowerMult", "Enchantment Power Mult", EnchPowerSetting[tog_Settings_PowerMult])
      addEmptyOption()
      addHeaderOption("Interface")
      if EA_1stPersonMessages.getValue()
        addTextOptionST("opMsgType", "Notification Style", "1ST PERSON")
      else
        addTextOptionST("opMsgType", "Notification Style", "2ND PERSON")
      endif 
      addToggleOptionST("opBetterSorting", "Better Sorting", EA_BetterSorting.getValue() as bool)
      addToggleOptionST("opWeapExtra", "Extra Weapon Disenchant XP", AddedWeaponDisenchantXP.getValue() as bool)
      addToggleOptionST("opShowRegen", "Display Fortify Magic & Regen %", ShowMagickaRegenBuffs.getValue() as bool)
      addToggleOptionST("opShowPower", "Display Daily Power Message & FX", ShowAbsorbedPowerDailyMsg.getValue() as bool)
      int index = RemoveEnchantmentDialog.getValue() as int
      if index == 0
        addMenuOptionST("opShowTriple", "Triple Enchant Menu", "Ask")
      elseif index == 1
        addMenuOptionST("opShowTriple", "Triple Enchant Menu", "Triple Enchant")
      elseif index == 2
        addMenuOptionST("opShowTriple", "Triple Enchant Menu", "Single Enchant")
      endif
    SetCursorPosition(1)
      addHeaderOption("Gameplay")
      if CurLanguage == "Language English"
        addToggleOptionST("opDangerousTraps", "Dangerous Soul Gem Traps", (EA_DangerousGemTraps.getValue() as bool))
      endif
      addToggleOptionST("opNPCOverride", "Boot NPCs from Enchanting Table", (EA_EnchTableNPCOverride.getValue() as bool))
      addSliderOptionST("opParalysis", "Chance to Paralyze", 18.0, "{0}%")
      addSliderOptionST("opEssNemMult", "Essence Nemesis Absorb Power %", STQ.essNemCustomMult * 100.0, "{0}%")
      addEmptyOption()
      addHeaderOption("Compatibility")
      addToggleOptionST("opIgnoreCustom", "Allow Custom Equipment Effects", (ETracker.getState() as bool))
      if EA_InstalledOverOldVersion.getValue() == 0
        addEmptyOption()
        addHeaderOption("Optional Plugins")
        addToggleOptionST("opLessGems", "Less Filled Soulgems for Merchants", bOpLessGems, bOpLessGems as int)
      endif



  elseif kpage == "Learning"
    SetCursorPosition(0)
    SetCursorFillMode(TOP_TO_BOTTOM)
    SetTitleText("Learning")



  elseif kpage == "Perks"

    ;GREAT IDEA! AddCustomContent to show a pic here depending on what enchantment style the player has specialized in!
    ;show it for a few seconds and then show the perk menu

    SetCursorPosition(0)
    SetCursorFillMode(TOP_TO_BOTTOM)
    SetTitleText("Perks")
    AddHeaderOption("Perk Data")
    AddTextOption("Style of Specialization: ", curStyle)
    ;AddToggleOptionST("tog_Perks3", "Show More Bonuses", false) ;base enchantment bonus, soul trap, etc.
    AddToggleOptionST("tog_Perks4", "Include Enchanting Level Modifier", tog_Perks_ShowLvlBonus)
    AddToggleOptionST("tog_Perks2", "Hide Bonuses", tog_Perks_HideBonuses)
    AddEmptyOption()
    AddHeaderOption("Options")
    AddToggleOptionST("tog_Perks1", "Respec Perks", tog_Perks_Respec)

    ; lvlMult = 1.0 ;skill multiplier garnered from Enchanting level
    ; lvlMultx = 1.0 ;charge multiplier garnered from Enchanting level
    ; baseMult = 1.0 ;base (for non-affiliated enchants added by other mods & soul trap)
    ; baseMultx = 1.0 ;base mult for CHARGES produced on weapon enchants
    ; soulTrapChargeMult = 1.0 ;increases with essence perks
    ; aetherMult = 1.0 ;magnitude
    ; aetherMultx = 1.0 ;charges
    ; aetherSpec = 0.0 ;shock/magic special
    ; corpusMult = 1.0 ;magnitude
    ; corpusMultx = 1.0 ;charges
    ; corpusSpec = 0.0 ;frost special
    ; corpusSpecWeap = 0.0 ;guardian's vigor
    ; corpusSpecArmor = 0.0 ;guardian's vigor
    ; chaosMult = 1.0 ;magnitude
    ; chaosMultx = 1.0 ;charges
    ; chaosSpec = 0.0 ;fire special

    SetCursorPosition(1)
    if tog_Perks_HideBonuses == false
      if !tog_Perks_ShowLvlBonus
        AddHeaderOption("Perk Bonus to Enchantments")
      else
        AddHeaderOption("Total Bonus to Enchantments")
      endif
      float tempLvlMult = 1.0
      float tempLvlMultx = 1.0
      if tog_Perks_ShowLvlBonus
        tempLvlMult = lvlMult
        tempLvlMultx = lvlMultx
      endif
      if curStyle == "Aether" || curStyle == "Unchosen"
        outputAetherPerkData(tempLvlMult, tempLvlMultx)
        outputChaosPerkData(tempLvlMult, tempLvlMultx)
        outputCorpusPerkData(tempLvlMult, tempLvlMultx)
      elseif curStyle == "Chaos"
        outputChaosPerkData(tempLvlMult, tempLvlMultx)
        outputCorpusPerkData(tempLvlMult, tempLvlMultx)
        outputAetherPerkData(tempLvlMult, tempLvlMultx)
      elseif curStyle == "Corpus" && !corpusSpecWeap
        outputCorpusPerkData(tempLvlMult, tempLvlMultx)
        outputAetherPerkData(tempLvlMult, tempLvlMultx)
        outputChaosPerkData(tempLvlMult, tempLvlMultx)
      elseif curStyle == "Corpus" && corpusSpecWeap
        outputCorpusPerkDataSpecial(tempLvlMult, tempLvlMultx)
      endif
    else ;tog_Perks_HideBonuses == true
      AddHeaderOption("Perk Bonuses Are Hidden")
    endif

    ;respec option (with warning that enchants cannot be unlearned)

  elseif kpage == "Uninstall"
    ;use is3DLoaded() & isNearPlayer() in combination to test for nearby enchanting tables/gem traps - that should do the trick.
    SetCursorFillMode(TOP_TO_BOTTOM)
    AddHeaderOption("Uninstall")
    AddToggleOptionST("opUninstall", "Uninstall Enchanting Awakened", tog_Uninstalled)

  endif

EndEvent



Function outputAetherPerkData(float tempLvlMult, float tempLvlMultx)
  AddTextOption("Aether ", " ")
  int aetherPow = ((aetherMult * baseMult * tempLvlMult - 1.0) * 100.0) as int
  if aetherPow > 0
    AddTextOption("   Enchantment Power ", "+ " + aetherPow + "%")
  else
    AddTextOption("   Enchantment Power ", aetherPow + "%")
  endif
  if (aetherMultx * baseMultx * tempLvlMultx) > 1.0
    AddTextOption("   Weapon Charges ", "+ " + (((aetherMultx * baseMultx * tempLvlMultx - 1.0) * 100.0) as int) + "%")
  endif
  if aetherSpec > 1.0
    AddTextOption("   Shock & Magic Resist ", "+ " + (((aetherMult * baseMult * tempLvlMult * aetherSpec - 1.0) * 100.0) as int) + "%")
  endif
EndFunction

Function outputChaosPerkData(float tempLvlMult, float tempLvlMultx)
  AddTextOption("Chaos ", " ")
  int chaosPow = ((chaosMult * baseMult * tempLvlMult - 1.0) * 100.0) as int
  if chaosPow > 0
    AddTextOption("   Enchantment Power ", "+ " + chaosPow + "%")
  else
    AddTextOption("   Enchantment Power ", chaosPow + "%")
  endif 
  if (chaosMultx * baseMultx * tempLvlMultx) > 1.0
    AddTextOption("   Weapon Charges ", "+ " + (((chaosMultx * baseMultx * tempLvlMultx - 1.0) * 100.0) as int) + "%")
  endif
  if chaosSpec > 1.0
    AddTextOption("   Fire Enchantments ", "+ " + (((chaosMult * baseMult * tempLvlMult * chaosSpec - 1.0) * 100.0) as int) + "%")
  endif
EndFunction

Function outputCorpusPerkData(float tempLvlMult, float tempLvlMultx)
  AddTextOption("Corpus ", " ")
  int corpusPow = ((corpusMult * baseMult * tempLvlMult - 1.0) * 100.0) as int
  if corpusPow > 0
    AddTextOption("   Enchantment Power ", "+ " + corpusPow + "%")
  else
    AddTextOption("   Enchantment Power ", corpusPow + "%")
  endif 
  if (corpusMultx * baseMultx * tempLvlMultx) > 1.0
    AddTextOption("   Weapon Charges ", "+ " + (((corpusMultx * baseMultx * tempLvlMultx - 1.0) * 100.0) as int) + "%")
  endif
  if corpusSpec > 1.0
    AddTextOption("   Frost Enchantments ", "+ " + (((corpusMult * baseMult * tempLvlMult * corpusSpec - 1.0) * 100.0) as int) + "%")
  endif
EndFunction

Function outputCorpusPerkDataSpecial(float tempLvlMult, float tempLvlMultx)
  AddTextOption("Corpus ", " ")
  AddTextOption("   Weapon Enchantment Power ", "+ " + (((corpusSpecWeap * corpusMult * baseMult * tempLvlMult - 1.0) * 100.0) as int) + "%")
  AddTextOption("   Weapon Frost Power ", "+ " + (((corpusSpecWeap * corpusMult * baseMult * tempLvlMult * corpusSpec - 1.0) * 100.0) as int) + "%")
  AddTextOption("   Weapon Charges ", "+ " + (((corpusMultx * baseMultx * tempLvlMultx - 1.0) * 100.0) as int) + "%")
  AddTextOption("   Vigor Armor Enchantments ", "+ " + (((corpusSpecArmor * corpusMult * baseMult * tempLvlMult - 1.0) * 100.0) as int) + "%")
  AddTextOption("   Frost Armor Enchantments ", "+ " + (((corpusSpecArmor * corpusMult * baseMult * tempLvlMult * corpusSpec - 1.0) * 100.0) as int) + "%")
  AddTextOption("   Other Armor Enchantments ", "+ " + (((corpusMult * baseMult * tempLvlMult - 1.0) * 100.0) as int) + "%")

  AddTextOption("Aether ", " ")
  AddTextOption("   Weapon Enchantment Power ", "+ " + (((corpusSpecWeap * aetherMult * baseMult * tempLvlMult - 1.0) * 100.0) as int) + "%")
  AddTextOption("   Weapon Charges ", "+ " + (((aetherMultx * baseMultx * tempLvlMultx - 1.0) * 100.0) as int) + "%")
  AddTextOption("   Vigor Armor Enchantments ", "+ " + (((corpusSpecArmor * aetherMult * baseMult * tempLvlMult - 1.0) * 100.0) as int) + "%")
  int aetherPow = ((aetherMult * baseMult * tempLvlMult - 1.0) * 100.0) as int
  if aetherPow > 0
    AddTextOption("   Other Armor Enchantments ", "+ " + aetherPow + "%")
  else
    AddTextOption("   Other Armor Enchantments ", aetherPow + "%")
  endif

  AddTextOption("Chaos ", " ")
  AddTextOption("   Weapon Enchantment Power ", "+ " + (((corpusSpecWeap * chaosMult * baseMult * tempLvlMult - 1.0) * 100.0) as int) + "%")
  AddTextOption("   Weapon Charges ", "+ " + (((chaosMultx * baseMultx * tempLvlMultx - 1.0) * 100.0) as int) + "%")
  AddTextOption("   Vigor Armor Enchantments ", "+ " + (((corpusSpecArmor * chaosMult * baseMult * tempLvlMult - 1.0) * 100.0) as int) + "%")
  int chaosPow = ((chaosMult * baseMult * tempLvlMult - 1.0) * 100.0) as int
  if chaosPow > 0
    AddTextOption("   Other Armor Enchantments ", "+ " + chaosPow + "%")
  else
    AddTextOption("   Other Armor Enchantments ", chaosPow + "%")
  endif
  
  ;for future:
  ;enable clicking on an enchant type listed above & show a menu box telling all the valid enchantments affected by this bonus (requires tracking the numbers)
  ;weapon
  ;corpus weap/magic
  ;fortify
EndFunction




;ADJUST SKILL GAIN RATE
State opSkillMult
  event onMenuOpenST()
    SetMenuDialogStartIndex(tog_Settings_SkillGain) ;EnchantSkillGainSetting
    SetMenuDialogDefaultIndex(5)
    SetMenuDialogOptions(EnchSkillSetting)
  endEvent

  event onMenuAcceptST(int index)
    tog_Settings_SkillGain = index
    SetMenuOptionValueST(EnchSkillSetting[index])
  endEvent

  event onDefaultST()
    tog_Settings_SkillGain = 5
    SetMenuOptionValueST(EnchSkillSetting[tog_Settings_SkillGain])
  endEvent

  event onHighlightST()
    SetInfoText("Change the global rate at which you will gain Enchanting experience.")
  endEvent
EndState

;ADJUST SOUL TRAP SKILL GAIN RATE
; State opSTSkillMult
;   event onHighlightST()
;     SetInfoText("Option wont be available until version two. (Along with ton of other options!)")
;   endEvent
; EndState

;ADJUST ENCHANTMENT MAGNITUDE GLOBALLY
State opPowerMult
  event onMenuOpenST()
    SetMenuDialogStartIndex(tog_Settings_PowerMult) ;EnchantPowerMultSetting
    SetMenuDialogDefaultIndex(5)
    SetMenuDialogOptions(EnchPowerSetting)
  endEvent

  event onMenuAcceptST(int index)
    tog_Settings_PowerMult = index
    SetMenuOptionValueST(EnchPowerSetting[index])
  endEvent

  event onDefaultST()
    tog_Settings_PowerMult = 5
    SetMenuOptionValueST(EnchPowerSetting[tog_Settings_PowerMult])
  endEvent

  event onHighlightST()
    SetInfoText("Change the overall strength of all Enchantments that you apply to items.")
  endEvent
EndState

;TRIPLE ENCHANT MENU OPTION POPUP
State opShowTriple
  event onMenuOpenST()
    SetMenuDialogStartIndex(RemoveEnchantmentDialog.getValue() as int)
    SetMenuDialogDefaultIndex(0)
    SetMenuDialogOptions(TripleEnchMenuSetting)
  endEvent

  event onMenuAcceptST(int index)
    RemoveEnchantmentDialog.setValue(index)
    if index == 0
      SetMenuOptionValueST("Ask")
      EA_EnchantMode.setValue(1)
    elseif index == 1
      SetMenuOptionValueST("Triple Enchant")
      EA_EnchantMode.setValue(1)
    elseif index == 2
      SetMenuOptionValueST("Single Enchant")
      EA_EnchantMode.setValue(0)
    endif
  endEvent

  event onDefaultST()
    RemoveEnchantmentDialog.setValue(0)
    SetMenuOptionValueST("Ask")
      EA_EnchantMode.setValue(1)
  endEvent

  event onHighlightST()
    SetInfoText("This setting allows Chaos masters with the Chaotic Dissonance perk to turn off the pop-up menu that appears whenever they activate the Arcane Enchanter. You can choose to make Triple or Single Enchanting your default preference, instead of having to choose each time through the Pop-up.")
  endEvent
EndState

;EXTRA WEAPON DISENCHANT EXPERIENCE
State opWeapExtra
  event onSelectST()
    if AddedWeaponDisenchantXP.getValue()
      AddedWeaponDisenchantXP.setValue(0)
      SetToggleOptionValueST(false)
    else
      AddedWeaponDisenchantXP.setValue(1)
      SetToggleOptionValueST(true)
    endif
  endEvent

  event onDefaultST()
    AddedWeaponDisenchantXP.setValue(1)
    SetToggleOptionValueST(true)
  endEvent

  event onHighlightST()
    SetInfoText("Toggles whether or not weapon disenchanting awards extra experience to bring it more in line with armor disenchanting. The drawback is that the Enchanting experience bar will not visually update to reflect this until you enchant or disenchant another item, so it may be a cosmetic annoyance to some people.")
  endEvent
EndState

;SHOW DAILY MESSAGE & FX FOR ABSORBED POWERS
State opShowPower
  event onSelectST()
    if ShowAbsorbedPowerDailyMsg.getValue()
      ShowAbsorbedPowerDailyMsg.setValue(0)
      SetToggleOptionValueST(false)
    else
      ShowAbsorbedPowerDailyMsg.setValue(1)
      SetToggleOptionValueST(true)
    endif
  endEvent

  event onDefaultST()
    ShowAbsorbedPowerDailyMsg.setValue(1)
    SetToggleOptionValueST(true)
  endEvent

  event onHighlightST()
    SetInfoText("This toggles whether a message and some fun visual effects on your character will appear each in-game day to countdown the remaining time left for your Essence Modulation absorbed power. (The message and FX won't appear during combat, so they hopefully wont be distracting at any inopportune moments.)")
  endEvent
EndState

;SHOW MAGICKA REGEN BONUS ON ROBES
State opShowRegen
  event onSelectST()
    if ShowMagickaRegenBuffs.getValue()
      ShowMagickaRegenBuffs.setValue(0)
      SetToggleOptionValueST(false)
    else
      ShowMagickaRegenBuffs.setValue(1)
      SetToggleOptionValueST(true)
    endIf
  endEvent

  event onDefaultST()
    ShowMagickaRegenBuffs.setValue(0)
    SetToggleOptionValueST(false)
  endEvent

  event onHighlightST()
    SetInfoText("This toggles whether a message will appear notifying you of the percentage buff to Magicka Regen that your Fortify <Magic Type> & Regen enchantment has granted you, shown when you equip the item. Handy for those who like to know that kind of stuff.")
  endEvent
EndState

;PARALYSIS PERCENT CHANCE
bool RequiemLoaded
State opParalysis
  event onSliderOpenST()
    SetSliderDialogStartValue(ParalysisPercentChance.getValue())
    SetSliderDialogDefaultValue(18)
    SetSliderDialogRange(0, 100)
    SetSliderDialogInterval(1)
  endevent

  event onSliderAcceptST(float value)
    ParalysisPercentChance.setValue(value)
    SetSliderOptionValueST(value, "{0}%")
  endevent

  event onDefaultST()
    ParalysisPercentChance.setValue(18)
    SetSliderOptionValueST(18, "{0}%")
  endevent

  event onHighlightST()
    if RequiemLoaded
      SetInfoText("Requiem lowers the chance to paralyze with player-crafted paralysis enchantments to only 2% (versus vanilla's 26%). However, this slider will allow you to change the percent of times that paralysis will trigger, if you prefer a different setting.")
    else
      SetInfoText("Enchanting Awakened lowers the chance to paralyze with a paralysis enchantment to only 18% (versus vanilla's 26%). However, this slider will allow you to change the percent of times that paralysis will trigger, if you prefer a different setting.")
    endif
  endEvent
EndState

;MODIFY ABSORB POWER % FOR ESSENCE NEMESIS
State opEssNemMult
  event onSliderOpenST()
    SetSliderDialogStartValue(STQ.essNemCustomMult * 100.0)
    SetSliderDialogDefaultValue(100.0)
    SetSliderDialogRange(0.0, 300.0)
    SetSliderDialogInterval(10.0)
  endevent

  event onSliderAcceptST(float value)
    STQ.essNemCustomMult = value * 0.01
    SetSliderOptionValueST(value, "{0}%")
  endevent

  event onDefaultST()
    STQ.essNemCustomMult = 1.0
    SetSliderOptionValueST(100.0, "{0}%")
  endevent

  event onHighlightST()
    if (essNemBase as bool)
      SetInfoText("Adjust the chance that you will absorb a power when soul trapping with the Essence Nemesis perk.\nYour current base chance to absorb: " + essNemBase + "%\nYour current modified chance to absorb: " + (essNemBase * STQ.essNemCustomMult) + "%\n(This percentage applies to humans - the chance to absorb a power from creatures with smaller souls will be less)")
    else
      SetInfoText("Adjust the chance that you will absorb a power when soul trapping with the Essence Nemesis perk.\n(You have not yet unlocked the Essence Nemesis perk.)")
    endif
  endEvent
EndState

;INJECT LESS GEMS OPTION INTO LEVELED LISTS
bool property bOpLessGems auto hidden
EA_LeveledListSoulGemsScript property LGemScript auto
State opLessGems
  event onSelectST()
      ;show confirm message first
      if ShowMessage("Once chosen, the Less Filled Gems setting cannot be removed without a full reinstall the mod. Are you sure?", true, "Continue", "Cancel")
        bOpLessGems = true
        SetToggleOptionValueST(true, true)
        SetOptionFlagsST(OPTION_FLAG_DISABLED)
        LGemScript.ModifyGemLists()
      endif
      ;set flag to not choosable
  endEvent

  event onHighlightST()
    SetInfoText("This will reduce the number of FILLED soul gems sold by all merchants. The same total number of gems will still be sold, they will just be 80% less likely to be filled. Does NOT affect Soul Gems found while adventuring.")
  endEvent
EndState

;BOOT NPCs FROM ENCHANTING TABLE
State opNPCOverride
  event onSelectST()
    int iChoice = EA_EnchTableNPCOverride.getValue() as int
    iChoice = (iChoice + 1) % 2
    EA_EnchTableNPCOverride.setValue(iChoice)
    SetToggleOptionValueST(iChoice)
  endEvent

  event onDefaultST()
    EA_EnchTableNPCOverride.setValue(0)
    SetToggleOptionValueST(false)
  endevent

  event onHighlightST()
    SetInfoText("Checking this option will force NPCs who are currently using an enchanting table to stop using the table when the player tries to use it (as in vanilla Skyrim).")
  endevent
EndState

;DANGEROUS SOUL GEM TRAPS
State opDangerousTraps
  event onSelectST()
    int iChoice = EA_DangerousGemTraps.getValue() as int
    iChoice = (iChoice + 1) % 2
    EA_DangerousGemTraps.setValue(iChoice)
    SetToggleOptionValueST(iChoice)
  endEvent

  event onDefaultST()
    EA_DangerousGemTraps.setValue(1)
    SetToggleOptionValueST(true)
  endevent

  event onHighlightST()
    SetInfoText("While this option is selected, you will be unable to simply run up to soul gem traps and grab the gem off the pedestal while it is still active. Instead, you'll have to disable the gem first (with arrows, magic, shouts, or other methods). Changes to this option won't affect traps that are already near you.")
  endevent
EndState

;BETTER SORTING
GlobalVariable property EA_BetterSorting auto
EA_MaintenanceScript property SortScript auto
State opBetterSorting
  event onSelectST()
    int oldSort = EA_BetterSorting.getValue() as int
    int newSort = (oldSort + 1) % 2
    EA_BetterSorting.setValue(newSort)
    SetToggleOptionValueST(newSort)
    updateSortMethod()
    ShowMessage("Your Sorting preference has been set.\n\nPlease allow a few moments for all enchantment names to update.", false, "Confirm")
  endevent

  event onDefaultST()
    if !EA_BetterSorting.getValue()
      EA_BetterSorting.setValue(1)
      updateSortMethod()
    endif
  endevent

  event onHighlightST()
    SetInfoText("Better Sorting method at the Enchanting Table. Will sort Enchantments by which of the three Enchanting styles they are associated with. This makes it much easier to keep track of which enchantments will be most powerful for you as you begin to specialize in a particular style of Enchanting.")
  endevent
EndState

;TOGGLE MESSAGE TYPE (1st OR 2nd PERSON)
GlobalVariable property EA_1stPersonMessages auto 
EA_HostileTrapAliasScript property HTA auto
State opMsgType
  event onSelectST()
    int cur = EA_1stPersonMessages.getValue() as int
    cur = (cur + 1) % 2
    EA_1stPersonMessages.setValue(cur as float)
    if cur
      STQ.setSoulTrapMessageType(true) ;1stP
      HTA.setHostileTrapMessageType(true) ;1stP
      SetTextOptionValueST("1st Person")
    else
      STQ.setSoulTrapMessageType(false) ;2ndP
      HTA.setHostileTrapMessageType(false) ;2ndP
      SetTextOptionValueST("2nd Person")
    endif 
  endevent 

  event onDefaultST()
    EA_1stPersonMessages.setValue(0)
    STQ.setSoulTrapMessageType(false) ;2ndP
    HTA.setHostileTrapMessageType(false) ;2ndP
    SetTextOptionValueST("2nd Person")
  endevent 

  event onHighlightST() 
    SetInfoText("Toggle your preferred message style. 1st Person will use \"I\", \"Me\", and \"My\" to display all in-game Enchanting Awakened messages. 2nd Person is the default, and uses \"You\" and \"Your\" for all in-game notifications.")
  endevent 
EndState

;COMPATIBILITY WITH CUSTOM ENCHANTED ITEMS
EA_SpecialEquipTracker property ETracker auto
State opIgnoreCustom
  event onSelectST()
    bool isActive = ETracker.getState() as bool
    if isActive
      ETracker.goToState("")
    else
      ETracker.goToState("Active")
    endif
    SetToggleOptionValueST(!isActive)
  endevent 

  event onHighlightST()
    SetInfoText("This option will force Enchanting Awakened to allow the effects from modded equipment that uses custom slots (like backpacks, cloaks, pouches, etcetera). You should only need to select this option if your item effects are being dispelled (\"fading\" and \"dissipating\"), but you don't want them to be.")
  endevent
EndState



;PERKS MENU STATES >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

EA_PCDisenchantingControl property PCD auto
EA_SoulTrapQuestScript property STQ auto
EA_PerkRespecOnInstallScript property PRS auto

;RESPEC PERKS
State tog_Perks1
  event onSelectST()
    if !tog_Perks_Respec
      tog_Perks_Respec = true
      SetToggleOptionValueST(true)
      if playerRef.hasperk(EA_AetherStrider) || playerRef.hasPerk(EA_ChaosMaster) || playerRef.hasPerk(EA_CorpusGuardian)
        if !ShowMessage("Are you sure you want to respec all your enchanting perks?\n\nKeep in mind that you cannot unlearn any enchantments you've unlocked that are meant to be exclusive to your current style.", true, "Respec", "Cancel")
          tog_Perks_Respec = false
          SetToggleOptionValueST(false)
          return
        endif
      else
        if !ShowMessage("Are you sure you want to respec all your enchanting perks?", true, "Respec", "Cancel")
          tog_Perks_Respec = false
          SetToggleOptionValueST(false)
          return
        endif
      endif
     ;EA_SoulTrapQuestScript:
      float tempEVal = playerRef.getActorValue("Enchanting")
      playerRef.modActorValue("Enchanting", -tempEVal)
      STQ.calcEssencePerkEffects()
      playerRef.modActorValue("Enchanting", tempEVal)
      STQ.goToState("")
     ;EA_PerkRespecOnInstallScript:
      int preRespec = game.getPerkPoints()
      PRS.uninstallPerkRespec()
      if preRespec < game.getPerkPoints()

       ;EA_PCDisenchantingControl:
        PCD.PerkStateCore = 0
        PCD.PerkStateSpecial[1] = false
        PCD.PerkStateSpecial[2] = false
        PCD.PerkStateSpecial[3] = false
        PCD.UpdateRestrictions()

       ;Menu Perk Info Recalc:
        onConfigOpen()
        
        ShowMessage("Enchanting Perks Successfully Reset!", false, "OK")
        refreshPage()
      else
        ShowMessage("You don't appear to have any Enchanting Perks to respec...", false, "OK")
        tog_Perks_Respec = false
        SetToggleOptionValueST(false)
      endif
    endif
  endEvent

  event onDefaultST()
  endEvent

  event onHighlightST()
      SetInfoText("Choosing this option will remove all your character's current enchanting perks and return the Perk Points to you.")
  endEvent
EndState

;HIDE BONUSES
State tog_Perks2
  event onSelectST()
    tog_Perks_HideBonuses = !tog_Perks_HideBonuses
    SetToggleOptionValueST(tog_Perks_HideBonuses)
    if tog_Perks_HideBonuses == true
      tog_Perks_ShowLvlBonus = false
    endif
    refreshPage()
  endEvent

  event onDefaultST()
    tog_Perks_HideBonuses = false
    setToggleOptionValueST(false)
  endEvent

  event onHighlightST()
    if !tog_Perks_HideBonuses
      SetInfoText("Hide perk bonuses from view.")
    else
      SetInfoText("Display perk bonuses for Enchanting.")
    endif
  endEvent
EndState

;SHOW ENCH LVL BONUS
State tog_Perks4
  event onSelectST()
    if !tog_Perks_HideBonuses
      tog_Perks_ShowLvlBonus = !tog_Perks_ShowLvlBonus
      SetToggleOptionValueST(tog_Perks_ShowLvlBonus)
      refreshPage()
    endif
  endEvent

  event onDefaultST()
    tog_Perks_ShowLvlBonus = false
    SetToggleOptionValueST(false)
  endEvent

  event onHighlightST()
    if !tog_Perks_ShowLvlBonus
      SetInfoText("Factor Enchanting Level multipliers into the displayed Perk Bonus values.\n(This will give a more accurate representation of your total bonus to applied enchantments)")
    else
      SetInfoText("Remove Enchanting Level multipliers, and display only the bonuses to Enchanting that you have gained from your perks.")
    endif
  endEvent
EndState

;UNINSTALL OPTION
Quest property EAUninstall auto
State opUninstall
  event onSelectST()
    if !tog_Uninstalled
      if ShowMessage("Are you sure you want to uninstall Enchanting Awakened?", true, "Uninstall", "Cancel")
        ShowMessage("Sorry to see you go! Please exit the MCM Menu to begin the Uninstallation process.", false, "OK")
        tog_Uninstalled = true
        SetToggleOptionValueST(true)
        queueUninstall()
      endif
    endif 
  endEvent

  event onHighlightST()
    if !tog_Uninstalled
      SetInfoText("Choose this option to begin the Uninstall process for Enchanting Awakened.")
    else
      SetInfoText("Enchanting Awakened will be Uninstalled as soon as you exit the MCM Menu.")
    endif
  endEvent
EndState






;UTILITY FUNCTIONS

;Update Sorting Method
  bool bWillSort
  Function updateSortMethod()
    registerForModEvent("EAv1_updateSort", "onUpdateSort")
    sendModEvent("EAv1_updateSort")
  EndFunction
  Event onUpdateSort(string eventName, string strArg, float iterations, Form sender)
    if bWillSort
      return
    endIf
    bWillSort = true
    utility.wait(0.01) ;wait for menu to close
    bWillSort = false
    SortScript.BetterSort()
    SortScript.VanillaSort()
    UnregisterForModEvent("EAv1_updateSort")
  EndEvent

;Uninstall Event (delays until player exits menu entirely, to avoid stopping other MCM menus from working)
  Function queueUninstall()
    registerForModEvent("EAv1_beginUninstall", "onQueueUninstall")
    sendModEvent("EAv1_beginUninstall")
  EndFunction
  Event onQueueUninstall(string eventName, string strArg, float iterations, Form sender)
    utility.wait(0.01) ;wait for menu to close
    tog_Perks_Respec = false
    tog_Uninstalled = false
    EAUninstall.start()
    UnregisterForModEvent("EAv1_beginUninstall")
  EndEvent

;Page Refresh that maintains highlight on currently selected option:
  Function refreshPage()
    int index = UI.GetInt("Journal Menu", "_root.ConfigPanelFader.configPanel.contentHolder.optionsPanel.optionsList.selectedIndex")
    registerForModEvent("EAv1_pageRefresh", "onPageRefreshed")
    sendModEvent("EAv1_pageRefresh", index as string, 0)
    forcePageReset()
  EndFunction
  bool refreshLock
  Event onPageRefreshed(string eventName, string strArg, float iterations, Form sender)
    ; if refreshLock
    ;   return      ;fringe check to prevent multithreading
    ; endIf
    ; refreshLock = true

    int returnPlace = strArg as int
    int readyState = UI.GetInt("Journal Menu", "_global.ConfigPanel.READY")
    int curState = UI.GetInt("Journal Menu", "_root.ConfigPanelFader.configPanel._state")

    if (curState == readyState || iterations > 10.0)
      UI.SetInt("Journal Menu", "_root.ConfigPanelFader.configPanel.contentHolder.optionsPanel.optionsList.selectedIndex", returnPlace)
      UnregisterForModEvent("EAv1_pageRefresh")
;      refreshLock = false
    else
      utility.wait(0.02)
;      refreshLock = false
      SendModEvent("EAv1_pageRefresh", strArg, iterations + 1.0)
    endIf
;    refreshLock = false
  EndEvent