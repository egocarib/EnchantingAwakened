Scriptname EA_LeveledListSoulGemsScript extends Quest

;simple script to fill items into various leveledItem lists


;PROPERTIES -------------------------------------->
  LeveledItem property LItemMiscVendorSoulGemEmpty auto
  Form property SoulGemPettyFilled auto
  Form property SoulGemLesserFilled auto
  Form property SoulGemCommonFilled auto
  Form property SoulGemGreaterFilled auto

  LeveledItem property LItemMiscVendorSoulGem75 auto
  LeveledItem property LItemSpellVendorSoulGem75 auto
  LeveledItem property LItemMiscVendorSoulGemFull auto

  bool listsAdded

Function ModifyGemLists()
  if !listsAdded
    LItemMiscVendorSoulGem75.addForm(LItemMiscVendorSoulGemEmpty, 1, 14)
    LItemSpellVendorSoulGem75.addForm(LItemMiscVendorSoulGemEmpty, 1, 8)
    LItemMiscVendorSoulGemFull.addForm(SoulGemPettyFilled, 1, 1)
    LItemMiscVendorSoulGemFull.addForm(SoulGemLesserFilled, 1, 1)
    LItemMiscVendorSoulGemFull.addForm(SoulGemCommonFilled, 1, 1)
    LItemMiscVendorSoulGemFull.addForm(SoulGemGreaterFilled, 1, 1)
    listsAdded = true
  endif
EndFunction