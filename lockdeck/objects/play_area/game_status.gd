extends Control

@export var stage: int:
	set(v):
		stage = v
		$VBoxContainer/LockCount.text = "Lock: %s" % stage

@export var picks: int:
	set(v):
		picks = v
		$VBoxContainer/PickCount.text = "Picks: %s" % picks

@export var coins: int:
	set(v):
		coins = v
		# $VBoxContainer/CoinCount.text = "Coins: %s" % coins

func _ready() -> void:
	stage = 0
	picks = 0
	coins = 0