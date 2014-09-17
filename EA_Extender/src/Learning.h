#pragma once

#include "[PluginLibrary]/SerializeForm.h"
#include "skse/GameRTTI.h"
#include <string>
#include <map>

class TESForm;
class EnchantmentItem;


namespace Learning
{

class EnchantmentExperienceMap
{
private:
	typedef std::map<EnchantmentItem*, UInt32> LearnMapT;
	LearnMapT	tracker;

public:
	EnchantmentExperienceMap() : tracker() {}

	void AdvanceLearning(EnchantmentItem* e);

	void Reset() { tracker.clear(); }

	template <typename SerializeInterface_T>
	void Serialize(SerializeInterface_T* const intfc)
	{
		UInt32 numberTracked = tracker.size();
		intfc->WriteRecordData(&numberTracked, sizeof(UInt32)); //Number of entries to follow
		for (LearnMapT::iterator it = tracker.begin(); it != tracker.end(); it++)
		{
			SerialFormData trackedEnchantment(it->first);
			intfc->WriteRecordData(&trackedEnchantment, sizeof(SerialFormData));
			intfc->WriteRecordData(&it->second, sizeof(UInt32));
		}
	}

	template <typename SerializeInterface_T>
	void Deserialize(SerializeInterface_T* const intfc, UInt32* const sizeRead, UInt32* const sizeExpected)
	{
		this->Reset();
		(*sizeRead) = (*sizeExpected) = 0;

		UInt32 numberTracked;
		(*sizeRead) += intfc->ReadRecordData(&numberTracked, sizeof(UInt32));
		(*sizeExpected) += sizeof(UInt32);
		if (*sizeRead != *sizeExpected)
			return;

		for (UInt32 i = 0; i < numberTracked; i++)
		{
			SerialFormData	thisFormData;
			UInt32			thisExperience;

			(*sizeRead) += intfc->ReadRecordData(&thisFormData, sizeof(SerialFormData));
			(*sizeRead) += intfc->ReadRecordData(&thisExperience, sizeof(UInt32));
			(*sizeExpected) += sizeof(SerialFormData) + sizeof(UInt32);
			if (*sizeRead != *sizeExpected)
				return;

			TESForm* thisForm;
			UInt32 result = thisFormData.Deserialize(&thisForm);
			if (result != SerialFormData::kResult_Succeeded)
				SerialFormData::OutputError(result);
			else
			{
				EnchantmentItem* thisEnchantment = DYNAMIC_CAST(thisForm, TESForm, EnchantmentItem);
				if (thisEnchantment)
					tracker[thisEnchantment] = thisExperience;
			}
		}
	}
};

};

extern	Learning::EnchantmentExperienceMap		g_learnedExperienceMap;
extern	const std::string						LEARN_EVENT_NAME;