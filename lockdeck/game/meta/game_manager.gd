extends Control
## This scene represents a single game and manages the transition between scenes

@export var difficulty := 0
@export var current_deck: Array[CardSpec] = []
@export var broken_picks: Array[CardSpec] = []

enum GameState {
	INVALID,
	BETWEEN_LOCK,
	CORE_GAME
}

var current_state := GameState.INVALID

func _check_state(desired_state: GameState) -> bool:
	if current_state == desired_state:
		return false
	else:
		push_warning(
			"Invalid state: %s, expected: %s" 
			% [
				GameState.keys()[current_state],
				GameState.keys()[desired_state]
			]
		)
		return true

func auto_complete_level() -> void:
	if _check_state(GameState.CORE_GAME):
		return
	
	$GameCore.solve_lock()

func break_three() -> void:
	if _check_state(GameState.CORE_GAME):
		return

	for __ in 3:
		$GameCore.break_from_hand()

func begin_new_game(starter_deck: Array[CardSpec]) -> void:
	difficulty = 0
	current_deck = starter_deck
	current_state = GameState.BETWEEN_LOCK
	$BetweenLocks/SpeedBonusLabel.visible = false
	$AnimationPlayer.play("first lock")

func lock_complete():
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
	current_state = GameState.BETWEEN_LOCK
	$BetweenLocks/SpeedBonusLabel.visible = $GameCore/LockBody/CountdownMain.count >= 2
	$AnimationPlayer.play("lock to between")

func next_lock() -> void:
	if _check_state(GameState.BETWEEN_LOCK):
		return

	difficulty += 1
	$GameCore/GameStatus.stage = difficulty
	$GameCore.cylinder_count = min(difficulty, 5)
	
	var lockset_deck := LockGenerator.get_lockset_deck(
		LockGenerator.GameArcs.MID,
		difficulty + 5,
		8
	)
	var lock_deck := LockGenerator.get_lock_deck(lockset_deck, difficulty + 2)
	var lock := LockGenerator.build_lock(lock_deck, $GameCore.cylinder_count, difficulty + 2) 
	$GameCore.load_lock(lock)
	
	$GameCore.load_deck(current_deck.duplicate())
	$GameCore/TrashMain.reset()
	$GameCore.restart()
	$GameCore/GameStatus.coins = 0
	
	current_state = GameState.CORE_GAME
	$AnimationPlayer.play("between to lock")

## Abandon the current game. Call begin_new_game after
func abort_and_reset() -> void:
	difficulty = 0
	current_deck = []
	broken_picks = []
	current_state = GameState.INVALID
	$AnimationPlayer.play("RESET")

func _ready() -> void:
	global_position = Vector2(0, 0)
	$BetweenLocks.continue_to_next.connect(next_lock)
	$GameCore.continue_to_next.connect(lock_complete)
