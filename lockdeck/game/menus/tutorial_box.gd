extends PanelContainer

signal box_clicked

const DEFAULT_X := int((960 - 384) / 2.0)
const DEFAULT_Y := 128

const FX_SCRAPE := preload("res://assets/fx/card_scrape.ogg")
const FX_CLICK := preload("res://assets/fx/shell_click.ogg")

var can_continue := false

func show_box(
	text: String,
	origin_x: int = -1,
	origin_y: int = -1,
	continuable := true
):
	if origin_x == -1:
		origin_x = DEFAULT_X
	if origin_y == -1:
		origin_y = DEFAULT_Y
	
	GlobalEffects.request(FX_SCRAPE)
	%Label.text = text
	global_position = Vector2(origin_x, origin_y)
	visible = true
	size = Vector2.ZERO
	
	can_continue = continuable
	if continuable:
		%Continue.text = "Click to continue"
		_color_label(NORMAL)
	else:
		%Continue.text = "Complete task to continue"
		_color_label(LOCKED)

const NORMAL := Color("09090f")
const HOVERED := Color("853550")
const PRESSED := Color("bd4844")
const LOCKED := Color("312836")

func _color_label(color: Color) -> void:
	%Continue.add_theme_color_override("font_color", color)

func _do_hover() -> void:
	if can_continue:
		_color_label(HOVERED)

func _end_hover() -> void:
	if can_continue:
		_color_label(NORMAL)

func _do_press() -> void:
	_color_label(PRESSED)

func _end_press() -> void:
	_do_hover()
	box_clicked.emit()
	GlobalEffects.request(FX_CLICK)

func _input(event: InputEvent) -> void:
	if (
		visible
		and can_continue
		and event is InputEventMouseButton
		and event.button_index == MOUSE_BUTTON_LEFT
		and get_global_rect().has_point(event.global_position)
	):
		if event.pressed:
			_do_press()
		else:
			_end_press()

func _ready() -> void:
	mouse_entered.connect(_do_hover)
	mouse_exited.connect(_end_hover)
