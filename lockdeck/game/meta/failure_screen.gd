extends Control

signal continue_to_title

func _ready() -> void:
	$ReturnButton.pressed.connect(continue_to_title.emit)