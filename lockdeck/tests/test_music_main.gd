extends Control

static var BASS_1: AudioStreamMP3 = preload("res://assets/bgm/bass_4_easy_loop.mp3")
static var GUITAR_1: AudioStreamMP3 = preload("res://assets/bgm/guitar_1_minor_mel_loop.mp3")

func _play_bass_1() -> void:
	$BgmMain/MusicManager.crossfade_track(BASS_1)

func _play_guitar_1() -> void:
	$BgmMain/MusicManager.crossfade_track(GUITAR_1)

func _ready() -> void:
	$Bass1Button.pressed.connect(_play_bass_1)
	$Guitar1Button.pressed.connect(_play_guitar_1)
