extends Control
## The view for the full set of cylinders in the lock.
## Made up of pins, which are made up of depths.

## Contains references to all the Pin view objects in order.
## Skips having to disambiguate get_children()[i] and avoids that breaking
## if more children are added.
var pin_refs: Array[Pin]

#region display logic
## Updates all pins simultaneously as well as clearing unused pins.
func set_pin_specs(pins: Array[PinSpec]) -> void:
	for i in len(pins):
		set_pin(i, pins[i])
	for i in range(len(pins), PinSpec.CYLINDER_COUNT_MAX):
		clear_pin(i)

## Sets a specific pin by index
func set_pin(pin_index: int, pin_spec: PinSpec) -> void:
	pin_refs[pin_index].visible_ = true
	pin_refs[pin_index].load_spec(pin_spec)

## Hides a pin more correctly than setting visible = false
func clear_pin(pin_index: int) -> void:
	pin_refs[pin_index].load_spec(PinSpec.new())
	pin_refs[pin_index].visible_ = false

## Loads a debug pinspec for and hides all pins.
func clear_all_pins() -> void:
	for i in PinSpec.CYLINDER_COUNT_MAX:
		clear_pin(i)

## Loads a set of results into the pins
func set_results(pin_results: Array[ResultSpec]) -> void:
	for i in len(pin_results):
		pin_refs[i].load_results(pin_results[i])

func clear_results() -> void:
	for pin in pin_refs:
		pin.clear_results()
#endregion

func get_valid_refs() -> Array[Pin]:
	var refs: Array[Pin] = []
	for pin in pin_refs:
		if pin.visible_:
			refs.append(pin)
	return refs

func get_index_of_ref(ref: Pin) -> int:
	return pin_refs.find(ref)

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
