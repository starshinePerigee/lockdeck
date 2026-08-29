extends Resource
## This class holds all of the global game settings
## This also functions 
class_name GameSettings

const SAVE_PATH := "user://game_settings.tres"

static var _instance: GameSettings

static func instance(force: bool = false) -> GameSettings:
	if _instance == null or force:
		_instance = _load_from_disk()
	return _instance

static func save():
	var ret := ResourceSaver.save(instance(), SAVE_PATH)
	if ret != OK:
		push_error("Failed to save! path: %s, error: %d" % [SAVE_PATH, ret])

static func reset() -> GameSettings:
	_instance = GameSettings.new()
	save()
	return _instance

static func _load_from_disk() -> GameSettings:
	if not ResourceLoader.exists(SAVE_PATH):
		return reset()

	var load_res: Resource = ResourceLoader.load(
		SAVE_PATH, "GameSettings", ResourceLoader.CACHE_MODE_IGNORE
	)

	if load_res is GameSettings:
		return load_res
	else:
		return reset()

signal tooltip_speed_changed(float)
@export var tooltip_speed: float = 1.4

func set_tooltip_speed(setting: float = 1.4) -> void:
	tooltip_speed = setting
	tooltip_speed_changed.emit(tooltip_speed)


signal highlight_active_row_changed(bool)
@export var highlight_active_row: bool = true

func set_highlight_active_row(setting: bool) -> void:
	highlight_active_row = setting
	highlight_active_row_changed.emit(highlight_active_row)


signal ambience_volume_changed(float)
@export var ambience_volume: float = 0.6

func set_ambience_volume(setting: float) -> void:
	ambience_volume = setting
	ambience_volume_changed.emit(ambience_volume)


signal music_volume_changed(float)
@export var music_volume: float = 0.6

func set_music_volume(setting: float) -> void:
	music_volume = setting
	music_volume_changed.emit(music_volume)


signal effect_volume_changed(float)
@export var effect_volume: float = 0.6

func set_effect_volume(setting: float) -> void:
	effect_volume = setting
	effect_volume_changed.emit(effect_volume)

