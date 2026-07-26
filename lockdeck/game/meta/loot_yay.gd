extends Control
## This is the loot distribution scene

signal continue_to_next

func _ready() -> void:
	$ContinueButton.pressed.connect(continue_to_next.emit)