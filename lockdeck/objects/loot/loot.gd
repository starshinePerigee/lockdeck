extends RigidBody2D
## The live loot objects
class_name Loot

signal loot_hovered
signal loot_clicked
signal loot_grabbed
signal collide(bool, EffectFonts)

const SELF_SCENE := preload("res://objects/loot/loot.tscn")

var spec: Loots

var fx_font: Loots.EffectFonts

var grabbed: bool = false

static func new_loot(loots: Loots) -> Loot:
	var scene: Loot = SELF_SCENE.instantiate()
	scene.spec = loots
	var texture := scene.get_child(0)

	scene.mass = loots.mass
	if not loots.material == null:
		scene.physics_material_override = loots.material
	scene.fx_font = loots.fx_font
	
	var collider := loots.collider.instantiate()
	scene.add_child(collider)
	
	texture.texture = loots.texture
	texture.position = -(texture.texture.get_size() / 2)
	
	return scene
	

static var SAYINGS: Array[String] = [
	"Yoink",
	"Yoink",
	"Nice",
	"Nice",
	"Dibs",
	"Dibs",
	"You saw nothing",
	"Easy",
	"Shiny",
	"Don't mind if I do",
	"Thank you",
	"For me?",
	"You shouldn't have",
	"Lucky",
	"Mine now",
	"Gotcha",
	"Another one",
	"Cha-ching",
	"Just what I wanted",
]
static var PUNCTUATION: Array[String] =[".", ".", "!", "!", "!", "~"]

static func get_saying() -> String:
	var saying: String = SAYINGS.pick_random()
	if saying[-1] != "?":
		saying += PUNCTUATION.pick_random()
	return saying

## Claims the loot, playing the saying and then removing it from the scene tree.
func get_that_bag() -> void:
	grabbed = true
	# wake up all adjacent
	if contact_monitor:
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
	
	var label_tween := create_tween()
	label_tween.tween_property(
		$Label,
		"position",
		$Label.position + Vector2(0, -32),
		0.6
	)
	label_tween.tween_callback(queue_free)
	loot_grabbed.emit()

func disable_physics() -> void:
	freeze = true
	collision_layer = 0
	collision_mask = 0

const STRONG_THRESHOLD := 400000.0
const WEAK_THRESHHOLD := 10000.0
const ROT_SCALE := 1000
const TIME_THRESHOLD := 50
var previous_velocity := Vector2.ZERO
var prev_rotation := 0.0
@onready var prev_time := Time.get_ticks_msec()

func _physics_process(delta: float) -> void:
	var delta_vel := linear_velocity - previous_velocity
	var delta_rot := angular_velocity - prev_rotation
	var delta_weight: float = delta_vel.length_squared() + abs(delta_rot) * ROT_SCALE
	
	if delta_weight > WEAK_THRESHHOLD:
		var current_time := Time.get_ticks_msec()
		if delta_weight > STRONG_THRESHOLD:
			collide.emit(true, fx_font)
			prev_time = current_time
		elif current_time - prev_time > TIME_THRESHOLD:
			collide.emit(false, fx_font)
			prev_time = current_time
	
	previous_velocity = linear_velocity
	prev_rotation = angular_velocity

func _handle_input(
	_viewport: Node, event: InputEvent, _shape_idx: int
) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			loot_clicked.emit()


func _ready() -> void:
	mouse_entered.connect(loot_hovered.emit)
	input_event.connect(_handle_input)
