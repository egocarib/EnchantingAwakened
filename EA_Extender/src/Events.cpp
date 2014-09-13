#include "skse/GameRTTI.h"
#include "skse/GameReferences.h"
#include "skse/GameObjects.h"
#include "skse/Utilities.h"
#include "Types.h"
#include "Events.h"
#include "ExtraEnchantmentInfo.h"
#include <time.h>
#include <map>


EventDispatcher<Events::TESEquipEvent>*	g_equipEventDispatcher = (EventDispatcher<Events::TESEquipEvent>*) 0x012E4EA0;
Events::TESEquipEventHandler			g_equipEventHandler;

EventDispatcher<Events::TESHitEvent>*	g_hitEventExDispatcher = (EventDispatcher<Events::TESHitEvent>*) 0x012E4F60;
Events::TESHitEventHandler				g_hitEventExHandler;



namespace Events
{

TESObjectREFR* TESHitEvent::_getProjectileRef(void* obj)
{   //tried forever to find a flag that indicates these types in contactData... but it's impossible, same flags for invalid or other types...
	const char* rttiName = GetObjectClassName(obj);
	if (strcmp(rttiName, "ArrowProjectile@@") == 0)
		return DYNAMIC_CAST(obj, ArrowProjectile, TESObjectREFR);
	if (strcmp(rttiName, "MissileProjectile@@") == 0)
		return DYNAMIC_CAST(obj, MissileProjectile, TESObjectREFR);
	return NULL;
}

bool TESHitEvent::_isActorMagicCaster(void* obj)
{
	return (strcmp(GetObjectClassName(obj), "ActorMagicCaster@@") == 0) ? true : false;
}

TESObjectREFR* TESHitEvent::GetProjectileRef()
{
	TESObjectREFR* ref = _getProjectileRef(contactData01);
	return (ref) ? ref : _getProjectileRef(contactData02);
}

TESForm* TESHitEvent::GetProjectileForm()
{
	if (projectileFormID)
		return LookupFormByID(projectileFormID);

	TESObjectREFR* ref = GetProjectileRef();
	return (ref) ? ref->baseForm : NULL;
}

ActorMagicCaster* TESHitEvent::GetMagicHitData() //enchantment or other spell effect hit
{
	if (_isActorMagicCaster(contactData01))
		return reinterpret_cast<ActorMagicCaster*>(contactData01);
	if (_isActorMagicCaster(contactData02))
		return reinterpret_cast<ActorMagicCaster*>(contactData02);
	return NULL;
}

UInt32 TESHitEvent::GetMagicHitSource()
{
	ActorMagicCaster* magicHitData = GetMagicHitData();
	return (magicHitData) ? magicHitData->source : 0xFFFFFFFF;
}

EnchantmentItem* TESHitEvent::GetMagicHitEnchantment()
{
	//enchantment hit will have either weapon or enchantment as sourceForm (for melee & bow attacks, respectively)
	TESForm* src = LookupFormByID(sourceFormID);
	EnchantmentItem* enchantment = DYNAMIC_CAST(src, TESForm, EnchantmentItem);
	if (!enchantment)
		if (src->formType == TESObjectWEAP::kTypeID)
			if (ActorMagicCaster* magicHitData = GetMagicHitData())
				enchantment = DYNAMIC_CAST(magicHitData->magicItem, MagicItem, EnchantmentItem);

	return enchantment;
}







void TESEquipEventHandler::EquippedWeaponEnchantments::Push(UInt32 formID)
{
	if (formID)
	{
		if (enchantment01 == 0)
			{enchantment01 = formID;
			_MESSAGE("enchantment01 == %08X", formID);}
		else if (enchantment02 == 0)
			{enchantment02 = formID;
			_MESSAGE("enchantment02 == %08X", formID);}
		else
			_MESSAGE("Error: cannot record equipped player weapon enchantment, data retainer already full.");
	}
}

void TESEquipEventHandler::EquippedWeaponEnchantments::Pop(UInt32 formID)
{
	if (enchantment01 == formID)
		{enchantment01 = 0;
		_MESSAGE("enchantment01 == NULL");}
	else if (enchantment02 == formID)
		{enchantment02 = 0;
		_MESSAGE("enchantment02 == NULL");}
	else
		_MESSAGE("Error: unequipped player weapon enchantment not found in data retainer.");
}

void TESEquipEventHandler::EquippedWeaponEnchantments::Clear()
{
	enchantment01 = 0;
	enchantment02 = 0;
}


EventResult TESEquipEventHandler::ReceiveEvent(TESEquipEvent * evn, EventDispatcher<TESEquipEvent> * dispatcher)
{
	if (evn->actor->baseForm != (*g_thePlayer)->baseForm)
		return kEvent_Continue;

	TESForm* equippedForm = LookupFormByID(evn->equippedFormID);
	EnchantmentItem* enchantment = DYNAMIC_CAST(equippedForm, TESForm, EnchantmentItem);
	if (!enchantment || enchantment->data.unk14 == 0x0C) //ignore staff enchantments, for now (may add later)
		return kEvent_Continue;

	if (evn->isEquipping)
		playerEquippedWeaponEnchantments.Push(evn->equippedFormID);
	else
		playerEquippedWeaponEnchantments.Pop(evn->equippedFormID);

	g_hitEventExDispatcher->RemoveEventSink(&g_hitEventExHandler);
	if (playerEquippedWeaponEnchantments.HasData())
		g_hitEventExDispatcher->AddEventSink(&g_hitEventExHandler);

	return kEvent_Continue;
}


EventResult TESHitEventHandler::ReceiveEvent(TESHitEvent * evn, EventDispatcher<TESHitEvent> * dispatcher)
{
	if (evn->caster->baseForm != (*g_thePlayer)->baseForm)
		{_MESSAGE("evn aborted: NOT PLAYER"); return kEvent_Continue; }

	//event - only advance timer if recorded enchant hit.

	EnchantmentItem* enchantment = evn->GetMagicHitEnchantment();

	if (!enchantment) //wasn't retrieved from event data (always worked in testing, but just in case)
		if (!(enchantment = ExtraEnchantmentInfo::GetActorSourceEnchantment(*g_thePlayer, evn->GetMagicHitSource())))
			{_MESSAGE("evn aborted: can't get enchantment data"); return kEvent_Continue;}


	//timer is used to ignore multiple hit events triggered by a single enchantment (and to add slight delay for learn framework)
	time_t thisTime = time(NULL);
	if (difftime(thisTime, hitDelayMap[enchantment]) < 1.0) //could make this delay an ini setting. different weapons attack at different speeds.
		{_MESSAGE("hit event from enchantment 0x%08X IGNORED, not enough time elapsed..", enchantment->formID); return kEvent_Continue;}
	hitDelayMap[enchantment] = thisTime;


	_MESSAGE("enchantment 0x%08X successfully processed in hit event", enchantment->formID);
	if (enchantment->data.unk14 == 0x0C)
		_MESSAGE("    ...but, it was a staff enchantment. FROWNY FACE FROWNY FACE");
	//process enchantment hit, increment learning, etc.
	//map of enchantments and # of times actor hit someone else? Power attacks worth slightly more?
	//can either send event from here, or use an IsInCombat ability's OnEffectFinish() event in papyrus to
	//poll the new values from papyrus (and clear out the array here? if so, would still need to serialize if saved mid-combat)

	//........

	_MESSAGE("    enchantment: 0x%08X  caster: 0x%08X  source: %s", (enchantment) ? enchantment->formID : NULL, evn->caster->formID, evn->GetMagicHitSource() ? "LEFT" : "RIGHT");

	return kEvent_Continue;
}




};