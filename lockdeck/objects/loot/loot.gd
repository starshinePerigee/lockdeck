extends RigidBody2D
## The live loot objects
class_name Loot

signal loot_hovered
signal loot_clicked

const SELF_SCENE := preload("res://objects/loot/loot.tscn")

var spec: Loots 

static func new_loot(loots: Loots) -> Loot:
	var scene: Loot = SELF_SCENE.instantiate()
	scene.spec = loots
	var texture := scene.get_child(0)

	scene.mass = loots.mass
	if not loots.material == null:
		scene.physics_material_override = loots.material
	
	var collider := loots.collider.instantiate()
	scene.add_child(collider)
	
	texture.texture = loots.texture
	texture.position = -(texture.texture.get_size() / 2)
	
	return scene
	

static var SAYINGS: Array[String] = [
	"Nice",
	"Shiny",
	"Don't mind if I do",
	"Thank you",
	"For me?",
	"You shouldn't have",
	"Dibs",
	"Lucky",
	"Mine now",
	"Gotcha",
	"Another one",
	"Cha-ching",
	"Just what I wanted",
]
static var PUNCTUATION: Array[String] =[".", ".", "!", "~"]

static func get_saying() -> String:
	var saying: String = SAYINGS.pick_random()
	if saying[-1] != "?":
		saying += PUNCTUATION.pick_random()
	return saying

## Claims the loot, playing the saying and then removing it from the scene tree.
func get_that_bag() -> void:
	# wake up all adjacent
	for friend in get_colliding_bodies():
		if friend is RigidBody2D:
			friend.sleeping = false
	
	# disable this one
	disable_physics.call_deferred()
	$Label.position = global_position + Vector2(-128, 0)
	$Label.rotation = 0
	
	# set/hide visibility
	$Label.text = get_saying()
	$Label.visible = true
	$TextureRect.visible = false
	
	var label_tween := get_tree().create_tween()
	label_tween.tween_property(
		$Label,
		"position",
		$Label.position + Vector2(0, -32),
		0.6
	)
	label_tween.tween_callback(queue_free)

func disable_physics() -> void:
	collision_layer = 0
	collision_mask = 0

func _handle_input(
	_viewport: Node, event: InputEvent, _shape_idx: int
) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			loot_clicked.emit()


func _ready() -> void:
	mouse_entered.connect(loot_hovered.emit)
	input_event.connect(_handle_input)
