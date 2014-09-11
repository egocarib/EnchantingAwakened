Scriptname EA_Learn_ResistPoison01 extends ActiveMagicEffect
{when resist poison enchantment is equipped, this script adds a
"Perk to Apply" to several poison trap Magic Effects, so that if
the player gets hit by them, I can detect the poison event and
advance learning accordingly}

MagicEffect  property  TrapPoisonFFContactEffect       auto
MagicEffect  property  TrapPoisonGasMagicEffect        auto
Perk         property  EA_Learn_PosionedIndicatorPerk  auto

bool	dartPerkApplied
bool	gasPerkApplied

Event OnEffectStart(Actor target, Actor caster)
	ApplyPoisonDetectionPerk()
EndEvent

Event OnPlayerLoadGame()
    ApplyPoisonDetectionPerk()
EndEvent

Function ApplyPoisonDetectionPerk()
	;confirm no other mod has added a perk to these effects before we change it:
	Perk checkPerk = TrapPoisonFFContactEffect.GetPerk()
	if (checkPerk)
		debug.trace("Enchanting Awakened: WARNING - Poison Trap Magic Effect has been modified by another mod. " \
				  + "Learning for Resist Poison enchantment will not work when hit by poison dart traps.")
		dartPerkApplied = false
	else
		TrapPoisonFFContactEffect.SetPerk(EA_Learn_PosionedIndicatorPerk)
		dartPerkApplied = true
	endif

	checkPerk = TrapPoisonGasMagicEffect.GetPerk()
	if (checkPerk)
		debug.trace("Enchanting Awakened: WARNING - Poison Gas Magic Effect has been modified by another mod. " \
				  + "Learning for Resist Poison enchantment will not work when hit by clouds of poison gas.")
		gasPerkApplied = false
	else
		TrapPoisonGasMagicEffect.SetPerk(EA_Learn_PosionedIndicatorPerk)
		gasPerkApplied = true
	endif
EndFunction

Event OnEffectFinish(Actor target, Actor caster)
    if (dartPerkApplied)
		TrapPoisonFFContactEffect.SetPerk(none)
	endif
	if (gasPerkApplied)
		TrapPoisonGasMagicEffect.SetPerk(none)
	endif
EndEvent