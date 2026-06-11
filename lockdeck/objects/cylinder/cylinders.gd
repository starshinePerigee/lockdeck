@tool
extends Control
## The view for the full set of cylinders in the lock.
## Made up of pins, which are made up of depths.
## 
## The most important variable is pins, which sets the values (as PinSpecs)
## for the entire apparatus (but also forces a redraw).

## Maxmimum number of cylinders.
## This is a deep assumption - changing this will break *everything*.
## so dont.
const CYLINDER_COUNT_MAX = 5

## Contains references to all the Pin view objects in order.
## Skips having to disambiguate get_children()[i] and avoids that breaking
## if more children are added.
var pin_refs: Array[Pin]

## Number of active cylinders.
@export var cylinder_count: int:
	set(v):
		var old_count = cylinder_count
		cylinder_count = v
		
		if not is_node_ready():
			await ready
		
		if old_count > cylinder_count:
			for i in range(cylinder_count, CYLINDER_COUNT_MAX):
				clear_pin(i)
		else:
			for i in range(old_count, cylinder_count):
				set_pin(i, PinSpec.new())

## Updates one or more pins based on new pin specs.
## Pins not included in the dictionary do not update.
func set_pin_specs(pins: Dictionary[int, PinSpec]) -> void:	
	for k in pins.keys():
		if k < cylinder_count:
			set_pin(k, pins[k])

## Sets a specific pin by index
func set_pin(pin_index: int, pin_spec: PinSpec) -> void:
	pin_refs[pin_index].visible_ = true
	pin_refs[pin_index].load_spec(pin_spec)

## Hides a pin more correctly than setting visible = false
func clear_pin(pin_index: int) -> void:
	pin_refs[pin_index].load_spec(PinSpec.new())
	pin_refs[pin_index].visible_ = false
	pin_refs[pin_index].pin_set = true

func clear_all_pins() -> void:
	for i in cylinder_count:
		clear_pin(i)

func _ready() -> void:
	pin_refs = [
		$CylinderHBox/Pin1,
		$CylinderHBox/Pin2,
		$CylinderHBox/Pin3,
		$CylinderHBox/Pin4,
		$CylinderHBox/Pin5,
	]
	clear_all_pins()

func _init() -> void:
	pin_refs = []
	cylinder_count = CYLINDER_COUNT_MAX
	
