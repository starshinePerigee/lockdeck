extends Control

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
	var texture := TextureButton.new()
	texture.texture_normal = TEXTURES[flavor]
	texture.position = Vector2(-64, -64)
	texture.pressed.connect(remove.bind(coin))
	var mask := BitMap.new()
	mask.create_from_image_alpha(TEXTURES[flavor].get_image())
	texture.texture_click_mask = mask
	coin.add_child(texture)
	coin.add_child(COLLIDERS[flavor].instantiate())
	add_child(coin)

func remove(target: RigidBody2D):
	remove_child(target)
	target.queue_free()

func _ready() -> void:
	$Timer.timeout.connect(spawn_coin)
