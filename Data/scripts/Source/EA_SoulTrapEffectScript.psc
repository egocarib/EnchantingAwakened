Scriptname EA_SoulTrapEffectScript extends ActiveMagicEffect
{EA replacement soul trap effect script}

Actor property playerRef auto
EA_SoulTrapQuestScript property STQ auto
Perk property EA_EssenceNemesis auto
Keyword property ActorTypeNPC auto

Event onEffectFinish(Actor akTarget, Actor akCaster)
	if akTarget.isDead()
		if akCaster == playerRef
			if akTarget.hasKeyword(ActorTypeNPC)
				if akCaster.hasPerk(EA_EssenceNemesis)
					STQ.SoulTrapHuman(akTarget)
				else
					STQ.sendNoHumanSoulTrapMessage()
				endif
			else
				STQ.SoulTrapCreature(akTarget)
			endif
		else ;akCaster == NPC
			STQ.NPCSoulTrap(akTarget, akCaster)
		endif
	endif
EndEvent