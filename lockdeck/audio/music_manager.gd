extends Node
## Handles queuing and playing bgm as requested by bgm main

static var CHILL_BASS: Array[AudioStreamMP3] = [
	preload("res://assets/bgm/bass_4_easy_loop.mp3"),
	preload("res://assets/bgm/bass_3_chill_loop.mp3"),
]
var _current_chill := -1

static var HYPE_BASS: Array[AudioStreamMP3] = [
	preload("res://assets/bgm/bass_1_default_loop.mp3"),
	preload("res://assets/bgm/bass_2_alt_loop.mp3"),
	preload("res://assets/bgm/bass_5_doubles_loop.mp3"),
]
var _current_hype := -1

static var SHOP_GUITAR: Array[AudioStreamMP3] = [
	preload("res://assets/bgm/guitar_1_minor_mel_loop.mp3"),
	preload("res://assets/bgm/guitar_3_singsong_loop.mp3")
]
var _current_shop := -1

static var LATE_TITLE: AudioStreamMP3 = preload("res://assets/bgm/guitar_2_lost_loop.mp3")

static var VICTORY_BGM: AudioStreamMP3 = preload("res://assets/bgm/bass_6_higher_loop.mp3")
static var FAILURE_BGM: AudioStreamMP3 = preload("res://assets/bgm/guitar_4_ending.mp3")

static func _get_random_track_index(tracks: Array[AudioStreamMP3], current_index: int) -> int:
	var count := len(tracks)
	if count <= 1:
		return 0
	
	var new_index := randi_range(0, count - 2)
	if new_index >= current_index:
		new_index += 1
	return new_index

var _current_stream_is_bgm_1 := false
var bgm_1_fader: Tween
var bgm_2_fader: Tween

func crossfade_track(
	track: AudioStreamMP3,
	delay: float = 1.5,
	fade_out: float = 12.0,
	immediate := false,
) -> void:
	var playing_player: AudioStreamPlayer
	var playing_fader: Tween
	var quiet_player: AudioStreamPlayer
	var quiet_fader: Tween
	
	if _current_stream_is_bgm_1:
		playing_player = $BGM_1
		playing_fader = bgm_1_fader
		quiet_player = $BGM_2
		quiet_fader = bgm_2_fader
	else:
		playing_player = $BGM_2
		playing_fader = bgm_2_fader
		quiet_player = $BGM_1
		quiet_fader = bgm_1_fader
	
	if quiet_fader:
		quiet_fader.kill()
	if playing_fader:
		playing_fader.kill()
	
	# this should already be stopped but just in case
	var ramp: float
	if immediate:
		ramp = 0.05
	else:
		ramp = 1.0
	quiet_fader = get_tree().create_tween()
	quiet_fader.tween_property(quiet_player, "volume_db", -60.0, ramp)
	quiet_fader.tween_interval(delay)
	quiet_fader.tween_callback(_start_track.bind(quiet_player, track))
	quiet_fader.tween_property(quiet_player, "volume_db", -12.0, 0.0)
	quiet_fader.tween_property(quiet_player, "volume_db", 0.0, 0.2)
	
	playing_fader = get_tree().create_tween()
	playing_fader.tween_property(playing_player, "volume_db", -60, fade_out)
	playing_fader.tween_callback(playing_player.stop)
	
	if _current_stream_is_bgm_1:
		bgm_1_fader = playing_fader
		bgm_2_fader = quiet_fader
	else:
		bgm_1_fader = quiet_fader
		bgm_2_fader = playing_fader
	_current_stream_is_bgm_1 = not _current_stream_is_bgm_1

func _start_track(player: AudioStreamPlayer, track: AudioStreamMP3) -> void:
	player.stream = track
	player.play()

func play_bass(intense: bool) -> void:
	if not intense:
		_current_chill = _get_random_track_index(CHILL_BASS, _current_chill)
		crossfade_track(CHILL_BASS[_current_chill])
	else:
		_current_hype = _get_random_track_index(CHILL_BASS, _current_hype)
		crossfade_track(HYPE_BASS[_current_hype])

func play_shop() -> void:
	_current_shop = _get_random_track_index(SHOP_GUITAR, _current_shop)
	crossfade_track(SHOP_GUITAR[_current_shop])

func play_end(victory: bool) -> void:
	if victory:
		crossfade_track(VICTORY_BGM, 1.0)
	else:
		crossfade_track(FAILURE_BGM, 2.0)

var _first_menu := true

func queue_main_menu() -> void:
	var delay
	if _first_menu:
		delay = 0.0
	else:
		delay = 1.0
	crossfade_track(LATE_TITLE, delay, 12.0, _first_menu)
	_first_menu = false

var _settings_tween: Tween
var _bgm_1_db_cache: float
var _bgm_2_db_cache: float

func settings_open() -> void:
	if _settings_tween:
		_settings_tween.kill()
	
	if bgm_1_fader.is_valid():
		bgm_1_fader.pause()
	_bgm_1_db_cache = $BGM_1.volume_db
	if bgm_2_fader.is_valid():
		bgm_2_fader.pause()
	_bgm_2_db_cache = $BGM_2.volume_db
	
	_settings_tween = get_tree().create_tween()
	_settings_tween.parallel()
	_settings_tween.tween_property($BGM_1, "volume_db", -60, 1.0)
	_settings_tween.tween_property($BGM_2, "volume_db", -60, 1.0)

var _sub_settings_tween: Tween

func settings_play() -> void:
	if _sub_settings_tween:
		_sub_settings_tween.kill()
	_sub_settings_tween = get_tree().create_tween()
	$SettingsMusic.volume_db = -60
	$SettingsMusic.play()
	_sub_settings_tween.tween_property($SettingsMusic, "volume_db", 0.0, 0.5)

func settings_stop() -> void:
	if _sub_settings_tween:
		_sub_settings_tween.kill()
	_sub_settings_tween = get_tree().create_tween()
	_sub_settings_tween.tween_property($SettingsMusic, "volume_db", -60, 0.5)
	_sub_settings_tween.tween_callback($SettingsMusic.stop)

func settings_close() -> void:
	if _settings_tween:
		_settings_tween.kill()
	_settings_tween = get_tree().create_tween()
	
	_settings_tween.tween_property($BGM_1, "volume_db", _bgm_1_db_cache, 1.0)
	_settings_tween.parallel().tween_property($BGM_2, "volume_db", _bgm_2_db_cache, 1.0)
	
	if bgm_1_fader.is_valid():
		_settings_tween.tween_callback(bgm_1_fader.play)
	if bgm_2_fader.is_valid():
		_settings_tween.tween_callback(bgm_2_fader.play)
