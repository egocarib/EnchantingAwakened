/**
 * ...
 * @author egocarib
 */
 
class MenuBladeMonitor extends MovieClip
{
	/* Filter Flags */
	static var WEAPON_BASIC              :Number = 1;  //Item submenu
	static var WEAPON_ENCHANTED          :Number = 2;  //Disenchant submenu
	static var ARMOR_BASIC               :Number = 4;  //Item submenu
	static var ARMOR_ENCHANTED           :Number = 8;  //Disenchant submenu
	static var ENCHANTMENT_EFFECT_WEAPON :Number = 16; //Enchantment submenu
	static var ENCHANTMENT_EFFECT_ARMOR  :Number = 32; //Enchantment submenu
	static var SOUL_GEM                  :Number = 64; //Soul Gem submenu

	/* Menu Elements */
	public var _craftRoot :MovieClip;
	public var _craftMenu :MovieClip;
	public var _itemCard  :MovieClip;

	/* Local Data */
	private var _noDisenchantNames   :Object  = new Object();
	private var _bDisablerInvalidate :Boolean = false;
	private var _currentFilterFocus  :Number  = 0;


	/* Public */
	public function MenuBladeMonitor(craftRoot:MovieClip) 
	{
		_craftRoot = craftRoot;
		_craftMenu = craftRoot.InventoryLists;
		_itemCard = craftRoot.ItemInfo;
		
	    _craftMenu.addEventListener("showItemsList", this, "OnMenuBladeOpen");
		_itemCard.addEventListener("subMenuAction", this, "OnSubMenuAction");
		_craftMenu.addEventListener("categoryChange", this, "OnCategoryChange");
	}

	public function RegisterDisallowedItems(): Void //@Papyrus
	{
		for (var i = 0; (i < arguments.length && arguments[i] != ""); i++)
			_noDisenchantNames[String(arguments[i])] = 1;
	}


	/* Private */
	private var EntryInhibitor:Function = function(prop, oldVal, newVal)
	{
		return false;
	}

	private function DisableDisallowedItems(): Void
	{
		if (_bDisablerInvalidate) //Prevent recursion when we InvalidateListData() from this function
		{
			_bDisablerInvalidate = false;
			return;
		}

		var entries:Array = _craftMenu.ItemsList.entryList;
		for (var i:Number = 0; i < entries.length; i++)
		{
			if (_noDisenchantNames[entries[i].text] == 1 &&
			(entries[i].filterFlag == WEAPON_ENCHANTED || entries[i].filterFlag == ARMOR_ENCHANTED))
			{
				entries[i].enabled = false;
				entries[i].watch("enabled", EntryInhibitor);
			}
		}
		
		_bDisablerInvalidate = true;
		_craftMenu.InvalidateListData();
	}

	private function OnMenuBladeOpen(event:Object): Void
	{
		_craftMenu.removeEventListener("showItemsList", this, "OnMenuBladeOpen");
		_craftMenu.addEventListener("hideItemsList", this, "OnMenuBladeClose");
		
		_craftMenu.addEventListener("itemHighlightChange", this, "OnEntryFocus");
		_craftMenu.ItemsList.addEventListener("itemPress", this, "OnEntrySelect");
		OnEntryFocus(event); //Send manually when blade first opens
	}

	private function OnMenuBladeClose(event:Object): Void
	{
		_craftMenu.removeEventListener("hideItemsList", this, "OnMenuBladeClose");
		_craftMenu.addEventListener("showItemsList", this, "OnMenuBladeOpen");
		
		_craftMenu.removeEventListener("itemHighlightChange", this, "OnEntryFocus");
		_craftMenu.ItemsList.removeEventListener("itemPress", this, "OnEntrySelect");
	}
	
	private function OnCategoryChange(event:Object): Void
	{
		DisableDisallowedItems();
	}
	
	private function OnEntryFocus(event:Object): Void
	{		
		if (event.index == -1)
			return;

		var thisEntry:Object = _craftMenu.ItemsList.selectedEntry;
		var disenchantMenu:Boolean = (thisEntry.filterFlag == WEAPON_ENCHANTED || thisEntry.filterFlag == ARMOR_ENCHANTED);

		if (_currentFilterFocus != thisEntry.filterFlag)
		{
			_currentFilterFocus = thisEntry.filterFlag;
			skse.SendModEvent("EA_OnMenuFocusTypeChange", thisEntry.text, thisEntry.filterFlag, 0);
		}

		if (disenchantMenu)
			DisableDisallowedItems();

		if (disenchantMenu && _noDisenchantNames[thisEntry.text] == 1)
			//Remove native event listener for disallowed items:
			_craftMenu.ItemsList.removeEventListener("itemPress", _craftRoot, "OnItemSelect");
		else
			_craftMenu.ItemsList.addEventListener("itemPress", _craftRoot, "OnItemSelect");
	}


	private function OnEntrySelect(event:Object): Void
	{
		if (_noDisenchantNames[_craftMenu.ItemsList.selectedEntry.text] == 1)
			skse.SendModEvent("EA_OnDisallowedItemSelect", _craftMenu.ItemsList.selectedEntry.text, 0, 0);
	}

	
	public function OnSubMenuAction(event: Object): Void //slider etc
	{
		// if ((event.menu == "quantity") && (event.opening == true))
		// 		_root.Menu.ItemInfo.addEventListener("sliderChange", this, "OnSliderChange");
	}

	// public function OnSliderChange(event: Object): Void
	// {
	// 	skse.Log("\n\nSLIDER CHANGE   [QuantitySlider_mc.value == " + _root.Menu.ItemInfo.QuantitySlider_mc.value + "]\n");
	// 	skse.Log("_root.Menu.ItemInfo.EnchantmentLabel.text  ==  " + _root.Menu.ItemInfo.EnchantmentLabel.text);
	// }
}
