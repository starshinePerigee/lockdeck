extends Control
## This is the top level entrypoint for Handful of Lockpicks

var VERSION_NUMBER := "v0.11.0"

func start_game(starter_deck: Array[CardSpec]) -> void:
	$MenuButton.visible = true
	$GameManager.visible = true
	$SettingsWidget.add_button("DEBUG: Solve level", $GameManager.auto_complete_level, true)
	$SettingsWidget.add_button("DEBUG: Reveal lock", $GameManager.reveal_level, true)
	$SettingsWidget.add_button("DEBUG: Break three", $GameManager.break_three) 
	
	$TopLevelMenus/AnimationPlayer.play("start_game")
	$GameManager.begin_new_game(starter_deck)

func abandon_game_and_return_to_title() -> void:
	$MenuButton.visible = false
	$GameManager.visible = false
	$SettingsWidget.remove_button("DEBUG: Solve level")
	$SettingsWidget.remove_button("DEBUG: Break three")
	
	$TopLevelMenus.reset()
	$TopLevelMenus/AnimationPlayer.play("return_to_title")
	$GameManager.abort_and_reset()

func _ready() -> void:
	$Version.text = VERSION_NUMBER
	$MenuButton.visible = false
	$GameManager.visible = false
	
	$MenuButton.pressed.connect($SettingsWidget.show_widget)
	$SettingsWidget.add_button(
		"Abort game and return to title",
		abandon_game_and_return_to_title,
		true
	)
	$GameManager.end_game.connect(abandon_game_and_return_to_title)
	$TopLevelMenus/Title.show_settings.connect($SettingsWidget.show_widget)
	$TopLevelMenus/DeckSelect.start_game.connect(start_game)
	$TopLevelMenus/AnimationPlayer.play("RESET")
