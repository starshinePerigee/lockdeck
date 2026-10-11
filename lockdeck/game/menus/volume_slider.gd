extends Control

signal setting_updated(float)
signal hovered_start()
signal hovered_stop()

@export var texture_normal: Texture2D = null
@export var texture_highlight: Texture2D = null
@export var texture_disabled: Texture2D = null

@export var sound_name: String = "SOUNDS"

const effect_normal: Texture2D = preload("res://assets/interface/sound_status_normal.png")
const effect_hover: Texture2D = preload("res://assets/interface/sound_status_highlight.png")
const effect_mute: Texture2D = preload("res://assets/interface/sound_status_mute.png")
const effect_mute_highlight: Texture2D = preload("res://assets/interface/sound_status_mute_highlight.png")

const NORMAL := Color("FFFFFF")
const HOVERED := Color("ffbc57")
const DISABLED := Color("575651")

var _prev_pos: float = 0.6
var _muted: bool = false

func set_value(value: float) -> void:
	$HSlider.value = value
	_prev_pos = value
	_muted = value == 0.0
	show_mute(_muted)
	_update_bus(value)
	_end_hover()

func toggle_mute() -> void:
	_muted = not _muted
	if _muted:
		_prev_pos = $HSlider.value
		$HSlider.value = 0.0
		_update_bus(0.0)
	else:
		$HSlider.value = _prev_pos
		_update_bus(0.0)
	show_mute(_muted)
	setting_updated.emit($HSlider.value)

func show_mute(muted: bool) -> void:
	if muted:
		$Status.texture = effect_mute_highlight
	else:
		$Status.texture = effect_hover

func update_value(value: float) -> void:
	_muted = $HSlider.value == 0.0
	show_mute(_muted)
	_update_bus(value)
	setting_updated.emit($HSlider.value)

func _do_hover() -> void:
	$Label.add_theme_color_override("font_color", HOVERED)
	$VolumeIcon.texture = texture_highlight
	if _muted:
		$Status.texture = effect_mute_highlight
	else:
		$Status.texture = effect_hover
	$HSlider.theme_type_variation = "HSliderForceHighlight"
	hovered_start.emit()

func _end_hover() -> void:
	if _muted:
		$Label.add_theme_color_override("font_color", DISABLED)
		$VolumeIcon.texture = texture_disabled
		$Status.texture = effect_mute
	else:
		$Label.add_theme_color_override("font_color", NORMAL)
		$VolumeIcon.texture = texture_normal
		$Status.texture = effect_normal
	$HSlider.theme_type_variation = "HSlider"
	hovered_stop.emit()

func _update_bus(value: float) -> void:
	AudioServer.set_bus_volume_db(
		bus_index,
		linear_to_db(value) 
	) 

var bus_index: int

func _ready() -> void:
	$Label.text = sound_name
	bus_index = AudioServer.get_bus_index(sound_name)
	
	_end_hover()
	$VolumeIcon.clicked.connect(toggle_mute)
	$HSlider.value_changed.connect(update_value)
	mouse_entered.connect(_do_hover)
	mouse_exited.connect(_end_hover)
