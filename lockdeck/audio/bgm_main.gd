extends Node
## Manages all background (non-effect) audio

enum MUSIC_STATES {
	SILENCE,
	LOCK,
	SHOP,
	LATE_TITLE,
	END
}

func title_screen() -> void:
	$MusicManager.queue_main_menu()
	$AmbienceManager.title_screen()
	$AmbienceManager.stop_bugs()

func heist_start(heist_number: int = 0) -> void:
	$MusicManager.play_bass(heist_number > 2)
	$AmbienceManager.set_fire(false)
	$AmbienceManager.set_wind(true)
	$AmbienceManager.start_bugs()

func new_lock() -> void:
	$AmbienceManager.shift_bugs()

func strat_start() -> void:
	$MusicManager.play_shop()
	$AmbienceManager.set_fire(true)
	$AmbienceManager.set_wind(false)
	$AmbienceManager.stop_bugs()

func fail_start() -> void:
	$AmbienceManager.set_fire(false)
	$MusicManager.play_end(false)
	$AmbienceManager.stop_bugs()
	$AmbienceManager.set_night(true, -12.0)

func victory_start() -> void:
	$MusicManager.play_end(true)
	$AmbienceManager.set_wind(false)
	$AmbienceManager.stop_bugs()

func final_turn() -> void:
	$AmbienceManager.play_final_turn()

func settings_open() -> void:
	pass

func settings_closed() -> void:
	pass

func start_sample_music() -> void:
	pass

func stop_sample_music() -> void:
	pass

func _ready() -> void:
	title_screen()