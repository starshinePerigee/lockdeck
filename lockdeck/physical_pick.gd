extends RigidBody2D

func load_spec(spec: CardSpec) -> void:
	$Sprite2D.texture = spec.template.texture
	$Sprite2D.material = PickCard.material_dictionary[spec.template.rarity]

func do_break():
	angular_velocity = randf_range(-35, 35)
	linear_velocity = Vector2(randf_range(-600, 600), -400)

func _physics_process(_delta: float) -> void:
	if global_position.y > 700:
		queue_free()

func _ready() -> void:
	do_break()
