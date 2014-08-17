Scriptname EA_HostileSoulGemTrapScript extends ObjectReference
{forces player into the trapAlias if they have the perk}


Actor property playerRef auto
Perk property EA_EssenceModulation auto 				  ;perk required for absorbing trap energy
ReferenceAlias property refAlias auto 					  ;playerAlias on EA_SoulGemQuest that will respond to trap
EA_HostileTrapAliasScript property refScript auto 		  ;script on the aforementioned alias
bool property playerSeesMe auto hidden


Event OnCellAttach()

	if playerRef.hasPerk(EA_EssenceModulation)
		if refScript.registerThisTrapWithPlayerAlias(self as objectReference)
			registerForLOS(playerRef, (self as objectReference))
			utility.wait(1.5) 								  ;give it time to setup and handshake its gem
			if refScript.checkIfValidTrapForPlayer(self as objectReference) ;is this trap armed, the closest trap to player, and can player absorb more energy today?
				refAlias.forceRefTo(playerRef)
				handshakePlayer()
			endif
		endif
	endif
EndEvent


Function handshakePlayer()
	MagicTrap trapScript = (self as objectReference) as MagicTrap
	refScript.trapPedestal = trapScript.trapSelf  ;fill variables for the playerAlias script
	refScript.trapGem = trapScript.mySoulGem
	refScript.trapDisarmed = false
	refScript.runSetup()
EndFunction


Event onCellDetach()
	utility.wait(2.0)
	refScript.updateTrackedTrapsList() ;removes trap from the tracking array if it's still in it
EndEvent


Event OnGainLOS(Actor akViewer, ObjectReference akTarget)
	playerSeesMe = true
EndEvent

Event OnLostLOS(Actor akViewer, ObjectReference akTarget)
	playerSeesMe = false
EndEvent


;Event OnCellDetach()  ;ALL THIS GETS DONE IN refScript's bootAlias() function now.
	;refScript.trapSensed = false
	; if refScript.healRateMod > 0
	; 	playerRef.modActorValue("HealRate", (healRateMod * -1.0))    ;ensure player's HealRate is reset
	; endif
	;refScript.unregisterForUpdate()
	;refAlias.clear()
;EndEvent