Scriptname EA_VersionCheck extends Quest

;maybe build this into maintenence script?

GlobalVariable property EA_ModSetupComplete auto
Message property EA_OldVersionError auto

Event OnInit()
  if EA_ModSetupComplete.getValue() > 0
    EA_OldVersionError.show()
  endif
EndEvent