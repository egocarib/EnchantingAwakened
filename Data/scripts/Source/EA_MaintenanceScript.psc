Scriptname EA_MaintenanceScript extends ReferenceAlias

GlobalVariable Property EA_ModSetupComplete auto
GlobalVariable Property EA_InstalledOverOldVersion auto
Message Property EAObsoletePluginsMsg auto

GlobalVariable Property EA_BetterSorting auto
Formlist Property EA_AetherEnchantmentsList auto
Formlist Property EA_ChaosEnchantmentsList auto
Formlist Property EA_CorpusEnchantmentsList auto
Formlist Property EA_Tier1_EnchantmentsList auto
Formlist Property EA_Tier2_EnchantmentsList auto
Formlist Property EA_Tier3_EnchantmentsList auto

bool sortLock


Event OnPlayerLoadGame()
  VanillaSort()
EndEvent


Function VanillaSort()
  if !EA_BetterSorting.getValue()
    if SKSE.getVersion()
      while sortLock
        utility.wait(0.5)
      endWhile
      sortLock = true

      int i = EA_Tier1_EnchantmentsList.getSize()
      while i
        i -= 1
        Form ench = EA_Tier1_EnchantmentsList.getAt(i)
        string name = ench.getName()
        int index = StringUtil.Find(name, ": ")
        if index >= 0
          index += 2
          string newName = StringUtil.SubString(name, index)
          ench.setName(newName)
        endif
      endWhile

      ;extra space needed to preserve capitalization on this one:
      EA_Tier2_EnchantmentsList.getAt(0).setName("Resist Magic ")

      i = EA_Tier2_EnchantmentsList.getSize()
      while i > 1
        i -= 1
        Form ench = EA_Tier2_EnchantmentsList.getAt(i)
        string name = ench.getName()
        int index = StringUtil.Find(name, ": ")
        if index >= 0
          index += 2
          string newName = StringUtil.SubString(name, index)
          ench.setName(newName)
        endif
      endWhile

      i = EA_Tier3_EnchantmentsList.getSize()
      while i
        i -= 1
        Form ench = EA_Tier3_EnchantmentsList.getAt(i)
        string name = ench.getName()
        int index = StringUtil.Find(name, ": ")
        if index >= 0
          index += 2
          string newName = StringUtil.SubString(name, index)
          ench.setName(newName)
        endif
      endWhile

      sortLock = false
    else
      debug.Trace("Enchanting Awakened :::::::: SKSE check failed - most likely you once had SKSE installed but have since removed it. This is a non-critical error that can be safely ignored.")
    endif
  endif
EndFunction


Function BetterSort()
  if EA_BetterSorting.getValue()
    if SKSE.getVersion()
      while sortLock
        utility.wait(0.5)
      endWhile
      sortLock = true

      int i = EA_Tier1_EnchantmentsList.getSize()
      while i
        i -= 1
        Form ench = EA_Tier1_EnchantmentsList.getAt(i)
        string name = ench.getName()
        if StringUtil.Find(name, ": ") < 0 ;safety check to make sure they aren't already named
          string newName
          if EA_AetherEnchantmentsList.hasForm(ench)
            newName = "Aether: " + name
          elseif EA_ChaosEnchantmentsList.hasForm(ench)
            newName = "Chaos: " + name
          elseif EA_CorpusEnchantmentsList.hasForm(ench)
            newName = "Corpus: " + name
          endif
          if newName
            ench.setName(newName)
          endif
        endif
      endWhile

      ;resist magic string will get lowercased unless I do it special
      EA_Tier2_EnchantmentsList.getAt(0).setName("Aether: Resist Magic")

      i = EA_Tier2_EnchantmentsList.getSize()
      while i > 1
        i -= 1
        Form ench = EA_Tier2_EnchantmentsList.getAt(i)
        string name = ench.getName()
        if StringUtil.Find(name, ": ") < 0 ;safety check to make sure they aren't already named
          string newName
          if EA_AetherEnchantmentsList.hasForm(ench)
            newName = "Aether: " + name
          elseif EA_ChaosEnchantmentsList.hasForm(ench)
            newName = "Chaos: " + name
          elseif EA_CorpusEnchantmentsList.hasForm(ench)
            newName = "Corpus: " + name
          endif
          if newName
            ench.setName(newName)
          endif
        endif
      endWhile

      i = EA_Tier3_EnchantmentsList.getSize()
      while i
        i -= 1
        Form ench = EA_Tier3_EnchantmentsList.getAt(i)
        string name = ench.getName()
        if StringUtil.Find(name, ": ") < 0 ;safety check to make sure they aren't already named
          string newName
          if EA_AetherEnchantmentsList.hasForm(ench)
            newName = "Aether: " + name
          elseif EA_ChaosEnchantmentsList.hasForm(ench)
            newName = "Chaos: " + name
          elseif EA_CorpusEnchantmentsList.hasForm(ench)
            newName = "Corpus: " + name
          endif
          if newName
            ench.setName(newName)
          endif
        endif
      endWhile

      sortLock = false
    else
      debug.Trace("Enchanting Awakened :::::::: SKSE check failed - most likely you once had SKSE installed but have since removed it. This is a non-critical error that can be safely ignored.")
    endif
  endif
EndFunction