extends Control
## This is a popover to manage settings

signal closed()

func show_widget():
	visible = true
	z_index = 120

func hide_widget():
	visible = false
	closed.emit()


func _handle_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			hide_widget()

func _ready() -> void:
	gui_input.connect(_handle_input)
	global_position = Vector2(0, 0)
	visible = false

	if get_parent() == get_tree().root:
		show_widget()