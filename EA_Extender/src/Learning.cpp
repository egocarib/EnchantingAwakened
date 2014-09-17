#include "Learning.h"
#include "Events.h"

Learning::EnchantmentExperienceMap		g_learnedExperienceMap;
const std::string 						LEARN_EVENT_NAME("EA_AddLearningExperienceEvent");



namespace Learning
{
	void SendLearnEvent(EnchantmentItem* e, UInt32 learnTotal)
	{
		BSFixedString learnEventName(LEARN_EVENT_NAME.c_str());

		SKSEModCallbackEvent evn(learnEventName, "", learnTotal, e);
		g_skseModEventDispatcher->SendEvent(&evn);
	}

	void EnchantmentExperienceMap::AdvanceLearning(EnchantmentItem* e)
	{
		tracker[e]++;
		if (tracker[e] % 50 == 0)
			SendLearnEvent(e, tracker[e]);
	}
}



//have to leave registration to the papyrus script using RegisterForMod event, otherwise I'd have to make a
//separate papyrus register function for forms, aliases, and activemagiceffects...

//could make papyrus method to retrieve the event name though, to make it seem a little more well designed :)


//RegisterForModEvent("EA_LearnEvent", "OnLearnEvent")
//Callback:
//	OnLearnEvent(Enchantment thisEnchantment, int totalUses) - event will be sent every 100 uses of weapon enchantment