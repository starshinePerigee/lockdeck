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


func _handle_input(
	_viewport: Node, event: InputEvent, _shape_idx: int
) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			loot_clicked.emit()


func _ready() -> void:
	mouse_entered.connect(loot_hovered.emit)
	input_event.connect(_handle_input)
