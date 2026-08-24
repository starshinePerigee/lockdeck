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

func lock_start(heist_number: int = 0) -> void:
	$MusicManager.play_bass(heist_number > 2)
	$AmbienceManager.set_fire(false)
	$AmbienceManager.set_wind(true)

func strat_start() -> void:
	$MusicManager.play_shop()
	$AmbienceManager.set_fire(true)
	$AmbienceManager.set_wind(false)

func fail_start() -> void:
	$AmbienceManager.set_fire(false)
	$MusicManager.play_end(false)

func victory_start() -> void:
	$MusicManager.play_end(true)
	$AmbienceManager.set_wind(false)

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