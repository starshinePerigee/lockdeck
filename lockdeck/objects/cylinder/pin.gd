@tool
extends Control
## The view for a single pin in the lock, made up of multiple depths.
class_name Pin

## Number of depth segments to make a pin.
## Sets the forced size of the depths and revealed arrays.
const DEPTH_SIZE = 9
## Vertical height of a depth texture in pixels.
const DEPTH_VHEIGHT = 35
const _DEPTH = preload("res://objects/cylinder/depth.tscn")

## Reference to each depth object, so adding children doesn't break things.
var depth_refs: Array[Depth] = []

## If this pin is "set" - aka, jammed and won't fall at the next fall step.
@export var pin_set: bool = false:
	set(v):
		pin_set = v
		if pin_set:
			$Stack.modulate = Color("848484")
		else:
			$Stack.modulate = Color("ffffff")

## Current position of the pin. 0 is all the way down, and 9 is all the way up.
@export var pin_position: int = 0:
	set(v):
		pin_position = v
		
		if not is_node_ready():
			await ready
		
		$Stack.position = Vector2(0, DEPTH_VHEIGHT * DEPTH_SIZE - DEPTH_VHEIGHT * v)

## Hides the pin, visually.
## I don't remember why I use this instaead of just self.visible?
## games james ¯\_(ツ)_/¯
@export var visible_: bool = false:
	set(v):
		visible_ = v
		
		if not is_node_ready():
			await ready
		
		$Stack.visible = visible_

## The value of the jam indicator, and if one is present. If jam count is less than or equal
## to zero, hide the jam indicator.
@export var jam_count: int = 0:
	set(v):
		jam_count = v
		
		if not is_node_ready():
			await ready
		
		$JamIndicator.visible = jam_count > 0
		$JamIndicator/JamCount.text = str(jam_count)

## If the unlock indicator is visible.
@export var key_set: bool = false:
	set(v):
		key_set = v
		
		if not is_node_ready():
			await ready
		
		$KeyIndicator.visible = key_set

func load_spec(pin_spec: PinSpec) -> void:
	if depth_refs.is_empty():
		return
		
	for i in min(DEPTH_SIZE, len(depth_refs)):
		depth_refs[i].flavor = pin_spec.depths[i]
		depth_refs[i].revealed = pin_spec.reveals[i]
	
	pin_position = pin_spec.pin_position
	jam_count = pin_spec.jam_count
	pin_set = pin_spec.pin_set
	key_set = pin_spec.key_set

func _ready() -> void:
	depth_refs = []
	for i in DEPTH_SIZE:
		var next_depth = _DEPTH.instantiate()
		depth_refs.append(next_depth)
		$Stack/Depths.add_child(next_depth)
	
	load_spec(PinSpec.new())
