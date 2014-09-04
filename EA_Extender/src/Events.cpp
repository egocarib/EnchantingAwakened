#include "skse/GameRTTI.h"
#include "skse/GameReferences.h" //req
#include "skse/GameObjects.h" //req
#include "skse/GameForms.h" //req
#include "skse/Utilities.h"

#include "Types.h"
#include "Events.h"
#include "EquipData.h"
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
{   //tried forever to find a flag that indicates these types in contactData... but it's impossible, same flags for invalid or other types... (unless TESHitEvent has additional members, haven't tested)
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
	//enchantment hit will have either weapon or enchantment as sourceForm (melee & bow attacks, respectively)
	TESForm* src = LookupFormByID(sourceFormID);
	EnchantmentItem* enchantment = DYNAMIC_CAST(src, TESForm, EnchantmentItem);
	if (!enchantment)
		if (DYNAMIC_CAST(src, TESForm, TESObjectWEAP))
			if (ActorMagicCaster* magicHitData = GetMagicHitData())
				enchantment = DYNAMIC_CAST(magicHitData->magicItem, MagicItem, EnchantmentItem);

	return enchantment;
}











EventResult TESEquipEventHandler::ReceiveEvent(TESEquipEvent * evn, EventDispatcher<TESEquipEvent> * dispatcher)
{
	static Actor* player = DYNAMIC_CAST((*g_thePlayer), PlayerCharacter, Actor);

	if (!evn || evn->actor != player)
		return kEvent_Continue;

	TESForm* equippedForm = LookupFormByID(evn->equippedFormID);
	EnchantmentItem* enchantment = DYNAMIC_CAST(equippedForm, TESForm, EnchantmentItem);
	if (!enchantment || enchantment->data.unk14 == 0x0C) //ignore staff enchantments, for now (may add later)
		return kEvent_Continue;

	if (evn->isEquipping)
		g_playerEquippedWeaponEnchantments.Push(evn->equippedFormID);
	else
		g_playerEquippedWeaponEnchantments.Pop(evn->equippedFormID);

	return kEvent_Continue;
}


EventResult TESHitEventHandler::ReceiveEvent(TESHitEvent * evn, EventDispatcher<TESHitEvent> * dispatcher)
{
	//TODO: build these in as private variables for TESHitEventHandler
	static TESObjectREFR* player = DYNAMIC_CAST((*g_thePlayer), PlayerCharacter, TESObjectREFR);
	static std::map<EnchantmentItem*, time_t> hitDelayMap;

	if (!evn || evn->caster != player)
		{_MESSAGE("evn aborted: NOT PLAYER"); return kEvent_Continue; }

	if (!g_playerEquippedWeaponEnchantments.HasData()) //Not wielding an enchanted weapon
		{_MESSAGE("evn aborted: PLAYER NOT WIELDING ENCHANTED ITEM"); return kEvent_Continue;}


	//event - only advance timer if recorded enchant hit.

	EnchantmentItem* enchantment = evn->GetMagicHitEnchantment();

	if (!enchantment) //wasn't retrieved from event data (always worked in testing, but just in case)
		if (!(enchantment = ExtraEnchantmentInfo::GetActorSourceEnchantment(*g_thePlayer, evn->GetMagicHitSource())))
			{_MESSAGE("evn aborted: can't get enchantment data"); return kEvent_Continue;}


	//timer is used to ignore multiple hit events triggered by a single enchantment
	time_t thisTime = time(NULL);
	if (difftime(thisTime, hitDelayMap[enchantment]) < 1.0)
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