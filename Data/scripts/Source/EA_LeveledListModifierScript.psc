Scriptname EA_LeveledListModifierScript extends Quest

;simple script to fill items into various leveledItem lists


;PROPERTIES -------------------------------------->
  Formlist      property EA_LevList_ItemToAdd auto
  LeveledItem[] property listToModify auto
   ;these two lists need be directly correlated so that the
   ;item form found in EA_LevList_ItemsToAdd(x) should be
   ;inserted into the Leveled List found in listsToModify[x]
  int[] property levelForItem auto
   ;this should also correlate, listing the level that each
   ;item should be associated with in its leveled item list


Event onInit()
	registerForSingleUpdate(20.0) ;allow more important stuff to process first
EndEvent


Event onUpdate()
	int index = listToModify.Length
	while index
		index -= 1
		listToModify[index].addForm(EA_LevList_ItemToAdd.getAt(index), levelForItem[index], 1)
	endWhile

  self.stop()
EndEvent
