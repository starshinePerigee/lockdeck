extends Control
## This is a popover that can dynamically add/remove buttons, used for the in-game menu

signal closed()
signal return_to_title

@export var title := ""

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
	%ButtonHolder.add_child(button)

func remove_button(button_text: String) -> void:
	if not button_text in _button_table.keys():
		push_warning("Button not in settings: %s" % button_text)
		return
	
	var button := _button_table[button_text]
	%ButtonHolder.remove_child(button)
	_button_table.erase(button_text)
	button.queue_free()

func show_widget():
	global_position = Vector2(0, 0)
	visible = true
	z_index = 1200

func hide_widget():
	visible = false
	closed.emit()

func do_return_to_title() -> void:
	return_to_title.emit()
	hide_widget()

func _handle_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			hide_widget()

func _ready() -> void:
	%Title.text = title
	%ToTopMenuButton.pressed_confirmed.connect(do_return_to_title)
	gui_input.connect(_handle_input)
	visible = false

	if get_parent() == get_tree().root:
		show_widget()
