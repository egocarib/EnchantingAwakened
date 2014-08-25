Scriptname EA_Learn_FortifyWeapon extends EA_Learn_TemplateAME

GlobalVariable[]  property  typeEnabled  auto ;Globals indicating if the effect is learn-enabled (player is wearing an enchantment with that effect)
	;0 = FortifyOneHanded    1 = FortifyTwoHanded    2 = FortifyMarksman
int property NOWEAPON  = -1 autoreadonly
int property ONEHANDED =  0 autoreadonly
int property TWOHANDED =  1 autoreadonly
int property BOW       =  2 autoreadonly

int		equippedType
bool[]  isDeactivated


Event OnKillActor()
	if (equippedType >= 0)
		if (!isDeactivated[equippedType])
			learnManager.LearnWeapon(equippedType)
		endif
	endif
EndEvent


Event OnObjectEquipped(Form baseObject, ObjectReference ref)
	if (baseObject as Weapon)
		UpdateWeaponTypeEquipped()
	endif
EndEvent

Event OnObjectUnequipped(Form baseObject, ObjectReference ref)
	if (baseObject as Weapon)
		UpdateWeaponTypeEquipped()
	endif
EndEvent

Function UpdateWeaponTypeEquipped()
	registerForSingleUpdate(3.0) ;equip event spamkiller (new registrations will cancel previous)
EndFunction

Event OnUpdate() ;update equipped item type
	int weaponCheck = playerRef.GetEquippedItemType(1)
	if (weaponCheck == 7 || weaponCheck == 12) ;bow/crossbow
		equippedType = BOW
	elseif (weaponCheck == 5 || weaponCheck == 6) ;two-handed
		equippedType = TWOHANDED
	elseif (weaponCheck >= 1 && weaponCheck <= 4) ;one-handed
		equippedType = ONEHANDED
	else ;check left hand for one-handed item
		weaponCheck = playerRef.GetEquippedItemType(0)
		if (weaponCheck >= 1 && weaponCheck <= 4)
			equippedType = ONEHANDED
		else
			equippedType = NOWEAPON
		endif
	endif
EndEvent


Event OnUpdateActiveEffects(string evnName, string strArg, float numArg, Form sender)
	int i = 3
	while (i)
		i -= 1
		isDeactivated[i] = (typeEnabled[i].GetValue() < 1.0)
	endWhile
EndEvent


Event OnInit()
    isDeactivated = new bool[3]
    OnPlayerLoadGame()
    OnUpdate()
    OnUpdateActiveEffects("", "", 0, none)
EndEvent

Event OnPlayerLoadGame()
    RegisterForModEvent("EA_OnKillActorEvent", "OnKillActor")
    RegisterForModEvent("EA_UpdateActiveLearnEffects", "OnUpdateActiveEffects")
EndEvent