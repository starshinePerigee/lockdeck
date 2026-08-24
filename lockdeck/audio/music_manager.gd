extends Node
## Handles queuing and playing bgm as requested by bgm main

static var CHILL_BASS: Array[AudioStreamMP3] = [
	preload("res://assets/bgm/bass_4_easy_loop.mp3"),
	preload("res://assets/bgm/bass_3_chill_loop.mp3"),
]

static var HYPE_BASS: Array[AudioStreamMP3] = [
	preload("res://assets/bgm/bass_1_default_loop.mp3"),
	preload("res://assets/bgm/bass_2_alt_loop.mp3"),
	preload("res://assets/bgm/bass_5_doubles_loop.mp3"),
]

static var SHOP_GUITAR: Array[AudioStreamMP3] = [
	preload("res://assets/bgm/guitar_1_minor_mel_loop.mp3"),
	preload("res://assets/bgm/guitar_3_singsong_loop.mp3")
]

static var LATE_TITLE: AudioStreamMP3 = preload("res://assets/bgm/guitar_2_lost_loop.mp3")

static var VICTORY_BGM: AudioStreamMP3 = preload("res://assets/bgm/bass_6_higher_loop.mp3")
static var FAILURE_BGM: AudioStreamMP3 = preload("res://assets/bgm/guitar_4_ending.mp3")

enum MUSIC_STATES {
	SILENCE,
	LOCK,
	SHOP,
	LATE_TITLE,
	END
}

var _current_stream_is_bgm_1 := false
var bgm_1_fader: Tween
var bgm_2_fader: Tween

func crossfade_track(track: AudioStreamMP3) -> void:
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
	
	_current_stream_is_bgm_1 = not _current_stream_is_bgm_1
	
	if quiet_fader:
		quiet_fader.kill()
	if playing_fader:
		playing_fader.kill()
	
	# this should already be stopped but just in case
	quiet_fader = get_tree().create_tween()
	quiet_fader.tween_property(quiet_player, "volume_db", -80, 1.0)
	quiet_fader.tween_interval(2.5)
	quiet_fader.tween_callback(_start_track.bind(quiet_player, track))
	
	playing_fader = get_tree().create_tween()
	playing_fader.tween_property(playing_player, "volume_db", -80, 5.0)
	playing_fader.tween_callback(playing_player.stop)

## All of our music has built-in intros, so we don't need to fade in tracks.
func _start_track(player: AudioStreamPlayer, track: AudioStreamMP3) -> void:
	player.stop()
	player.volume_db = 0.0
	player.stream = track
	player.play()

func play_game_track(intense: bool) -> void:
	pass

func _ready() -> void:
	bgm_1_fader = get_tree().create_tween()
	bgm_1_fader.tween_interval(20.0)
	bgm_1_fader.tween_callback(_start_track.bind($BGM_1, LATE_TITLE))
	