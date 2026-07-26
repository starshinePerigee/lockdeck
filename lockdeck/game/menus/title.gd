extends Control

signal start_game
signal show_settings

func _ready() -> void:
	$StartGameButton.pressed.connect(start_game.emit)
	$SettingsButton.pressed.connect(show_settings.emit)
