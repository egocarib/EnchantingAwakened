Scriptname EA_Learn_FortifyLockpicking extends EA_Learn_TemplateAME

int locksPicked

Event OnMenuOpen(string menu)
	locksPicked = Game.QueryStat("Locks Picked")
EndEvent

Event OnMenuClose(string menu)
    if (Game.QueryStat("Locks Picked") > locksPicked)
    	learnManager.LearnLockpicking()
    endif
EndEvent

Event OnInit()
    RegisterForMenu("Lockpicking Menu")
EndEvent

Event OnPlayerLoadGame()
    RegisterForMenu("Lockpicking Menu")
EndEvent