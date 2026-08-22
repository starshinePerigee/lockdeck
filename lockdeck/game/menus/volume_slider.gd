extends Control

@export var texture_normal: Texture2D = null
@export var texture_highlight: Texture2D = null
@export var texture_disabled: Texture2D = null

@export var sound_name: String = "SOUNDS"

const effect_normal: Texture2D = preload("res://assets/interface/sound_status_normal.png")
const effect_hover: Texture2D = preload("res://assets/interface/sound_status_highlight.png")
const effect_mute: Texture2D = preload("res://assets/interface/sound_status_mute.png")
const effect_mute_highlight: Texture2D = preload("res://assets/interface/sound_status_mute_highlight.png")

const NORMAL := Color("757575")
const HOVERED := Color("ffbc57")
const DISABLED := Color("575651")

var _prev_pos: float
var _muted: bool

func toggle_mute() -> void:
	_muted = not _muted
	if _muted:
		_prev_pos = $HSlider.value
		$HSlider.value = 0.0
		$Status.texture = effect_mute_highlight
	else:
		$HSlider.value = _prev_pos
		$Status.texture = effect_hover

func _do_hover() -> void:
	$Label.add_theme_color_override("font_color", HOVERED)
	$VolumeIcon.texture = texture_highlight
	if _muted:
		$Status.texture = effect_mute_highlight
	else:
		$Status.texture = effect_hover
	$HSlider.notification(Control.NOTIFICATION_MOUSE_ENTER)

func _end_hover() -> void:
	if _muted:
		$Label.add_theme_color_override("font_color", DISABLED)
		$VolumeIcon.texture = texture_disabled
		$Status.texture = effect_mute
	else:
		$Label.add_theme_color_override("font_color", NORMAL)
		$VolumeIcon.texture = texture_normal
		$Status.texture = effect_normal
	$HSlider.notification(Control.NOTIFICATION_MOUSE_EXIT)

func _ready() -> void:
	$Label.text = sound_name
	_end_hover()
	$VolumeIcon.clicked.connect(toggle_mute)
	mouse_entered.connect(_do_hover)
	mouse_exited.connect(_end_hover)
	
