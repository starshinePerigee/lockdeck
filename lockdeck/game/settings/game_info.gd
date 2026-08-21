extends Resource
## This is a persistent resource meant to handle top level game info
class_name GameInfo

@export var last_version: String = ""
@export var start_count: int = 0

const SAVE_PATH := "user://game_info.tres"

static var _instance: GameInfo

static func instance(force: bool = false) -> GameInfo:
	if _instance == null or force:
		_instance = _load_from_disk()
	return _instance

static func save():
	var ret := ResourceSaver.save(instance(), SAVE_PATH)
	if ret != OK:
		push_error("Failed to save! path: %s, error: %d" % [SAVE_PATH, ret])

static func reset() -> GameInfo:
	_instance = GameInfo.new()
	save()
	return _instance

static func _load_from_disk() -> GameInfo:
	if not ResourceLoader.exists(SAVE_PATH):
		return reset()

	# "Force a fresh read from disk"
	var load_res: Resource = ResourceLoader.load(
		SAVE_PATH, "GameState", ResourceLoader.CACHE_MODE_IGNORE
	)

	if load_res is GameInfo:
		return load_res
	else:
		return reset()