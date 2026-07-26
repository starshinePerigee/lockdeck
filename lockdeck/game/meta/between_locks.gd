extends Control
## This is a quick summary screen between locks on a heist

signal continue_to_next

# TODO:
# this should be pictoral representations, as you progress you unlock / open lock icons
# [ ] > [] > [BOSS] > loot

func _ready() -> void:
	$ContinueButton.pressed.connect(continue_to_next.emit)