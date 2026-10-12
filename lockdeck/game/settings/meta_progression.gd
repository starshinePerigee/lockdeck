extends Resource
## This class holds all of the meta-progression
class_name MetaProgression

@export var tutorial_level := 0
@export var depth_level := 0
@export var most_recently_seen_stage := 0

const SAVE_PATH := "user://meta_progression.tres"

static var _instance: MetaProgression

static func instance(force: bool = false) -> MetaProgression:
	if _instance == null or force:
		_instance = _load_from_disk()
	return _instance

static func save() -> void:
	var ret := ResourceSaver.save(instance(), SAVE_PATH)
	if ret != OK:
		push_error("Failed to save! path: %s, error: %d" % [SAVE_PATH, ret])

static func reset() -> MetaProgression:
	_instance = MetaProgression.new()
	save()
	return _instance

static func _load_from_disk() -> MetaProgression:
	if not ResourceLoader.exists(SAVE_PATH):
		return reset()

	var load_res: Resource = ResourceLoader.load(
		SAVE_PATH, "MetaProgression", ResourceLoader.CACHE_MODE_IGNORE
	)

	var settings: MetaProgression
	if load_res is MetaProgression:
		settings = load_res
	else:
		settings = reset()
	
	return settings
