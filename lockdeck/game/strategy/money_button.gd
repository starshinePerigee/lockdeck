extends MarginContainer
## This acts as a combination of three button types: CardButton, ConfirmButton, 
## and TextureButtonWithLabel. 
class_name MoneyButton

signal pressed_confirmed

@export var card: CardSpec:
	set(v):
		card = v
		%CardButton.set_card_spec(card)

@export var label := "MONDY BTN":
	set(v):
		label = v
		%Label.text = label

@export var confirm_label := "MONDY BTN?"

@export var disabled := false:
	set(v):
		disabled = v
		
		if not is_node_ready():
			return
		
		%CardButton.disabled = v
		
		if _mouse_over:
			_do_hover()
		else:
			_end_hover()

## indicates if this is a removal action (and you should show the X for confirm)
## or a normal action (and you should only highlight the label for confirm)
@export var removal := false

var _confirm := false:
	set(v):
		_confirm = v
		
		if not is_node_ready():
			return
		
		if removal:
			%RemovalHighlight.visible = _confirm
		
		if _confirm:
			%Label.text = confirm_label
			TooltipManager.request_tooltip_close()
		else:
			%Label.text = label

func _unconfirm() -> void:
	_confirm = false

func _pressed():
	if _confirm:
		_confirm = false
		pressed_confirmed.emit()
	else:
		_confirm = true


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

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		if not %CardButton.get_global_rect().has_point(event.global_position):
			_unconfirm()

func _ready() -> void:
	# effectively a redraw:
	%CardButton.disabled = disabled
	_end_hover()
	
	%CardButton.pressed.connect(_pressed)
	%CardButton.mouse_entered.connect(_do_hover)
	%CardButton.mouse_exited.connect(_end_hover)
	%CardButton.button_down.connect(_do_press)
	%CardButton.button_up.connect(_end_press)

const SELF_PACKED := preload("res://game/strategy/money_button.tscn")

static func build_from_spec(
	card_: CardSpec,
	label_: String,
	removal_: bool = false
) -> MoneyButton:
	var new_button := SELF_PACKED.instantiate()
	new_button.card = card_
	new_button.label = label_
	new_button.removal = removal_
	return new_button
