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

;debug
Function DumpEnchantedWeaponValues() global native