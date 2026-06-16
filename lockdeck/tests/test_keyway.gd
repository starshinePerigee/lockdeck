extends Node2D

func act(i: int) -> void:
	print("activated %s" % i)

func _ready() -> void:
	$Keyway.space_activated.connect(act)
	$Keyway.space_count = 4
	$CardSpace.card_dropped.connect($Keyway.check_drop)
