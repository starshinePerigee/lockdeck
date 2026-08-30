extends Control
## This is the top level entrypoint for Handful of Lockpicks

var VERSION_NUMBER := "v0.15.4"

var _saved_game: GameSpec

func check_saved_game() -> void:
	_saved_game = GameSpec.load_save()
	var invalid := _saved_game == null or _saved_game.invalid_save
	$TopLevelMenus/Title/LoadGameButton.disabled = invalid

func load_saved_game() -> void:
	_saved_game.reify()
	$GameManager.visible = true
	$TopLevelMenus/AnimationPlayer.play("direct_load")
	$GameManager.load_saved_game(_saved_game)

func start_game(starter_deck: Array[CardSpec]) -> void:
	$GameManager.visible = true
	
	$TopLevelMenus/AnimationPlayer.play("start_game")
	$GameManager.begin_new_game(starter_deck)

func return_to_title() -> void:
	$TopLevelMenus.reset()
	$TopLevelMenus/AnimationPlayer.play("return_to_title")
	$GameManager.visible = false
	$GameManager.abort_and_reset()
	check_saved_game()

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
	check_saved_game()
	$Version.text = VERSION_NUMBER
	$GameManager.visible = false
	
	$GameManager.end_game.connect(return_to_title)
	$TopLevelMenus/Title.show_settings.connect($SettingsMain.show_settings)
	$GameManager/MenuMain.open_settings.connect($SettingsMain.show_settings)
	$GameManager/MenuMain.return_to_title.connect(return_to_title)
	$GameManager/MenuMain.return_to_title.connect($BgmMain.title_screen)
	$TopLevelMenus/DeckSelect.start_game.connect(start_game)
	$TopLevelMenus/Title.load_game.connect(load_saved_game)
	$TopLevelMenus/AnimationPlayer.play("RESET")
	
	$SettingsMain/SettingsWidget.opened.connect($BgmMain.settings_open)
	$SettingsMain/SettingsWidget.closed.connect($BgmMain.settings_closed)
	$SettingsMain/SettingsWidget.ambience_hovered_start.connect($BgmMain.start_sample_ambience)
	$SettingsMain/SettingsWidget.ambience_hovered_end.connect($BgmMain.stop_sample_ambience)
	$SettingsMain/SettingsWidget.music_hovered_start.connect($BgmMain.start_sample_music)
	$SettingsMain/SettingsWidget.music_hovered_end.connect($BgmMain.stop_sample_music)
	$SettingsMain/SettingsWidget.effects_hovered_start.connect($BgmMain.start_sample_effects)
	$SettingsMain/SettingsWidget.effects_hovered_end.connect($BgmMain.stop_sample_effects)
	
	$GameManager.heist_start.connect($BgmMain.heist_start)
	$GameManager.lock_start.connect($BgmMain.new_lock)
	$GameManager/GameCore.final_turn.connect($BgmMain.final_turn)
	$GameManager.shop_start.connect($BgmMain.strat_start)
	$GameManager.failure_start.connect($BgmMain.fail_start)
	$GameManager.victory_start.connect($BgmMain.victory_start)
