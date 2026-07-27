extends Control
## This is the top level entrypoint for Handful of Lockpicks

var VERSION_NUMBER := "v0.7.0"

func start_game(starter_deck: Array[CardSpec]) -> void:
	$MenuButton.visible = true
	$GameManager.visible = true
	$SettingsWidget.add_button("DEBUG: Solve level", $GameManager.auto_complete_level)
	$SettingsWidget.add_button("DEBUG: Break three", $GameManager.break_three) 
	
	$TopLevelMenus/AnimationPlayer.play("start_game")
	$GameManager.begin_new_game(starter_deck)

func _ready() -> void:
	$Version.text = VERSION_NUMBER
	$MenuButton.visible = false
	$GameManager.visible = false
	$MenuButton.pressed.connect($SettingsWidget.show_widget)
	$TopLevelMenus/Title.show_settings.connect($SettingsWidget.show_widget)
	$TopLevelMenus/DeckSelect.start_game.connect(start_game)
