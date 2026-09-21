extends AudioStreamPlayer
## A global singleton used to play audio
## Exactly one instance of this class should exist - currently it's in BGM Main > SFXManager
class_name GlobalEffects

static var _instance: GlobalEffects
var playback: AudioStreamPlaybackPolyphonic

static func request(stream_: AudioStream, volume_ := 0.0) -> void:
	if not _instance:
		return
	
	_instance.playback.play_stream(stream_, 0, volume_)

func _ready() -> void:
	if _instance:
		push_error("Static global sound effect player initialized!")
		return
	_instance = self
	
	# This is an audiostreampolyphonic so we set it to play from the jump
	play()
	playback = get_stream_playback()