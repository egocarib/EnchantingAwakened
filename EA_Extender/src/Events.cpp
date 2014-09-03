#include "skse/GameRTTI.h"
#include "skse/GameReferences.h" //req
#include "skse/GameObjects.h" //req
#include "skse/GameForms.h" //req
#include "skse/Utilities.h"

#include "Types.h"
#include "Events.h"

#include <time.h>

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

bool TESHitEvent::GetEnchantmentHitData(EnchantmentItem* &enchantment, bool &leftHandSource)
{
	//enchantment hit will have either weapon or enchantment as sourceForm (melee & bow attacks, respectively)
	//I believe this should always retrieve valid enchantment, but source data returned in case it needs to be manually retrieved.
	TESForm* src = LookupFormByID(sourceFormID);
	if (src)
	{
		enchantment = DYNAMIC_CAST(src, TESForm, EnchantmentItem);
		if (enchantment || DYNAMIC_CAST(src, TESForm, TESObjectWEAP))
		{
			ActorMagicCaster* magicHitData = GetMagicHitData();
			if (!magicHitData || magicHitData->source == ActorMagicCaster::kSource_Voice)
				return false;
			if (!enchantment) //enchantment stored here if it wasn't in sourceFormID -->
				enchantment = DYNAMIC_CAST(magicHitData->magicItem, MagicItem, EnchantmentItem);
			leftHandSource = (magicHitData->source == ActorMagicCaster::kSource_Left);
			return true;
		}
	}
	return false;
}









EventResult TESEquipEventHandler::ReceiveEvent(TESEquipEvent * evn, EventDispatcher<TESEquipEvent> * dispatcher)
{

	if (evn->isEquipping)
		_MESSAGE("equipped 0x%08X", evn->equippedFormID);

	// static bool isEquippingEnchantment = false;
	// static std::map<Actor*, EnchantmentItem*> eq_map;

	// if (!evn)
	// 	return kEvent_Continue;

	// TESForm* eqForm = LookupFormByID(evn->equippedFormID);

	// if (!isEquippingEnchantment)
	// {
	// 	EnchantmentItem* eqEnch = DYNAMIC_CAST(eqForm, TESForm, EnchantmentItem);
	// 	if (eqEnch)
	// 	{
	// 		eq_map[evn->actor] = eqEnch;	//Map enchantment to actor
	// 		isEquippingEnchantment = true;
	// 		return kEvent_Continue;			//Wait for weapon equip event to come next
	// 	}
	// }

	// else //Enchantment equip event was just received (this is reliable for every enchanted weapon equip or unequip, except when
	// 	//the game first loads if player had something equipped already when last save was made - so, need to update manually on first load)
	// {
	// 	TESObjectWEAP* eqWeap = DYNAMIC_CAST(eqForm, TESForm, TESObjectWEAP);
	// 	if (eqWeap)
	// 	{
	// 		std::map<Actor*, EnchantmentItem*>::iterator it = eq_map.find(evn->actor);
	// 		std::map<Actor*, EnchantmentItem*>::iterator itEnd = eq_map.end();
	// 		if (it != itEnd)
	// 		{
	// 			eq_map.erase(it);
	// 			EAInternal::UpdateCurrentEquipInfo(evn->actor);
	// 		}
	// 	}
	// 	isEquippingEnchantment = false;
	// }

	return kEvent_Continue;
}


EventResult TESHitEventHandler::ReceiveEvent(TESHitEvent * evn, EventDispatcher<TESHitEvent> * dispatcher)
{
	static TESObjectREFR* player = DYNAMIC_CAST((*g_thePlayer), PlayerCharacter, TESObjectREFR);
	static time_t timer;

	if (!evn || evn->caster != player)
		return kEvent_Continue;

	//I should also keep track of a bool that indicates whether the player is even wielding an enchanted item,
	//if they are not, I can skip this whole event, since it will be constant unnecessary processing.
	//   (mark this using equip event, and perhaps interface with Enchanted Arsenal?)

	time_t thisTime;
	time(&thisTime);
	_MESSAGE("difftime equals %u", difftime(thisTime, timer));
	if (difftime(thisTime, timer) < 1.0) //timer prevents spam and also multi-hit events sent by enchantment with multiple effects
		return kEvent_Continue;

	//event - only advance timer if recorded enchant hit.

	EnchantmentItem* enchantment;
	bool leftHandSource;
	if (!evn->GetEnchantmentHitData(enchantment, leftHandSource))
		return kEvent_Continue;
	
	//process enchantment hit, increment learning, etc.
	//map of enchantments and # of times actor hit someone else? Power attacks worth slightly more?
	//can either send event from here, or use an IsInCombat ability's OnEffectFinish() event in papyrus to
	//poll the new values from papyrus (and clear out the array here? if so, would still need to serialize if saved mid-combat)

	//........

	time(&timer); //advance timer
	_MESSAGE("enchant hit event recorded. timer now advanced to %u (0x%08X) (%f)", timer);
	_MESSAGE("enchantment: 0x%08X  caster: 0x%08X  source: %s", (enchantment) ? enchantment->formID : NULL, evn->caster->formID, leftHandSource ? "LEFT" : "RIGHT");

	return kEvent_Continue;
}




};