extends MarginContainer
## This acts as a combination of three button types: CardButton, ConfirmButton, 
## and TextureButtonWithLabel. 

@export var card: CardSpec:
	set(v):
		card = v
		%CardButton.set_card_spec(card)

@export var label := "MONDY BOTTON":
	set(v):
		%Label.text = label

@export var disabled := false:
	set(v):
		disabled = v
		%CardButton.disabled = v
		
		if _mouse_over:
			_do_hover()
		else:
			_end_hover()

const NORMAL := Color("ffffff")
const HOVERED := Color("ffbc57")
const PRESSED := Color("e3773d")
const DISABLED := Color("918891")
const DISABLED_HOVER := Color("bd4844")

var _mouse_over: bool = false

func _color_label(color: Color) -> void:
	if color == NORMAL:
		%Label.remove_theme_color_override("font_color")
	else:
		%Label.add_theme_color_override("font_color", color)

func _do_hover() -> void:
	_mouse_over = true
	if disabled:
		_color_label(DISABLED_HOVER)
	else:
		_color_label(HOVERED)

func _end_hover() -> void:
	_mouse_over = false
	if disabled:
		_color_label(DISABLED)
	else:
		_color_label(NORMAL)

func _do_press() -> void:
	if not disabled:
		_color_label(PRESSED)

func _end_press() -> void:
	if _mouse_over:
		_do_hover()
	else:
		_color_label(NORMAL)

func _ready() -> void:
	%CardButton.mouse_entered.connect(_do_hover)
	%CardButton.mouse_exited.connect(_end_hover)
	%CardButton.button_down.connect(_do_press)
	%CardButton.button_up.connect(_end_press)
