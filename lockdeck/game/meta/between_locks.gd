extends Control
## This is a quick summary screen between locks on a heist

signal continue_to_next

# TODO:
# this should be pictoral representations, as you progress you unlock / open lock icons
# [ ] > [] > [BOSS] > loot

func first_animate() -> void:
	var timer := get_tree().create_timer(0.6)
	timer.timeout.connect(continue_to_next.emit)

func animate() -> void:
	var timer := get_tree().create_timer(0.4)
	timer.timeout.connect(continue_to_next.emit)

func _ready() -> void:
	pass
