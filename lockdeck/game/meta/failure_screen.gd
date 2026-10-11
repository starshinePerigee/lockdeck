extends Control

signal continue_to_title

const FX_LOW_CHIME := preload("res://assets/fx/low_chime.ogg")

func _ready() -> void:
	$ReturnButton.pressed.connect(continue_to_title.emit)
	$ReturnButton.pressed.connect(GlobalEffects.request.bind(FX_LOW_CHIME))