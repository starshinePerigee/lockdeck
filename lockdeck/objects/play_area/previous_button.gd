extends Control

signal show_previous()
signal go_back()

@export var show_see_prev := true:
	set(v):
		show_see_prev = v
		$ViewMoreButton.visible = show_see_prev
		$GoBackButton.visible = not show_see_prev

var _is_hovered := false

func set_hovered(hovered: bool) -> void:
	_is_hovered = hovered
	_redraw()

@export var disable := false:
	set(v):
		disable = v
		$ViewMoreButton.disabled = v
		$GoBackButton.disabled = v
		_redraw()

func _redraw() -> void:
	var font_color := Color("FFFFFF")
	if disable:
		font_color = Color("#918891")
#	elif _is_hovered:
#		font_color = Color("#f7ed7b")

	$ViewMoreButton/Label.add_theme_color_override("font_color", font_color)
	$GoBackButton/Label.add_theme_color_override("font_color", font_color)

func _ready() -> void:
	$ViewMoreButton.mouse_entered.connect(set_hovered.bind(true))
	$ViewMoreButton.mouse_exited.connect(set_hovered.bind(false))
	$ViewMoreButton.pressed.connect(show_previous.emit)
	
	$GoBackButton.mouse_entered.connect(set_hovered.bind(true))
	$GoBackButton.mouse_exited.connect(set_hovered.bind(false))
	$GoBackButton.pressed.connect(go_back.emit)
