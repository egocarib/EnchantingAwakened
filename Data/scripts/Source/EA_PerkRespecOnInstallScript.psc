Scriptname EA_PerkRespecOnInstallScript extends Quest

;script that removes all unlocked vanilla enchanting perks and gives the player
;perk points for the removed perks so they can respec into the new perk tree.

Perk[] property perksVanilla auto
Perk[] property perksEnchantingAwakened auto
Actor property playerRef auto
Message property EAPerkInstallRespecMsg01 auto
Message property EAPerkInstallRespecMsg02 auto
EA_PCDisenchantingControl property MainRef auto


Event onInit()
	registerForSingleUpdate(0.001)
EndEvent


Event onUpdate()

	int iRemoved = 0
	int iPerk = perksVanilla.Length

	while iPerk
		iPerk -= 1
		if playerRef.hasPerk(perksVanilla[iPerk])
			playerRef.removePerk(perksVanilla[iPerk])
			iRemoved += 1
		endif
	endwhile
    debug.trace("Enchanting Awakened ::::::::::::::::::::: " + iRemoved + " Perks removed")
  ;quick check for the one ACE perk that's not an altered vanilla record:
	int AceCheck = game.GetModByName("ACE Enchanting.esp")
	if AceCheck < 255 && AceCheck > 0 ;if ACE Enchanting is active:
		Perk MagicAnticipationPerk = game.getFormFromFile(0x000D63, "ACE Enchanting.esp") as Perk
		if playerRef.hasPerk(MagicAnticipationPerk)
			playerRef.removePerk(MagicAnticipationPerk)
			iRemoved += 1
		endif
	endif

	if iRemoved
		game.addPerkPoints(iRemoved)
		EAPerkInstallRespecMsg01.show()
		EAPerkInstallRespecMsg02.show(iRemoved as float)
	endif

	mainRef.PerkStateCore = 0
    debug.trace("Enchanting Awakened ::::::::::::::::::::: Perk State Core Reset to 0")

	goToState("RespecCompleted")

	((self as Quest) as EA_QF_PerkGainUpdates).initialized = true ;allow perk fragments to start running
EndEvent


State RespecCompleted
	Event onInit()
	EndEvent
	Event onUpdate()
	EndEvent
EndState


Function uninstallPerkRespec()
	;call this function from global uninstall quest.

	int iRemoved = 0
	
	int iPerk = perksEnchantingAwakened.Length
	while iPerk
		iPerk -= 1
		if playerRef.hasPerk(perksEnchantingAwakened[iPerk])
			playerRef.removePerk(perksEnchantingAwakened[iPerk])
			iRemoved += 1
		endif
	endwhile

	iPerk = perksVanilla.Length
	while iPerk
		iPerk -= 1
		if playerRef.hasPerk(perksVanilla[iPerk])
			playerRef.removePerk(perksVanilla[iPerk])
			iRemoved += 1
		endif
	endwhile

	if iRemoved
		game.addPerkPoints(iRemoved)
		EAPerkInstallRespecMsg02.show(iRemoved as float)
	endif
EndFunction