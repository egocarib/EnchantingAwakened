#pragma once

#include "[PluginLibrary]/SerializeForm.h"
#include "skse/GameRTTI.h"
#include <string>
#include <map>
#include <set>

class TESForm;
class EnchantmentItem;


namespace Learning
{
typedef	std::set<float>		FloatSetT;

extern	float				kLearnExperienceMultiplier;
extern	FloatSetT			LearnLevelThresholds;

template <typename SerializeInterface_T>
void SerializeConstants(SerializeInterface_T* const intfc)
{	
	intfc->WriteRecordData(&Learning::kLearnExperienceMultiplier, sizeof(float));

	UInt32 setSize = LearnLevelThresholds.size();
	intfc->WriteRecordData(&setSize, sizeof(UInt32));
	for (FloatSetT::iterator it = LearnLevelThresholds.begin(); it != LearnLevelThresholds.end(); it++)
		intfc->WriteRecordData(&(*it), sizeof(float));
}

template <typename SerializeInterface_T>
void DeserializeConstants(SerializeInterface_T* const intfc, UInt32* const sizeRead, UInt32* const sizeExpected)
{
	(*sizeRead) = (*sizeExpected) = 0;

	(*sizeRead) += intfc->ReadRecordData(&Learning::kLearnExperienceMultiplier, sizeof(float));
	(*sizeExpected) += sizeof(float);

	UInt32 setSize;
	(*sizeRead) += intfc->ReadRecordData(&setSize, sizeof(UInt32));
	(*sizeExpected) += sizeof(UInt32);
	if (*sizeRead != *sizeExpected)
		return;

	for (UInt32 i = 0; i < setSize; i++)
	{
		float thisThreshold;
		(*sizeRead) += intfc->ReadRecordData(&thisThreshold, sizeof(float));
		(*sizeExpected) += sizeof(float);
		if (*sizeRead != *sizeExpected)
			return;
		LearnLevelThresholds.insert(thisThreshold);
	}
}




class EnchantmentExperienceMap
{
private:
	typedef std::map<EnchantmentItem*, float> LearnMapT;
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
			intfc->WriteRecordData(&it->second, sizeof(float));
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
			float			thisExperience;

			(*sizeRead) += intfc->ReadRecordData(&thisFormData, sizeof(SerialFormData));
			(*sizeRead) += intfc->ReadRecordData(&thisExperience, sizeof(float));
			(*sizeExpected) += sizeof(SerialFormData) + sizeof(float);
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