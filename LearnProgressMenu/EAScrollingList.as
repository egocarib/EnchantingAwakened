class EAScrollingList extends MovieClip
{
	public var Entries:Array;

	public var TestStrings:Array = new Array(
		"Aether: Absorb Magicka",
		"Aether: Shock Damage",
		"Chaos: Chaos Damage",
		"Chaos: Fiery Soul Trap",
		"Chaos: Fire Damage",
		"Corpus: Paralysis",
		"Corpus: Stamina Damage",
		"Aether: Resist Magic",
		"Aether: Fortify Illusion",
		"Aether: Fortify Conjuration & Magicka Regen",
		"Chaos: Resist Fire",
		"Corpus: Fortify Carry",
		"Corpus: Fortify Smithing",
		"Corpus: Resist Disease",
		"Corpus: Resist Frost",
		"Corpus: Waterbreathing");                                // <------ DEBUG STRINGS

	public var TestFloats:Array = new Array();

	public var scrollMonitor:Object;

	public var _scrollbarTrack:MovieClip;
	public var _scrollbarUp:MovieClip;
	public var _scrollbarDown:MovieClip;
	public var _scrollbarButton:MovieClip;

	//CONSTANTS
	private var TOTAL_ENTRIES    = 0; //set by constructor
	private var SCROLL_MAX       = 0; //set by constructor
	private var ENTRY_HEIGHT     = 40; //ScrollingListEntry height + 2p buffer
	private var SHOWABLE_ENTRIES = 12;
	private var MODE_NAVIGATION  = 0;
	private var MODE_TEXTINPUT   = 1;

	private var _currentMode   = MODE_NAVIGATION;
	private var _selectedIndex = -1;
	private var _scrollIndex   = 0;

	function EAScrollingList()
	{
		super();

		Mouse.addListener(this);

		//Init Scrollbar
		_scrollbarTrack                   = _root._scrollbarTrack;
		_scrollbarUp                      = _root._scrollbarUp;
		_scrollbarDown                    = _root._scrollbarDown;
		_scrollbarButton                  = _root._scrollbarButton;
		_scrollbarButton.onPress          = OnScrollbarButtonDrag;
		_scrollbarButton.onRelease        = OnScrollbarButtonRelease;
		_scrollbarButton.onReleaseOutside = OnScrollbarButtonRelease;
		_scrollbarUp.onPress              = OnScrollbarUpPress;
		_scrollbarDown.onPress            = OnScrollbarDownPress;

		//Configure TextInput Styles
		with (_global.styles.TextInput)
		{
			setStyle("embedFonts", true);
			setStyle("fontFamily", "$EverywhereFont");
			setStyle("fontSize", 23.0);
			setStyle("color", 0xFFFFFF);
			setStyle("borderStyle", "none");
			setStyle("textAlign", "center");
			setStyle("backgroundColor", undefined); //transparent
		}

		this.onEnterFrame = function()
		{
			LoadEntries();
			delete this.onEnterFrame;
			this.onEnterFrame = function()
			{
				PostLoadEntries();
				delete this.onEnterFrame;
			}
		}
	}

	function OnScrollbarButtonDrag()
	{
		if (_currentMode != MODE_NAVIGATION)
			return;

		var leftBound:Number = _root._scrollbarTrack._x;
		var rightBound:Number = _root._scrollbarTrack._x;
		var topBound:Number = _root._scrollbarTrack._y;
		var bottomBound:Number = _root._scrollbarTrack._y + _root._scrollbarTrack._height - _root._scrollbarButton._height;

		this.startDrag(false, leftBound, topBound, rightBound, bottomBound);

		scrollMonitor = new Object();
		scrollMonitor.onMouseMove = function()
		{
			var moveSlots:Number = _root._scrollingList.TOTAL_ENTRIES - _root._scrollingList.SHOWABLE_ENTRIES;
			if (moveSlots < 1)
				return;

			var moveRange = _root._scrollbarTrack._height - _root._scrollbarButton._height;
			var moveIncrement = moveRange / (moveSlots + 1);

			var buttonDistance = _root._scrollbarButton._y - _root._scrollbarTrack._y;
			var k = 0;
			while (buttonDistance > 0)
			{
				buttonDistance -= moveIncrement;
				if (buttonDistance >= 0)
					k++;
			}

			if (k > _root._scrollingList._scrollIndex)
			{
				_root._scrollingList._scrollIndex++;
				_root._scrollingList._y = _root._scrollingList._y - _root._scrollingList.ENTRY_HEIGHT;
			}
			if (k < _root._scrollingList._scrollIndex)
			{
				_root._scrollingList._scrollIndex--;
				_root._scrollingList._y = _root._scrollingList._y + _root._scrollingList.ENTRY_HEIGHT;
			}
		}

		Mouse.addListener(scrollMonitor);
	}

	function OnScrollbarButtonRelease()
	{
		this.stopDrag();
		Mouse.removeListener(scrollMonitor);
		delete scrollMonitor;
		_root._scrollingList.SnapScrollbarButtonToTrack();
	}

	function OnScrollbarUpPress()
	{
		_root._scrollingList.onMouseWheel(1);
	}

	function OnScrollbarDownPress()
	{
		_root._scrollingList.onMouseWheel(-1);
	}

	function SnapScrollbarButtonToTrack()
	{
		//update scrollbar
		var moveSlots:Number     = TOTAL_ENTRIES - SHOWABLE_ENTRIES;
		var moveRange:Number     = _scrollbarTrack._height - _scrollbarButton._height;
		var drawIncrement:Number = moveRange / moveSlots;
		_scrollbarButton._y      = _scrollbarTrack._y + (drawIncrement * _scrollIndex);
	}

	function onMouseWheel(delta:Number):Void
	{
		if (delta < 0)
		{
			if (_scrollIndex >= SCROLL_MAX)
				return;
			_scrollIndex++;
		}
		else if (delta > 0)
		{
			if (_scrollIndex <= 0)
				return;
			_scrollIndex--;
		}

		delta /= Math.abs(delta);
		this._y = this._y + (delta * ENTRY_HEIGHT);

		SnapScrollbarButtonToTrack();
	}

	function LoadEntries()
	{
		//paramaters that will be passed to this, eventually
		//  enchantment name Strings (use TestStrings for now)
		//  learn % floats
		TestFloats = new Array();
		for (var i = 0; i < TestStrings.length; i++)
			TestFloats[i] = Math.floor(Math.random() * (101)); //rand 0-100 for now, just to test

		Entries = new Array();
		var yAnchor:Number = 0;
		var yBuffer:Number = 2;

		for (var h = 0; h < TestStrings.length; h++)
		{
			Entries[h] = this.attachMovie("ScrollingListEntry", "_scrollSlot" + h, this.getNextHighestDepth());
			Entries[h]._y = yAnchor;
			yAnchor += Entries[h]._height + yBuffer;
			Entries[h].attachMovie("ListEntry", "entry", this.getNextHighestDepth());
			skse.SendModEvent("EVENT_test", "", 0, 0);
		}

		TOTAL_ENTRIES = TestStrings.length;
		SCROLL_MAX = Math.max(TOTAL_ENTRIES - SHOWABLE_ENTRIES, 0);

		SetMode(MODE_NAVIGATION);
	}

	function PostLoadEntries()
	{
		var i:Number = TOTAL_ENTRIES;
		while (i > 0)
		{
			i--;
			Entries[i].entry._textLabel.text = TestStrings[i];
			Entries[i].entry.FillToPct(TestFloats[i], 0);
		}
	}

	function SetMode(a_mode:Number)
	{
		if (a_mode == MODE_NAVIGATION)
		{
			_currentMode = MODE_NAVIGATION;
			for (var i = 0; i < TOTAL_ENTRIES; i++)
			{
				Entries[i].onRollOver = Entries[i].OnMouseRollover;
				Entries[i].onRollOut  = Entries[i].OnMouseRollout;
				Entries[i].onPress    = Entries[i].OnMousePress;
			}
			skse.AllowTextInput(false);
			Mouse.addListener(this);
		}
		else if (a_mode == MODE_TEXTINPUT)
		{
			_currentMode = MODE_TEXTINPUT;
			for (var i = 0; i < TOTAL_ENTRIES; i++)
			{
				delete Entries[i].onRollOver;
				delete Entries[i].onRollOut;
			}
			delete Entries[_selectedIndex].onPress; //disable mouse in text input region
			skse.AllowTextInput(true);
			Mouse.removeListener(this);
		}
	}

	function ReleaseFocus()
	{
		if (_currentMode != MODE_NAVIGATION)
		{
			this.SetMode(MODE_NAVIGATION);
			for (var i = 0; i < TOTAL_ENTRIES; i++)
			{
				if (Entries[i].hitTest(_root._xmouse, _root._ymouse))
				{
					Entries[i].highlightEntry();
					break;
				}
			}
		}
	}

	function SecureFocus()
	{
		if (_currentMode != MODE_TEXTINPUT)
			this.SetMode(MODE_TEXTINPUT);
	}

	function InterruptFocus(a_source:MovieClip)
	{
		if (_currentMode == MODE_TEXTINPUT)
		{
			Entries[_selectedIndex].StopTextInput();
			SetSelection(a_source);
			Entries[_selectedIndex].highlightEntry();
			this.SetMode(MODE_NAVIGATION);
		}
	}

	function SetSelection(a_entry:MovieClip):Void
	{
		for(var i = 0; i < TOTAL_ENTRIES; i++)
		{
			if (Entries[i] == a_entry)
			{
				_selectedIndex = i;
				return;
			}
		}
		_selectedIndex = -1;
	}
}