extends RigidBody2D

func load_spec(spec: CardSpec) -> void:
	$Sprite2D.texture = spec.template.texture
	$Sprite2D.material = PickCard.material_dictionary[spec.template.rarity]

func do_break():
	angular_velocity = randf_range(-35, 35)
	linear_velocity = Vector2(randf_range(-600, 600), -400)
	var timer := create_tween()
	timer.tween_interval(1.5)
	timer.tween_callback(clean_up)

func _physics_process(_delta: float) -> void:
	if global_position.y > 700:
		clean_up()

func clean_up() -> void:
	visible = false
	queue_free()

func _ready() -> void:
	do_break()
