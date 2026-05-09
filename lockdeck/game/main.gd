extends Control

var current_cylinders = 1
var tutorial := true

func do_tutorial():
	tutorial = not tutorial
	$Tutorial.visible = tutorial

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
	$TutorialButton.pressed.connect(do_tutorial)
	$GameCore.game_win.connect(clear_level)
	$NextLevelButton.pressed.connect(next_level)
