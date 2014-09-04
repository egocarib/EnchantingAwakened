#include "skse/GameEvents.h"

class ActorMagicCaster;
class TESObjectREFR;
class Actor;


namespace Events
{

struct TESEquipEvent
{
	Actor*		actor;			// 00
	UInt32		equippedFormID;	// 04
	UInt32		unk08;			// 08  (always 0)  specific ObjectReference FormID if item has one?
	UInt16		unk0C;			// 0C  (always 0)
	bool		isEquipping;	// 0E
	// more?
};


struct TESHitEvent
{
	enum
	{   //for use with primaryFlags
		kFlag_PowerAttack = (1 << 0),
		kFlag_SneakAttack = (1 << 1),
		kFlag_Bash		  = (1 << 2),
		kFlag_Blocked	  = (1 << 3),
		kFlag_MagicHit    = (0x4952B << 4) //when present, contactData01 is a valid pointer & either it or contactData02 points to an ActorMagicCaster (magic hit data)
	};

	//Members
	TESObjectREFR*		target;				//00
	TESObjectREFR*		caster;				//04
	UInt32				sourceFormID;		//08
	UInt32				projectileFormID;	//0C  empty when hitting actors with arrow. Otherwise usually filled (spells/enchants/hitting non-actor object with arrow all work fine)
	UInt32				primaryFlags;		//10
	UInt32				secondaryFlags;		//14
	TESObjectREFR**		dupTarget; 			//18  (same as 00)
	TESObjectREFR**		dupCaster; 			//1C  (same as 04)
	UInt32				dupSourceFormID;	//20  (same as 08)
	UInt32				dupProjectileFormID;//24  (same as 0C)
	void *				contactData01;		//28  never null but often have no rtti. either or both can be invalid. spent hours trying
	void *				contactData02;		//2C  to correlate the type of these to flags but can't, so using rtti debug funcs for now
	//												-Everything I've seen show up in ContactData:
	//													ActorMagicCaster, SpellItem, EnchantmentItem, ArrowProjectile, MissileProjectile,
	//													Explosion, TESObjectREFR, Character, PlayerCharacter
	//												-Other things I expect might show up:
	//													Actor, AlchemyItem, IngredientItem, ScrollItem, ChainExplosion, Hazard, Projectile,
	//													BarrierProjectile, BeamProjectile, ConeProjectile, FlameProjectile, GrenadeProjectile

private:
	TESObjectREFR*		_getProjectileRef(void* obj);
	bool				_isActorMagicCaster(void* obj);

public:
	TESObjectREFR*		GetProjectileRef();
	TESForm*			GetProjectileForm();
	ActorMagicCaster*	GetMagicHitData();
	UInt32				GetMagicHitSource();
	EnchantmentItem*	GetMagicHitEnchantment();
};




//EQUIP EVENT HANDLER ==========================>
template <>
class BSTEventSink <TESEquipEvent>
{
public:
	virtual ~BSTEventSink() {}
	virtual EventResult ReceiveEvent(TESEquipEvent * evn, EventDispatcher<TESEquipEvent> * dispatcher) = 0;
};

class TESEquipEventHandler : public BSTEventSink <TESEquipEvent> 
{
public:
	virtual	EventResult	ReceiveEvent(TESEquipEvent * evn, EventDispatcher<TESEquipEvent> * dispatcher);
};


//HIT EVENT HANDLER ============================>
template <>
class BSTEventSink <TESHitEvent>
{
public:
	virtual ~BSTEventSink() {}	// todo?
	virtual	EventResult ReceiveEvent(TESHitEvent * evn, EventDispatcher<TESHitEvent> * dispatcher) = 0;
};

class TESHitEventHandler : public BSTEventSink <TESHitEvent>
{
public:
	virtual	EventResult ReceiveEvent(TESHitEvent * evn, EventDispatcher<TESHitEvent> * dispatcher);
};

};


extern	EventDispatcher<Events::TESEquipEvent>*		g_equipEventDispatcher;
extern	Events::TESEquipEventHandler				g_equipEventHandler;

extern  EventDispatcher<Events::TESHitEvent>*		g_hitEventExDispatcher;
extern  Events::TESHitEventHandler					g_hitEventExHandler;