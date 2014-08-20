//EnchantmentData.h
#include <vector>
#include <algorithm>

class EnchantmentData
{

private:

	typedef std::vector<EnchantmentItem*> EnchVec;
	EnchVec knownEnchants;		//cache for last retrieved list of known enchantments
	EnchVec newEnchants;		//cache for new known enchantments detected during last retrieval

public:

	enum
	{
		kDelivery_Self;
		kDelivery_Contact;
		kDelivery_Aimed;
		kDelivery_TargetActor;
		kDelivery_TargetLocation;
	};

	bool IsWeaponEnchantment(EnchantmentItem* enchantment)
	{
		return (enchantment) ? (enchantment->data.deliveryType == kDelivery_Contact) : FALSE; //Weapon enchantment
	}

	//Returns number of normal (not player-created) known enchantments, and inserts them all into outputKnown array.
	//Returns -1 if no enchantments are known by the player.
	UInt32 UpdatePlayerKnownEnchantments(VMArray<EnchantmentItem*> &outputKnown)
	{
		DataHandler* loadedForms = DataHandler::GetSingleton();
		EnchVec known;

		for(UInt32 i = 0; i < loadedForms->enchantments.count; i++)
		{
			EnchantmentItem* ench = NULL;
			loadedForms->enchantments.GetNthItem(i, ench);
			if (ench && (ench->flags & TESForm::kFlagPlayerKnows))
				known.push_back(ench); //player knows
		}

		if (outputKnown.Length() < known.size())
		{
			_MESSAGE("GetPlayerKnownEnchantments overflow error: known(%u), outputCapacity(%u)", known.size(), outputKnown.Length());
			return 0xFFFFFFFF;
		}

		newEnchants.clear();

		for (UInt32 i = 0; i < known.size(); i++)
		{
			outputKnown.Set(&known[i], i);
			if (std::find(knownEnchants.begin(), knownEnchants.end(), known[i]) == knownEnchants.end()) //Was not known during last check
				newEnchants.push_back(known[i]);
		}

		knownEnchants = known;

		return knownEnchants.size();
	}
};