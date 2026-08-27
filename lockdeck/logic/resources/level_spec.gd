extends Resource
## This represents a single stage in the game
class_name LevelSpec

enum Stages {
	LOCK,
	LOOT_STRAT,
	VICTORY
}

var stage: Stages
var pin_count: int
var difficulty: int
var loot: int
var arc: LockDeck.GameArcs

func _init(
	stage_: Stages,
	count_: int = 0,
	difficulty_: int = 0,
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
