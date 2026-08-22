extends TextureRect

signal clicked

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		if get_global_rect().has_point(event.global_position):
			clicked.emit()
