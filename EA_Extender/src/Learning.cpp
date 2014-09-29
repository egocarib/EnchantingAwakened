#include "Learning.h"
#include "EnchantingAwakenedData.h"
#include "Events.h"

Learning::EnchantmentExperienceMap		g_learnedExperienceMap;
const std::string 						LEARN_EVENT_NAME("EA_AddLearningExperienceEvent");



namespace Learning
{
	float				kLearnExperienceMultiplier = 1.0;
	FloatSetT			LearnLevelThresholds;

	void SendLearnEvent(EnchantmentItem* e, UInt32 learnTotal)
	{
		if (g_userExclusions.IsExcluded(e))
			return;
		
		BSFixedString learnEventName(LEARN_EVENT_NAME.c_str());

		SKSEModCallbackEvent evn(learnEventName, "", learnTotal, e);
		g_skseModEventDispatcher->SendEvent(&evn);
	}

	void EnchantmentExperienceMap::AdvanceLearning(EnchantmentItem* e)
	{
		FloatSetT::iterator preIt	 = LearnLevelThresholds.lower_bound(tracker[e]);
		tracker[e]					+= kLearnExperienceMultiplier;
		FloatSetT::iterator postIt	 = LearnLevelThresholds.lower_bound(tracker[e]);

		if (preIt != postIt) //Experience level increase
		{
			if (preIt != LearnLevelThresholds.end())
				SendLearnEvent(e, *preIt); //return threshold just passed
			else
				_MESSAGE("Error: cannot dereference pointer to learn threshold passed [size: %u curXP: %g]", LearnLevelThresholds.size(), tracker[e]);
		}
	}
}



//have to leave registration to the papyrus script using RegisterForMod event, otherwise I'd have to make a
//separate papyrus register function for forms, aliases, and activemagiceffects...

//could make papyrus method to retrieve the event name though, to make it seem a little more well designed :)


//RegisterForModEvent("EA_LearnEvent", "OnLearnEvent")
//Callback:
//	OnLearnEvent(Enchantment thisEnchantment, int totalUses) - event will be sent every 100 uses of weapon enchantment