extends Control
## This scene represents a single game and manages the transition between scenes

var game: GameSpec

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
	game = GameSpec.new()
	game.current_deck = starter_deck
	current_state = GameState.BETWEEN_LOCK
	$BetweenLocks/SpeedBonusLabel.visible = false
	$AnimationPlayer.play("first lock")

func lock_complete():
	game.break_picks($GameCore/TrashMain.cards)
	current_state = GameState.BETWEEN_LOCK
	if $GameCore/LockBody/CountdownMain.count >= 2:
		game.coins += 5
		$BetweenLocks/SpeedBonusLabel.visible = true
	else:
		$BetweenLocks/SpeedBonusLabel.visible = false
	$AnimationPlayer.play("lock to between")

func next_lock() -> void:
	if _check_state(GameState.BETWEEN_LOCK):
		return

	game.complete_lock()
	
	$GameCore.load_lock(LockGenerator.get_next_level(game.difficulty))
	$GameCore.load_game(game)
	
	current_state = GameState.CORE_GAME
	$AnimationPlayer.play("between to lock")

## Abandon the current game. Call begin_new_game after
func abort_and_reset() -> void:
	current_state = GameState.INVALID
	$AnimationPlayer.play("RESET")

func _ready() -> void:
	global_position = Vector2(0, 0)
	$BetweenLocks.continue_to_next.connect(next_lock)
	$GameCore.continue_to_next.connect(lock_complete)
