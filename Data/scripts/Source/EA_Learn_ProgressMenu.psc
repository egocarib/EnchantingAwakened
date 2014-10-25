Scriptname EA_Learn_ProgressMenu extends ReferenceAlias

int property menuKey auto hidden

Event OnInit()
	menuKey = 38 ;'L' key
	OnPlayerLoadGame()
EndEvent

Event OnPlayerLoadGame()
	SetMenuKey(menuKey)
	SetEvents()
EndEvent

Function SetMenuKey(int newKey)
	UnregisterForAllKeys()
	RegisterForKey(menuKey)
EndFunction

Function SetEvents()
	RegisterForModEvent("EA_LearnMenuOpening", "OnEAMenuOpen")
	RegisterForModEvent("EA_LearnMenuClosing", "OnEAMenuClose")
EndFunction

State MenuOpen
	Event OnKeyDown(int keyPressed)
	EndEvent
EndState

Auto State MenuClosed
	Event OnKeyDown(int keyPressed)
		UI.OpenCustomMenu("EnchantingAwakened/LearnProgressMenu")
	EndEvent
EndState

;send events from flash (in case OpenCustomMenu should fail, don't want to change state here)
Event OnEAMenuOpen(string evnName, string strArg, float numArg, Form nullArg)
	GoToState("MenuOpen")
EndEvent

Event OnEAMenuClose(string evnName, string strArg, float numArg, Form nullArg)
	GoToState("MenuClosed")
EndEvent