extends PanelContainer

func hide_and_close() -> void:
	visible = false
	get_parent().remove_child(self)
	queue_free()

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		if not get_global_rect().has_point(event.global_position):
			hide_and_close()

func _ready() -> void:
	$MarginContainer/VBoxContainer/Button.pressed.connect(hide_and_close)