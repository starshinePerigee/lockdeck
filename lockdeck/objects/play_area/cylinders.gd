@tool
extends Control

const CYLINDER_COUNT = 5

var pin_refs: Array[Pin] = []

@export var cylinder_count: int = CYLINDER_COUNT:
	set(v):
		cylinder_count = v
		
		if not is_node_ready():
			await ready
		
		redraw()

@export var pins: Dictionary[int, PinSpec] = {}:
	set(v):
		pins = v
		
		if not is_node_ready():
			await ready

		redraw()

func redraw():
	if len(pin_refs) == 0:
		return
	
	for i in range(CYLINDER_COUNT):
		if i in pins and i < cylinder_count:
			pin_refs[i].visible_ = true
			pin_refs[i].depths = pins[i].depths
			pin_refs[i].revealed = pins[i].reveals
			pin_refs[i].pin_position = pins[i].pin_position
			pin_refs[i].jam_count = pins[i].jam_count
			pin_refs[i].pin_set = pins[i].pin_set
			pin_refs[i].key_set = pins[i].key_set
		else:
			pin_refs[i].visible_ = false
			pin_refs[i].pin_set = true

func _ready() -> void:
	pin_refs = [
		$CylinderHBox/Pin1,
		$CylinderHBox/Pin2,
		$CylinderHBox/Pin3,
		$CylinderHBox/Pin4,
		$CylinderHBox/Pin5,
	]
	cylinder_count = CYLINDER_COUNT
	redraw()
