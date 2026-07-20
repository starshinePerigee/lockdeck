extends Control

var VERSION_NUMBER := "v0.5.1"

var difficulty := 0

func set_next_button_state(enabled: bool) -> void:
	$NextLevelButton.visible = enabled
	$NextLevelButton.disabled = not enabled

func restart_game() -> void:
	difficulty = 0
	$GameCore.load_starter_deck()
	start_next_level()

func start_next_level():
	$RestartButton/ColorRect.visible = false
	set_next_button_state(false)
	
	difficulty += 1
	$GameCore.cylinder_count = min(difficulty, 5)
	$GameCore.difficulty_mod = max(difficulty - 6, 0)
	$GameCore.restart()
	$GameCore.add_random_cards(2)
	$NextLevelButton.disabled = true

func show_win():
	set_next_button_state(true)

func show_fail():
	$RestartButton/ColorRect.visible = true

func _ready():
	$RestartButton.pressed.connect(restart_game)
	$GameCore.game_win.connect(show_win)
	$GameCore.game_fail.connect(show_fail)
	$GameCore.DEBUG_MODE = true
	$NextLevelButton.pressed.connect(start_next_level)
	restart_game()
	$Version.text = VERSION_NUMBER
