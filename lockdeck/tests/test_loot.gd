extends Control

const SPAWN_Y := -284
const SPAWN_X_1 := 256
const SPAWN_X_2 := 960 - 256

@export var total_value: int = 100
@export var refil: bool = false
@export var eat_everything: bool = false
@export var force := 400

var pending_loot: Array[Loots] = []

func spawn_loot() -> void:
	if get_child_count() > 80:
		return
	
	if len(pending_loot) == 0:
		if refil:
			pending_loot = LootGenerator.get_pile_with_value(
				total_value, LootGenerator.CATEGORY_DECKS[Loots.LootsTypes.COIN]
			)
		else:
			return

	var loot := Loot.new_loot(pending_loot.pop_front())
	add_child(loot)
	loot.position = Vector2(randi_range(SPAWN_X_1, SPAWN_X_2), SPAWN_Y)
	loot.rotation_degrees = randf_range(0, 360)
	loot.apply_impulse.call_deferred(Vector2(randf_range(-force, force),  0))
	if loot.spec in Loots.ALL_COINS:
		loot.loot_hovered.connect(remove.bind(loot))
	else:
		loot.loot_clicked.connect(remove.bind(loot))
	
	loot.collide_light.connect(sound_queue.append.bind(1))
	loot.collide_medium.connect(sound_queue.append.bind(2))
	loot.collide_heavy.connect(sound_queue.append.bind(3))


func remove(target: Loot):
	target.get_that_bag()

func print_pile(pile: Array[Loots]) -> void:
	for l in pile:
		print(l.readable_name)

const FX_WEAK := preload("res://assets/fx/click_weak-001.ogg")
const FX_MED := preload("res://assets/fx/click_reset-002.ogg")
const FX_STRONG := preload("res://assets/fx/click_sharp_001.ogg")

var sound_queue: Array[int] = []

func _process(delta: float) -> void:
	if len(sound_queue) > 0:
		match sound_queue.max():
			3:
				$SoundPlayer.get_stream_playback().play_stream(FX_STRONG)
			2:
				$SoundPlayer.get_stream_playback().play_stream(FX_MED, 0, -6)
			1:
				$SoundPlayer.get_stream_playback().play_stream(FX_WEAK, 0, -24)
			_:
				pass
		sound_queue.clear()

func _ready() -> void:
	$Timer.timeout.connect(spawn_loot)
	pending_loot = LootGenerator.get_standard_loot_with_total_value(total_value)
	pending_loot.shuffle()
	print_pile(pending_loot)
	
	$Loot.loot_clicked.connect(remove.bind($Loot))
	$Loot.collide_light.connect(sound_queue.append.bind(1))
	$Loot.collide_medium.connect(sound_queue.append.bind(2))
	$Loot.collide_heavy.connect(sound_queue.append.bind(3))
