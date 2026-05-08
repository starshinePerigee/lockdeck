@tool
extends Control
class_name Pin

const DEPTH_SIZE = 9
const DEPTH = preload("res://objects/pin/depth.tscn")
const DEPTH_VHEIGHT = 35

@export var depths: Array[DepthData.DepthFlavors] = []:
	set(v):
		depths = v
		depths.resize(DEPTH_SIZE)
		
		_redraw()
	
@export var revealed: Array[bool] = []:
	set(v):
		revealed = v
		revealed.resize(DEPTH_SIZE)
		
		_redraw()

@export var pin_position: int = 0:
	set(v):
		pin_position = v
		
		if not is_node_ready():
			await ready
		
		$Stack.position = Vector2(0, DEPTH_VHEIGHT * DEPTH_SIZE - DEPTH_VHEIGHT * v)

@export var hide: bool = false:
	set(v):
		hide = v
		
		if not is_node_ready():
			await ready
		
		$Stack.visible = not hide

func _redraw():
	if depth_refs.is_empty():
		return
	
	for i in min(DEPTH_SIZE, len(depth_refs)):
		depth_refs[i].flavor = depths[i]
		depth_refs[i].revealed = revealed[i]

var depth_refs: Array[Depth] = []

func _ready() -> void:
	depth_refs = []
	for i in DEPTH_SIZE:
		var next_depth = DEPTH.instantiate()
		depth_refs.append(next_depth)
		$Stack/Depths.add_child(next_depth)
	
	_redraw()
