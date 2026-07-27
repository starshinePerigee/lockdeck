extends Control
## This scene represents a single game and manages the transition between scenes

@export var difficulty := 0
@export var current_deck: Array[CardSpec] = []
@export var broken_picks: Array[CardSpec] = []

func begin_new_game(starter_deck: Array[CardSpec]) -> void:
	difficulty = 0
	current_deck = starter_deck
	$AnimationPlayer.play("first lock")

func lock_complete():
	$AnimationPlayer.play("lock to between")
	var broken: Array[CardSpec] = $GameCore/TrashMain.cards
	for broke in broken:
		if broke in current_deck:
			current_deck.erase(broke)
		else:
			push_warning(
				"Could not find broken pick %s (%s) in deck record!" 
				% [broke.pick_name, broke.unique_id]
			)
	broken_picks.append_array(broken)

func next_lock():
	difficulty += 1
	$GameCore/GameStatus.stage = difficulty
	$GameCore.cylinder_count = min(difficulty, 5)
	$GameCore.difficulty_mod = max(difficulty - 6, 0)
	$GameCore.load_deck(current_deck.duplicate())
	$GameCore/TrashMain.reset()
	$GameCore.restart()
	$GameCore/GameStatus.coins = 0
	$AnimationPlayer.play("between to lock")

func _ready() -> void:
	global_position = Vector2(0, 0)
	$BetweenLocks.continue_to_next.connect(next_lock)
	$GameCore.continue_to_next.connect(lock_complete)
