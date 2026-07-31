extends Control

const SPAWN_Y := -284
const SPAWN_X_1 := 256
const SPAWN_X_2 := 960 - 256

@export var eat_everything: bool = false
@export var force := 400

static var TEXTURES: Array[Resource] = [
	load("res://assets/loot/coin_1.png"),
	load("res://assets/loot/coin_2.png"),
	load("res://assets/loot/coin_3.png"),
]

static var COLLIDERS: Array[PackedScene] = [
	preload("res://assets/loot/colliders/shape_coin_1.tscn"),
	preload("res://assets/loot/colliders/shape_coin_2.tscn"),
	preload("res://assets/loot/colliders/shape_coin_3.tscn"),
]

var DISTRIBUTION: Array[int] = [
	0, 0, 0, 0, 0, 0, 0, 0,
	1, 1, 1,
	2
]

static var MATERIAL := load("res://assets/loot/materials/metal_material.tres")

func spawn_coin() -> void:
	if get_child_count() > 20:
		return

	var coin := RigidBody2D.new()
	coin.input_pickable = true
	coin.position = Vector2(randi_range(SPAWN_X_1, SPAWN_X_2), SPAWN_Y)
	coin.rotation_degrees = randf_range(0, 360)
	coin.physics_material_override = MATERIAL
	var flavor: int = DISTRIBUTION.pick_random()
	var texture := TextureRect.new()
	texture.texture = TEXTURES[flavor]
	texture.position = Vector2(-64, -64)
	texture.mouse_filter = MOUSE_FILTER_IGNORE
	coin.add_child(texture)
	var collider := COLLIDERS[flavor].instantiate()
	coin.add_child(collider)
	add_child(coin)
	if flavor == 2 and not eat_everything:
		coin.input_event.connect(_handle_input.bind(coin))
	else:
		coin.mouse_entered.connect(remove.bind(coin))
	coin.apply_impulse.call_deferred(Vector2(randf_range(-force, force),  0))

func _handle_input(viewport: Node, event: InputEvent, shape_idx: int, target: RigidBody2D) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			remove(target)

func remove(target: RigidBody2D):
	remove_child(target)
	target.queue_free()

func _ready() -> void:
	$Timer.timeout.connect(spawn_coin)
