extends TextureButton

const NORMAL := Color("ffffff")
const HOVERED := Color("ffbc57")
const PRESSED := Color("e3773d")

func _color_label(color: Color) -> void:
	$Label.add_theme_color_override("font_color", color)

func _do_hover() -> void:
	_color_label(HOVERED)

func _end_hover() -> void:
	_color_label(NORMAL)

func _do_press() -> void:
	_color_label(PRESSED)

func _end_press() -> void:
	_color_label(HOVERED)

func _ready() -> void:
	mouse_entered.connect(_do_hover)
	mouse_exited.connect(_end_hover)
	button_down.connect(_do_press)
	button_up.connect(_end_press)
