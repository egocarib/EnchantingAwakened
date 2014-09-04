#pragma once


struct EquippedWeaponEnchantments
{
	UInt32	enchantment01;
	UInt32	enchantment02;

	EquippedWeaponEnchantments() : enchantment01(0), enchantment02(0) {}

	void Push(UInt32 formID)
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

	void Pop(UInt32 formID)
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

	void Clear()
	{
		enchantment01 = 0;
		enchantment02 = 0;
	}
	
	bool HasData() { return (enchantment01 || enchantment02); }
};

EquippedWeaponEnchantments g_playerEquippedWeaponEnchantments;