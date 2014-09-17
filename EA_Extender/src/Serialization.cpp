#include "Serialization.h"
#include "skse/PluginAPI.h"
#include "[PluginLibrary]/SerializeForm.h"
#include "Events.h"
#include "Learning.h"



namespace EASerialization
{
	void Serialization_Revert(SKSESerializationInterface* intfc)
	{
		g_equipEventHandler.Reset();
	}

	void Serialization_Save(SKSESerializationInterface* intfc)
	{
		_MESSAGE("Saving...");

		if (intfc->OpenRecord('EQUI', kSerializationDataVersion))
			g_equipEventHandler.Serialize_EquippedEnchantments(intfc);
		if (intfc->OpenRecord('LEAR', kSerializationDataVersion))
			g_learnedExperienceMap.Serialize(intfc);
	}

	void Serialization_Load(SKSESerializationInterface* intfc)
	{
		_MESSAGE("Loading...");

		//Clear player's currently equipped weapon enchantments (must do this even if no data to load)
		g_equipEventHandler.Reset();

		UInt32	type, version, length;
		bool	error = false;

		while(!error && intfc->GetNextRecordInfo(&type, &version, &length))
		{
			if (version == kSerializationDataVersion)
			{
				if (type == 'EQUI' || type == 'LEAR')
				{
					UInt32 sizeRead;
					UInt32 sizeExpected;
					
					if (type == 'EQUI')
						g_equipEventHandler.Deserialize_EquippedEnchantments(intfc, &sizeRead, &sizeExpected);
					else //type == 'LEAR'
						g_learnedExperienceMap.Deserialize(intfc, &sizeRead, &sizeExpected);

					length -= sizeRead;

					if (sizeRead != sizeExpected)
						{ _MESSAGE("Error Reading Cosave: Invalid Chunk Size, Aborting... (type: %08X read: %u expected: %u)", type, sizeRead, sizeExpected); error = true; }
					else if (length > 0)
						_MESSAGE("Warning: Leftover data during deserialization (type: %08X length: %u). Attempting to continue load anyway...", type, length);
				}
				else
					{ _MESSAGE("Error Reading Cosave: Unhandled Type %08X, Aborting...\n", type); error = true; }
			}
			else
				{ _MESSAGE("Error Reading Cosave: Unknown Data Version %u, Aborting...\n", version); error = true; }
		}
	}
};