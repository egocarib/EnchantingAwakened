Scriptname EA_UninstallScript extends Quest

Actor property playerRef auto

Message property EAUninstallConfirm auto
Message property EAUninstallBegin auto
Message property EAUninstallCancel auto
Message property EAUninstallFinish01 auto
Message property EAUninstallFinish02 auto

GlobalVariable property EA_ModSetupComplete auto


Event onInit()
	registerForSingleUpdate(0.1)
EndEvent

Event onUpdate()
	if !isRunning() ;prevent from triggering during initial install (OnInit gets sent even though not running)
		return
	endif

	if !EAUninstallConfirm.show()
		EAUninstallBegin.show()
			resetEnchantingPerkTree()
			stopModQuests()
			removeModItems()
			removeModSpells()
			removeModPerks()
			EAUninstallFinish01.show()
			EAUninstallFinish02.show()

	else ;Player hit the Cancel button
		EAUninstallCancel.show()
	endif

	self.stop()
EndEvent


;QUESTS/ALIASES ------------------------------------->

  Quest property EA_PCMainQuest auto
  Quest property EA_SoulTrapQuest auto
  Quest property EA_PerkQuest auto

	Function stopModQuests()
		EA_PCMainQuest.stop()
		EA_SoulTrapQuest.stop()
		EA_PerkQuest.stop()
	EndFunction


;NON-TREE PERKS ------------------------------------->

  Formlist property EA_Uninstall_ModPerksList auto

	Function removeModPerks()

		int iPerks = EA_Uninstall_ModPerksList.getSize()
		while iPerks
			iPerks -= 1
			if playerRef.hasPerk(EA_Uninstall_ModPerksList.getAt(iPerks) as Perk)
				playerRef.removePerk(EA_Uninstall_ModPerksList.getAt(iPerks) as Perk)
			endif
		endwhile

	EndFunction


;SPELLS --------------------------------------------->

  Formlist property EA_Uninstall_ModSpellsSpellList auto ;all fire-and-forget type spells
  Formlist property EA_Uninstall_ModSpellsAbilityList auto ;all ability type spells

	Function removeModSpells()

		int iAbilities = EA_Uninstall_ModSpellsAbilityList.getSize()
		while iAbilities
			iAbilities -= 1
			if playerRef.hasSpell(EA_Uninstall_ModSpellsAbilityList.getAt(iAbilities))
				playerRef.removeSpell(EA_Uninstall_ModSpellsAbilityList.getAt(iAbilities) as Spell)
			endif
		endWhile

		int iSpells = EA_Uninstall_ModSpellsSpellList.getSize()
		while iSpells
			iSpells -= 1
			playerRef.dispelSpell(EA_Uninstall_ModSpellsSpellList.getAt(iSpells) as Spell) 
		endWhile

	EndFunction


;ITEMS ---------------------------------------------->
  Formlist property EA_LevList_ItemToAdd auto  ;all mod-added weapons and armor
  SoulGem property EA_AzurasStarPetty auto
  SoulGem property EA_AzurasStarLesser auto
  SoulGem property EA_AzurasStarCommon auto
  SoulGem property EA_AzurasStarGreater auto
  SoulGem property EA_AzurasStarGrand auto
  SoulGem property DA01SoulGemAzurasStar auto

	Function removeModItems()

	  	int iInventory
	  	int iIndex = EA_LevList_ItemToAdd.getSize()
	  	while iIndex
	  		iIndex -= 1
	  		iInventory = playerRef.getItemCount(EA_LevList_ItemToAdd.getAt(iIndex))
	  		if iInventory
	  			playerRef.removeItem(EA_LevList_ItemToAdd.getAt(iIndex), iInventory)
	  		endif
	  	endWhile

	  	if playerRef.getItemCount(EA_AzurasStarPetty)
	  		playerRef.removeItem(EA_AzurasStarPetty, 1, true)
	  		playerRef.addItem(DA01SoulGemAzurasStar, 1, true)
	  	elseif playerRef.getItemCount(EA_AzurasStarLesser)
	  		playerRef.removeItem(EA_AzurasStarLesser, 1, true)
	  		playerRef.addItem(DA01SoulGemAzurasStar, 1, true)
	  	elseif playerRef.getItemCount(EA_AzurasStarCommon)
	  		playerRef.removeItem(EA_AzurasStarCommon, 1, true)
	  		playerRef.addItem(DA01SoulGemAzurasStar, 1, true)
	  	elseif playerRef.getItemCount(EA_AzurasStarGreater)
	  		playerRef.removeItem(EA_AzurasStarGreater, 1, true)
	  		playerRef.addItem(DA01SoulGemAzurasStar, 1, true)
	  	elseif playerRef.getItemCount(EA_AzurasStarGrand)
	  		playerRef.removeItem(EA_AzurasStarGrand, 1, true)
	  		playerRef.addItem(DA01SoulGemAzurasStar, 1, true)
	  	endif

	EndFunction


;PERKS ---------------------------------------------->
  EA_PerkRespecOnInstallScript property perkScript auto

	Function resetEnchantingPerkTree()
		perkScript.uninstallPerkRespec()
	EndFunction




  ;make sure any scripts attached to vanilla stuff (like enchant MGEFs) are set to STATE with empty functions/events.