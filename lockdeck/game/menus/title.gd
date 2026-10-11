extends Control

signal load_game
signal new_game
signal credits
signal show_settings

func close_game() -> void:
	get_tree().quit()

func _ready() -> void:
	$LoadGameButton.pressed.connect(load_game.emit)
	$NewGameButton.pressed.connect(new_game.emit)
	$CreditsButton.pressed.connect(credits.emit)
	$SettingsButton.pressed.connect(show_settings.emit)
	$ExitButton.pressed_confirmed.connect(close_game)