#include "skse/GameRTTI.h"
#include "skse/GameReferences.h"
#include "skse/GameObjects.h"
#include "skse/Utilities.h"
#include "Types.h"
#include "Events.h"
#include "Learning.h"
#include "ExtraEnchantmentInfo.h"
#include "EnchantingAwakenedData.h"
#include <time.h>
#include <map>


EnchantmentFrameworkInterface*			g_enchantmentFramework = NULL;
EventDispatcher<SKSEModCallbackEvent>*	g_skseModEventDispatcher = NULL;

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
			{
				enchantment = DYNAMIC_CAST(magicHitData->magicItem, MagicItem, EnchantmentItem);
				if (!enchantment)
					enchantment = ExtraEnchantmentInfo::GetActorSourceEnchantment(*g_thePlayer, GetMagicHitSource());
					//This last part may not be necessary. In testing, as long as there was ActorMagicCaster data, I was
					//always able to retrieve the enchantment without checking actor's source equipData. Added just in case.
			}

	return enchantment;
}







void TESEquipEventHandler::EquippedWeaponEnchantments::Push(UInt32 formID)
{
	if (formID)
	{
		if (enchantment01 == 0)
			enchantment01 = formID;
		else if (enchantment02 == 0)
			enchantment02 = formID;
		else
			_MESSAGE("Error: cannot record equipped player weapon enchantment, data retainer already full.");
	}
}

void TESEquipEventHandler::EquippedWeaponEnchantments::Pop(UInt32 formID)
{
	if (enchantment01 == formID)
		enchantment01 = 0;
	else if (enchantment02 == formID)
		enchantment02 = 0;
	// else //[this was showing up if player had enchanted items equipped before installing. Not really necessary anyway, tested this pretty thoroughly.]
	// 	_MESSAGE("Error: unequipped player weapon enchantment not found in data retainer.");
}

void TESEquipEventHandler::EquippedWeaponEnchantments::Clear()
{
	enchantment01 = 0;
	enchantment02 = 0;
}


EventResult TESEquipEventHandler::ReceiveEvent(TESEquipEvent* evn, EventDispatcher<TESEquipEvent>* dispatcher)
{
	if (evn->actor->baseForm != (*g_thePlayer)->baseForm)
		return kEvent_Continue;

	TESForm* equippedForm = LookupFormByID(evn->equippedFormID);

	EnchantmentItem* enchantment = DYNAMIC_CAST(equippedForm, TESForm, EnchantmentItem);

	if (!enchantment) //check active effects to see if an armor enchantment was equipped
	{
		if (evn->isEquipping)
			g_activeEnchantEffects.ProcessEquipped(); //find new equipped enchanted item and send event to papyrus
		else //unequipping
			g_activeEnchantEffects.ProcessUnequipped(); //find removed enchanted item and send event to papyrus
	}

	else if (enchantment->data.unk14 != 0x0C) //weapon enchantment equipped (but ignore staff enchantments for now)
	{
		if (evn->isEquipping)
			playerEquippedWeaponEnchantments.Push(evn->equippedFormID);
		else
			playerEquippedWeaponEnchantments.Pop(evn->equippedFormID);

		g_userExclusions.UpdateWeaponExclusions();

		g_hitEventExDispatcher->RemoveEventSink(&g_hitEventExHandler);
		if (playerEquippedWeaponEnchantments.HasData())
			g_hitEventExDispatcher->AddEventSink(&g_hitEventExHandler);
	}

	return kEvent_Continue;
}


EventResult TESHitEventHandler::ReceiveEvent(TESHitEvent* evn, EventDispatcher<TESHitEvent>* dispatcher)
{
	if (evn->caster->baseForm != (*g_thePlayer)->baseForm)
		return kEvent_Continue; //Ignore non-player attackers

	EnchantmentItem* enchantment = evn->GetMagicHitEnchantment();

	if (!enchantment) //Can't retrieve enchantment info
		return kEvent_Continue;

	if (enchantment->data.unk14 == 0x0C) //Staff enchantment
		return kEvent_Continue;

	//Timer is used to ignore multiple hit events triggered by a single enchantment (and to add slight delay for learn framework)
	time_t thisTime = time(NULL);
	if (difftime(thisTime, hitDelayMap[enchantment]) < 1.0) //(could make this delay an ini setting?)
		return kEvent_Continue; //Ignore multiple hit events from this enchantment
	hitDelayMap[enchantment] = thisTime;

	//Find base enchantment and advance learning
	if (enchantment->formID >= 0xFF000000)
	{
		std::vector<EnchantmentItem*> baseEnchantments = g_enchantmentFramework->GetCraftedEnchantmentParents(enchantment);
		for (UInt32 i = 0; i < baseEnchantments.size(); i++)
			g_learnedExperienceMap.AdvanceLearning(baseEnchantments[i]);
	}
	else
	{
		if (g_userExclusions.ShouldExcludeHitEventSource(evn))
			return kEvent_Continue;
		if (enchantment->data.baseEnchantment)
			enchantment = enchantment->data.baseEnchantment;
		g_learnedExperienceMap.AdvanceLearning(enchantment);
	}

	return kEvent_Continue;
}


};