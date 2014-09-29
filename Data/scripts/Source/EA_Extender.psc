Scriptname EA_Extender Hidden

;filterFlags retrieved from swf menu hook
; int  property  WEAPON_BASIC               = 0x01  autoReadOnly
; int  property  WEAPON_ENCHANTED           = 0x02  autoReadOnly
; int  property  ARMOR_BASIC                = 0x04  autoReadOnly
; int  property  ARMOR_ENCHANTED            = 0x08  autoReadOnly
; int  property  ENCHANTMENT_EFFECT_WEAPON  = 0x10  autoReadOnly
; int  property  ENCHANTMENT_EFFECT_ARMOR   = 0x20  autoReadOnly
; int  property  SOUL_GEM                   = 0x40  autoReadOnly

;set num-th keyword on targForm to keyToSet
Function SetNthKeyword(Form targForm, int num, Keyword keyToSet) global native

;batch array operation -- set keyword at index num on all inputForms to the new keyToSet
Function SetFormArrayNthKeyword(Form[] inputForms, int num, Keyword keyToSet) global native

;batch array operation -- set keyword at index num on all inputForms to the corresponding keyword in keysToSet[]
Function SetFormArrayNthKeywordArray(Form[] inputForms, int num, Keyword[] keysToSet) global native

Function GetFormArrayNthKeywords(Form[] inputForms, int num, Keyword[] fillKeys) global native

;fills the arrays with all the enchanted weapon/armor forms in container, along with their associated enchantments. Exclude player enchants and/or items with MagicDisallowEnchanting keyword
bool Function GetEnchantedForms(ObjectReference container, Form[] fillForms, Enchantment[] fillEnchants,  bool excludePlayerEnchants = false, bool excludeDisallowEnchanting = false) global native

;checks if form (weapon or armor) is enchanted, and if so, returns 3-member array [item form, base enchantment, 0-index keyword]
bool Function CheckFormForEnchantment(Form checkForm, Form[] returnParams) global native

;puts the name of inputForms into fillStrings. Function terminates upon finding a null form.
Function GetFormNames(Form[] inputForms, string[] fillStrings) global native

;returns whether the spell is associated with this school of magic or not
bool Function IsSpellSkillType(Spell checkSpell, string magicSchool) global native

;returns associated school of spell. Returns null string if no association, or if used on a spell that's not "Spell" type (like Voice, Ability, or Disease)
string Function GetSpellSkillString(Spell checkSpell) global native

;returns 0-4, corresponding alphabetically to Alteration-Restoration, or -1 if invalid or no type
int Function GetSpellSkillNumber(Spell checkSpell) global native

;adds each magic effect from ench into outputMGEFs array, and returns the number that were added
int Function GetEnchantmentMagicEffects(Enchantment ench, MagicEffect[] outputMGEFs) global native

;NOT CURRENTLY USED
; int Function GetPlayerKnownEnchantments(Enchantment[] outputKnown) global native

;returns event name string that must be registered for (via RegisterForModEvent) in order to receive learn events from internal plugin
string Function GetLearnEventName() global native
;format looks something like this:
;   RegisterForModEvent(EA_Extender.GetLearnEventName(), "OnLearnAdvance")
;   ...
;   Event OnLearnAdvance(string eventName, string nullArg, float newExperienceTotal, Form learnedEnchantment)
;
;   this event will be sent from internal plugin roughly every 50 weapon enchantment hits (and thus, newExperienceTotal will be a multiple of 50)

;same as above but returns event name for the armor enchantment equip/unequip event
string Function GetArmorEnchantmentEquipEventName() global native


;adds to formlist all loaded enchantments that have any member of baseEnchantments as their base enchantment.
;will just add new things to the formlist, so empty/revert formlist before calling if necessary.
Function FillFormlistWithChildrenOfBaseEnchantments(Formlist listToFill, Enchantment[] baseEnchantments, bool stopAtFirstNullEntry = true) global native

;as above, but input from a formlist of base enchantments instead
Function FillFormlistWithChildrenOfBaseEnchantmentsList(Formlist listToFill, Formlist baseEnchantments) global native

;modifies entry point at epIndex for each perksToModify, replacing current value with corresponding newValues
Function SetPerkEntryValues(Perk[] perksToModify, float[] newValues, int epIndex = 0) global native

;sets the internal constant for offensive enchant learning (each hit with enchanted weapon will be worth this much "experience"
Function SetOffensiveEnchantmentLearnExperienceMult(float newMultiplier) global native

;set the learn thresholds. Each time a new threshold is met by offensive enchantment use, a new learn event will be sent
;from internal plugin for that enchantment. Ignores 0 value threshold(s), which are not recorded and won't trigger a learn event.
Function SetOffensiveEnchantmentLearnLevelThresholds(float[] thresholds) global native

; Function DumpSpellsAndEffects() global native

Function ApplyIniMultModifiers(float[] multsToModify) global native
	
Function GetIniPerkPowerVals(float[] perkBasePower, float[] perkMaxLearnPower) global native

;dump papyrus learning data. Pass armor enchant arrays and weapon enchant arrays to this function. Will output to EnchantingAwakenedExtender.log
Function DumpLearningData(Enchantment[] aEnchants, float[] aEnchantsXP, int[] aEnchantsLvl, Enchantment[] wEnchants, float[] wEnchantsXP, int[] wEnchantsLvl) global native