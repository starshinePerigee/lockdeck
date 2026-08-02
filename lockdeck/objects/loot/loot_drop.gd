extends Control

const SPAWN_Y_1 := -512
const SPAWN_Y_2 := -256
const SPAWN_X_1 := 256
const SPAWN_X_2 := 960 - 256

const MAX_LOOT_COUNT := 100
const force := 600

@export var loot_queue: Array[Loot] = []

func queue_loot(loot_array: Array[Loot]) -> void:
	loot_queue.append_array(loot_array)

func spawn_loot() -> void:
	if get_child_count() > MAX_LOOT_COUNT:
		return
	
	if len(loot_queue) == 0:
		# TODO: check in window
		return
	
	var loot: Loot = loot_queue.pop_front()
	add_child(loot)
	loot.position = Vector2(
		randi_range(SPAWN_X_1, SPAWN_X_2),
		randi_range(SPAWN_Y_1, SPAWN_Y_2)
	)
	loot.rotation_degrees = randi_range(0, 360)
	loot.apply_impulse.call_deferred(Vector2(randf_range(-force, force), 0))

func _ready() -> void:
	$Timer.timeout.connect(spawn_loot)
	
	# if name == "__main__:
	if get_tree().current_scene == self:
		var pending_loot: Array[Loots]
		pending_loot = LootGenerator.get_pile_with_value(1000, LootGenerator.COIN_DECK)
		pending_loot.append_array(
			LootGenerator.get_pile_with_value(400, LootGenerator.BAR_DECK)
		)
		pending_loot.shuffle()
		for loot in pending_loot:
			var real: Loot = Loot.new_loot(loot)
			real.loot_hovered.connect(real.get_that_bag)
			queue_loot([real])
