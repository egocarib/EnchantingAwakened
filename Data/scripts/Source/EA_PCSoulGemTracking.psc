Scriptname EA_PCSoulGemTracking extends ReferenceAlias
{tracks player's empty soul gems}

Actor property playerRef auto

EA_SoulTrapQuestScript property STQ auto

SoulGem[] property AzurasStarVariants auto        ; [0]azurasStarPetty [1]azurasStarLesser [2]azurasStarCommon [3]azurasStarGreater [4]azurasStarGrand
SoulGem[] property emptyGemsBase      auto hidden ; [0]petty [1]lesser [2]common [3]greater [4]grand [5-9]azura's star (duplicates of vanilla empty)
int[]     property emptyGemsCount     auto hidden ; [0]petty [1]lesser [2]common [3]greater [4]grand [5]azura's star

int[]     property removeException auto hidden ; to indicate azura variant should not be replaced (soul trap script is handling it)


Event OnInit()
	RegisterForSingleUpdate(1.0)
EndEvent

Event OnPlayerLoadGame()
	STQ.resetMessageTimer()
EndEvent

Event OnUpdate()
	;link these arrays to the ones in SoulTrapQuest
	emptyGemsBase = STQ.emptyGemsBase
	emptyGemsCount = STQ.emptyGemsCount
	removeException = STQ.removeException

	int arrayIndex = 6
	while arrayIndex
		arrayIndex -= 1
		emptyGemsCount[arrayIndex] = playerRef.GetItemCount(emptyGemsBase[arrayIndex])
		AddInventoryEventFilter(emptyGemsBase[arrayIndex])
		AddInventoryEventFilter(AzurasStarVariants[arrayIndex])
	endWhile
	goToState("")
EndEvent


Event onItemAdded(Form akBaseItem, int aiItemCount, ObjectReference akItemReference, ObjectReference akSourceContainer)
	SoulGem addedGem = akBaseItem as SoulGem
	int indexCheck = emptyGemsBase.Find(addedGem)
	if indexCheck >= 0 ;empty gem
		emptyGemsCount[indexCheck] = emptyGemsCount[indexCheck] + aiItemCount
	else ;filled azuras star variant
		indexCheck = AzurasStarVariants.find(addedGem)
		int size = (indexCheck + 1) % 5
		STQ.currentAzurasStarSize = size ;resume tracking partially filled star in STQ
	endif
EndEvent


Event onItemRemoved(Form akBaseItem, int aiItemCount, ObjectReference akItemReference, ObjectReference akDestContainer)
	SoulGem removedGem = akBaseItem as SoulGem
	int indexCheck = emptyGemsBase.Find(removedGem)
	if indexCheck >= 0 ;empty gem
		emptyGemsCount[indexCheck] = emptyGemsCount[indexCheck] - aiItemCount
	else ; filled azura's star variant
		if (removeException[0] > 0)
			removeException[0] = removeException[0] - 1
		elseif (akDestContainer == none && akItemReference == none) ;consumed via enchanting
			playerRef.addItem(emptyGemsBase[5], 1, true) ;empty azura's star
			STQ.currentAzurasStarSize = 0 ;stop tracking partially filled star used in crafting
			STQ.currentAzurasStarCharge = 0 ;reset accumulated charge
		else
			STQ.currentAzurasStarSize = 0 ;stop tracking partially filled star moved out of inventory
		endif
	endif
EndEvent


Auto State uninitializedState
	Event onItemAdded(Form akBaseItem, int aiItemCount, ObjectReference akItemReference, ObjectReference akSourceContainer)
	EndEvent
	Event onItemRemoved(Form akBaseItem, int aiItemCount, ObjectReference akItemReference, ObjectReference akDestContainer)
	EndEvent
EndState