extends Control
## The view for the full set of cylinders in the lock.
## Made up of pins, which are made up of depths.

signal animation_complete()

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

var _tween: Tween
var _open_awaits: int
func animate_pins(pins: Array[PinSpec], results: Array[ResultSpec] = []):
	if _tween:
		_tween.kill()
	_tween = create_tween()
	# sync with indicator pick
	_tween.tween_interval(0.02)
	_open_awaits = len(pins)
	
	for i in range(len(pins) - 1, -1, -1):
		if (
			pins[i].pin_position == pin_refs[i].pin_position
			and len(results[i].results) <= 1
		):
			_tween.tween_callback(pin_refs[i].load_spec.bind(pins[i]))
		else:
			_tween.tween_callback(pin_refs[i].animate.bind(pins[i], results[i]))
			_tween.tween_interval(0.07)

func _pseudo_await() -> void:
	_open_awaits -= 1
	if _open_awaits == 0:
		animation_complete.emit()
#endregion

func get_valid_global_rect() -> Rect2:
	var rect: Rect2 = pin_refs[0].get_global_rect()
	rect = rect.merge(get_valid_refs()[-1].get_global_rect())
	return rect

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
	for pin in pin_refs:
		pin.animation_complete.connect(_pseudo_await)
	clear_all_pins()

func _init() -> void:
	pin_refs = []
