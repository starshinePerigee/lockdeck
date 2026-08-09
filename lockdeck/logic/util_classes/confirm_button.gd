extends Button
## This is a button that requires two presses, and has a Highlight child node
class_name ConfirmButton

signal pressed_confirmed

@export var base_text := "Continue >":
	set(v):
		base_text = v
		text = base_text

@export var confirm_text := "Continue ->"

func set_highlight(highlighted: bool) -> void:
	if highlighted:
		var s: int = get_theme_constant("outline_size")
		add_theme_constant_override("outline_size", s * 2)
		add_theme_color_override("font_outline_color", Color("e3773d"))
		text = confirm_text
	else:
		remove_theme_constant_override("outline_size")
		remove_theme_color_override("font_outline_color")
		text = base_text

var highlight := false:
	set(v):
		highlight = v
		set_highlight(highlight)

func _pressed():
	if highlight:
		highlight = false
		pressed_confirmed.emit()
	else:
		highlight = true

func unconfirm():
	highlight = false

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		if not get_global_rect().has_point(event.global_position):
			unconfirm()

func _ready() -> void:
	text = base_text