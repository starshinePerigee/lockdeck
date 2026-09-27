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

var stage: Stages
## How many pins to generate
var pin_count: int
## How difficult a lock to generate
var difficulty: int
## How much loot to generate
var loot: int
## The next lockset deck to load
var arc: LockDeck.GameArcs
## tutorial level
var tutorial_level: int
var lock: LockSpec
var cards: AllCardsSpec

## Note that this is a very polymorphic init
## It's best to just look at the case statement for this function
func _init(
	stage_: Stages,
	count_: int = 0,
	difficulty_: int = 0,
	lock_: LockSpec = null,
	cards_: AllCardsSpec = null,
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
			lock = lock_
			cards = cards_
		Stages.SPECIFIC:
			lock = lock_
			cards = cards_
