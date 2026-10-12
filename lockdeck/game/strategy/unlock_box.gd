extends PanelContainer

signal box_clicked

const DEFAULT_X := int((960 - 384) / 2.0)
const DEFAULT_Y := 146

const FX_SCRAPE := preload("res://assets/fx/card_scrape.ogg")
const FX_CLICK := preload("res://assets/fx/shell_click.ogg")

func show_depth_unlock(
	depth: Depths
) -> void:
	%Splash.text = "New Depth Unlocked!"
	%DepthInfo.visible = true
	%DepthInfo.depth = depth
	%Label.text = depth.description
	print("HIT")
	_finish_unlock()

func show_deck_unlock(
	deck_name: String,
	description: String
) -> void:
	%Splash.text = "New Deck Unlocked!"
	%DepthInfo.visible = false
	%DepthInfo.depth = Depths.DEBUG
	%Label.text = description
	_finish_unlock()

func _finish_unlock() -> void:
	GlobalEffects.request(FX_SCRAPE)
	position = Vector2(DEFAULT_X, DEFAULT_Y)
	visible = true
	size = Vector2.ZERO
	_color_label(NORMAL)
	

const NORMAL := Color("09090f")
const HOVERED := Color("853550")
const PRESSED := Color("bd4844")
const LOCKED := Color("312836")

func _color_label(color: Color) -> void:
	%Continue.add_theme_color_override("font_color", color)

func _do_hover() -> void:
	_color_label(HOVERED)

func _end_hover() -> void:
	_color_label(NORMAL)

func _do_press() -> void:
	_color_label(PRESSED)

func _end_press() -> void:
	close()
	GlobalEffects.request(FX_CLICK)

func close() -> void:
	if visible:
		hide()
		box_clicked.emit()

func _input(event: InputEvent) -> void:
	if (
		visible
		and event is InputEventMouseButton
		and (event.button_index == MOUSE_BUTTON_LEFT or event.button_index == MOUSE_BUTTON_RIGHT)
		and get_global_rect().has_point(event.global_position)
	):
		if event.pressed:
			_do_press()
		else:
			_end_press()

func _ready() -> void:
	mouse_entered.connect(_do_hover)
	mouse_exited.connect(_end_hover)
	
	if get_tree().current_scene == self:
		show_depth_unlock(Depths.SURPRISE)