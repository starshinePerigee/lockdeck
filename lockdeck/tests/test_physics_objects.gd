extends Control

@export var torque := 0.0
@export var force := 0.0

const SPAWN_Y := -284
const SPAWN_X_1 := 256
const SPAWN_X_2 := 960 - 256

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

static var MATERIAL := load("res://assets/loot/materials/metal_material.tres")

func spawn_coin() -> void:
	if get_child_count() > 50:
		return

	var coin := RigidBody2D.new()
	coin.position = Vector2(randi_range(SPAWN_X_1, SPAWN_X_2), SPAWN_Y)
	coin.rotation_degrees = randf_range(0, 360)
	coin.physics_material_override = MATERIAL
	var flavor := randi_range(-2, 2)
	if flavor < 0:
		flavor = 0
	var texture := TextureRect.new()
	texture.texture = TEXTURES[flavor]
	texture.position = Vector2(-64, -64)
	coin.add_child(texture)
	coin.add_child(COLLIDERS[flavor].instantiate())
	add_child(coin)

func _ready() -> void:
	$Timer.timeout.connect(spawn_coin)
