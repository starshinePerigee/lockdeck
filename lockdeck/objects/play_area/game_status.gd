extends Control

@export var tutorial := false

@export var stage: int:
	set(v):
		stage = v
		$VBoxContainer/LockCount.text = "Lock: %s" % stage

@export var picks: int:
	set(v):
		picks = v
		if tutorial:
			$VBoxContainer/PickCount.text = "Tutorial"
		else:
			$VBoxContainer/PickCount.text = "Picks: %s" % picks

func _ready() -> void:
	stage = 0
	picks = 0