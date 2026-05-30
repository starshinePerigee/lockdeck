extends Control

var current_cylinders = 1

func restart_level():
	current_cylinders = 1
	$GameCore.CYLINDER_COUNT = current_cylinders
	$GameCore.reset()

func clear_level():
	$NextLevelButton.disabled = false

func next_level():
	current_cylinders = min(5, current_cylinders + 1)
	$GameCore.CYLINDER_COUNT = current_cylinders
	$GameCore.reset()
	$NextLevelButton.disabled = true

func _ready():
	$RestartButton.pressed.connect(restart_level)
	$GameCore.game_win.connect(clear_level)
	$NextLevelButton.pressed.connect(next_level)
