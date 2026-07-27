extends Control
## This is a popover to manage settings

signal closed()

var _button_holder: VBoxContainer
var _button_table: Dictionary[String, Button] = {}

func call_callable(callable: Callable, close_after: bool):
	callable.call()
	if close_after:
		hide_widget()

## Adds a button to the settings menu that calls a callback when pushed.
func add_button(button_text: String, callable: Callable, close_after: bool = false) -> void:
	if button_text in _button_table.keys():
		push_warning("Button already in settings: %s" % button_text)
		return
	
	var button := Button.new()
	_button_table[button_text] = button
	
	button.text = button_text
	button.pressed.connect(call_callable.bind(callable.call, close_after))
	_button_holder.add_child(button)

func remove_button(button_text: String) -> void:
	if not button_text in _button_table.keys():
		push_warning("Button not in settings: %s" % button_text)
		return
	
	var button := _button_table[button_text]
	_button_holder.remove_child(button)
	_button_table.erase(button_text)
	button.queue_free()

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
	_button_holder = $Panel/VBoxContainer/MarginContainer/ButtonHolder
	gui_input.connect(_handle_input)
	global_position = Vector2(0, 0)
	visible = false

	if get_parent() == get_tree().root:
		show_widget()
