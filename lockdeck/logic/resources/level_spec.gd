extends Resource
## This represents a single stage in the game
class_name LevelSpec

enum Stages {
	LOCK,
	LOOT_STRAT,
	VICTORY,
	TUTORIAL,
	SPECIFIC,
}

enum InterfaceSetup {
	DEFAULT,
	FULL_EMPTY,
	HALF_SHOWN
}

var stage: Stages
## How many pins to generate
var pin_count: int = 1
## How difficult a lock to generate
var difficulty: int = 0
## How much loot to generate
var loot: int = 0
## The next lockset deck to load
var arc: LockDeck.GameArcs
## tutorial level
var tutorial_level: int = 0
var state: StateSpec = null
var interface: InterfaceSetup = InterfaceSetup.DEFAULT

## Note that this is a very polymorphic init
## It's best to just look at the case statement for this function
func _init(
	stage_: Stages,
	count_: int = 0,
	difficulty_: int = 0,
	state_: StateSpec = null,
	interface_: InterfaceSetup = InterfaceSetup.DEFAULT
) -> void:
	stage = stage_
	
	match stage:
		Stages.LOCK:
			pin_count = count_
			difficulty = difficulty_
		Stages.LOOT_STRAT:
			loot = count_
			arc = difficulty_ as LockDeck.GameArcs
		Stages.VICTORY:
			pass
		Stages.TUTORIAL:
			tutorial_level = count_
			state = state_
			interface = interface_
		Stages.SPECIFIC:
			state = state_
			interface = interface_
