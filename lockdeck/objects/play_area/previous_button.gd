extends Control

signal show_previous()
signal go_back()

@export var show_see_prev := true:
	set(v):
		show_see_prev = v
		$ViewMoreButton.visible = show_see_prev
		$GoBackButton.visible = not show_see_prev

@export var disable := false:
	set(v):
		disable = v
		$ViewMoreButton.disabled = v
		$GoBackButton.disabled = v
		
		var font_color := Color("FFFFFF")
		if disable:
			font_color = Color("#918891")

		$ViewMoreButton/Label.add_theme_color_override("font_color", font_color)
		$GoBackButton/Label.add_theme_color_override("font_color", font_color)

func _ready() -> void:
	$ViewMoreButton.pressed.connect(show_previous.emit)
	$GoBackButton.pressed.connect(go_back.emit)
