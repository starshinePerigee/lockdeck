extends Control
## This is the top level entrypoint for Handful of Lockpicks

var VERSION_NUMBER := "v0.7.0"

func start_game(starter_deck: Array[CardSpec]) -> void:
	$TopLevelMenus/AnimationPlayer.play("start_game")
	$GameManager.visible = true
	$GameManager.begin_new_game(starter_deck)

func _ready() -> void:
	$Version.text = VERSION_NUMBER
	$GameManager.visible = false
	$TopLevelMenus/Title.show_settings.connect($SettingsWidget.show_widget)
	$TopLevelMenus/DeckSelect.start_game.connect(start_game)
