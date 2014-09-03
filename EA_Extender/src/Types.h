#pragma once

class MagicItem;
class NiNode;
class TESRace;
class TESObjectREFR;


class ActorMagicCaster // : MagicCaster [have not found example of NonActorMagicCaster yet to determine the extent of parent]
{
public:
	enum
	{
		kSource_Left,           //(observed: chaurus spit)
		kSource_Right,
		kSource_Voice,
		kSource_Projectile		//???  (observed: hit from enchanted bow, chaurus bite [each had projectile, but chaurus spit and spells also had projectile, so not sure exactly...])
	};

	void*			unk00;		//00
	void*			unk04;		//04  (points to something representing right/left hand data for actor, stays same regardless of what enchanted weapon is wielded in a particular hand. right/left hand extraData?)
	UInt32  		flags08[2];	//08
	void*   		unk10;		//10
	MagicItem*		magicItem;	//14  (SpellItem or EnchantmentItem, but if enchantment from bow, this will be null, shouts seem to be null too (but sourceFormID && obj1 in hit event will hold shout spell))
	UInt32			flags18;	//18
	void*			unk1C[10];	//1C
	NiNode*			node01;		//44
	void*			unk48;		//48
	UInt32			flags4C;	//4C
	void*			unk50;		//50
	TESRace*		race;		//54  (null if caster is the player)
	void*			unk58;		//58
	UInt32			flags5C;	//5C  (have seen 0x87 and 0x88)
	void*			unk60[2];	//60
	TESObjectREFR*	caster;		//68
	NiNode*			node02;		//6C
	void*			unk70[6];	//70
	UInt32			source;		//88
	UInt32			unkFlags;	//8C  (have only seen 0x00, 0x04 and 0x08) [0x08 with bow and enemy projectiles/spells, 0x04 with mace enchanted, 0x00 for draugr shout]
	void*			unk90[6];	//90  (last member here seems to have consistent rtti (like SpellItem) sometimes but not always. most after this seems to be invalid data, probably the end of the class.
	//							//more?
};