extends Control
## This is the top level entrypoint for Handful of Lockpicks

var VERSION_NUMBER := "v0.13.3"

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
	$SettingsWidget.remove_button("DEBUG: Reveal lock")
	
	$TopLevelMenus.reset()
	$TopLevelMenus/AnimationPlayer.play("return_to_title")
	$GameManager.abort_and_reset()

static func _get_major_version(version: String) -> String:
	return version.substr(0, version.rfind("."))

func load_saves() -> void:
	var save := GameInfo.instance()
	
	if save.last_version:
		print("Last loaded from version %s#%s" % [save.last_version, save.start_count])
		var load_major_version := _get_major_version(save.last_version)
		var current_major_version := _get_major_version(VERSION_NUMBER)
		
		if load_major_version != current_major_version:
			push_warning(
				"Save version mismatch! Save: %s vs current: %s"
				% [save.last_version, VERSION_NUMBER]
			)
			save = GameInfo.reset()
	else:
		print("No save data detected. Creating new save.")
	
	save.start_count += 1
	save.last_version = VERSION_NUMBER
	GameInfo.save()

func _ready() -> void:
	load_saves()
	
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
