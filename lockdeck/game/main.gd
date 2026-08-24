extends Control
## This is the top level entrypoint for Handful of Lockpicks

var VERSION_NUMBER := "v0.13.5"

func start_game(starter_deck: Array[CardSpec]) -> void:
	$GameManager.visible = true
	
	$TopLevelMenus/AnimationPlayer.play("start_game")
	$GameManager.begin_new_game(starter_deck)

func return_to_title() -> void:
	$TopLevelMenus.reset()
	$TopLevelMenus/AnimationPlayer.play("return_to_title")
	$GameManager.visible = false
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
	# TODO
	$TopLevelMenus/Title/LoadGameButton.disabled = true
	
	$Version.text = VERSION_NUMBER
	$GameManager.visible = false
	
	$GameManager.end_game.connect(return_to_title)
	$TopLevelMenus/Title.show_settings.connect($SettingsMain.show_settings)
	$GameManager/MenuMain.open_settings.connect($SettingsMain.show_settings)
	$GameManager/MenuMain.return_to_title.connect(return_to_title)
	$GameManager/MenuMain.return_to_title.connect($BgmMain.title_screen)
	$TopLevelMenus/DeckSelect.start_game.connect(start_game)
	$TopLevelMenus/AnimationPlayer.play("RESET")
	
	$GameManager.lock_start.connect($BgmMain.lock_start)
	$GameManager.shop_start.connect($BgmMain.strat_start)
	$GameManager.failure_start.connect($BgmMain.fail_start)
	$GameManager.victory_start.connect($BgmMain.victory_start)
