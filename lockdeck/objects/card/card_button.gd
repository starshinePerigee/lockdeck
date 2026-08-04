extends Button
## A pressable Button that shows a live pick card
class_name CardButton

const NORMAL: Texture2D = preload("res://assets/card/card_bg.png")
const HOVERED: Texture2D = preload("res://assets/card/card_bg_hover.png")
const PRESSED: Texture2D = preload("res://assets/card/card_bg_pressed.png")

var _mouse_over: bool = false

func _do_hover() -> void:
	_mouse_over = true
	$PickCard.position = Vector2(0, -4)
	$PickCard.set_art(HOVERED)

func _end_hover() -> void:
	_mouse_over = false
	$PickCard.position = Vector2(0, 0)
	$PickCard.set_art(NORMAL)

func _do_press() -> void:
	$PickCard.position = Vector2(0, -2)
	$PickCard.set_art(PRESSED)

func _end_press() -> void:
	if _mouse_over:
		_do_hover()
	else:
		_end_hover()

func set_card_spec(spec: CardSpec) -> void:
	$PickCard.card_spec = spec

func _ready() -> void:
	mouse_entered.connect(_do_hover)
	mouse_exited.connect(_end_hover)
	button_down.connect(_do_press)
	button_up.connect(_end_press)

const SELF_SCENE := preload("res://objects/card/card_button.tscn")

static func build_from_spec(spec: CardSpec) -> CardButton:
	var button := SELF_SCENE.instantiate()
	button.set_card_spec(spec)
	return button
