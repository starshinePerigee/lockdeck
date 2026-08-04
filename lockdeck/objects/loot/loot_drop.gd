extends Control

signal spawn_complete
signal all_looted

const SPAWN_Y_1 := -512 - 256
const SPAWN_Y_2 := -256 - 256
const SPAWN_X_1 := 256
const SPAWN_X_2 := 960 - 256

const MAX_LOOT_COUNT := 100
const force := 600

@export var loot_queue: Array[Loot] = []

var _spawn_emitted: bool = true
var _grabbed_emitted: bool = true

func empty_queue() -> void:
	loot_queue.clear()

func clear_all() -> void:
	for child in get_children():
		if child is Loot:
			child.queue_free()

func queue_loot(loot_array: Array[Loot]) -> void:
	loot_queue.append_array(loot_array)
	loot_queue.shuffle()
	_spawn_emitted = false
	_grabbed_emitted = false

func drop_loot() -> void:
	if len(loot_queue) > 0:
		$Timer.start()

func spawn_loot() -> void:
	if get_child_count() > MAX_LOOT_COUNT:
		if not _spawn_emitted:
			spawn_complete.emit()
			_spawn_emitted = true
		return
	
	if len(loot_queue) == 0:
		# TODO: check in window
		return
	
	var loot: Loot = loot_queue.pop_front()
	loot.loot_grabbed.connect(check_complete)
	add_child(loot)
	loot.position = Vector2(
		randi_range(SPAWN_X_1, SPAWN_X_2),
		randi_range(SPAWN_Y_1, SPAWN_Y_2),
	)
	loot.rotation_degrees = randi_range(0, 360)
	loot.apply_impulse.call_deferred(Vector2(randf_range(-force, force), 0))

func check_complete() -> void:
	if _grabbed_emitted:
		return
	
	for child in get_children():
		if child is Loot:
			if not child.grabbed:
				return
	
	_grabbed_emitted = true
	all_looted.emit()
	$Timer.stop()

func _ready() -> void:
	$Timer.timeout.connect(spawn_loot)
