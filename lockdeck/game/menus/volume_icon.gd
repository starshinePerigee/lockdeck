extends TextureRect

signal clicked

func _input(event: InputEvent) -> void:
	if (
		is_visible_in_tree()
		and event is InputEventMouseButton
		and event.pressed
	):
		if get_global_rect().has_point(event.global_position):
			clicked.emit()
