extends Control
## The view for the full set of cylinders in the lock.
## Made up of pins, which are made up of depths.

## Emitted when a new pin is hovered;
signal new_pin_hovered(pin_index: int)

## Emitted when transitioning from pin to no pin being hovered:
signal pin_no_longer_hovered()

## Emitted when a cylinder is activated (either clicking or dropping)
signal pin_activated(pin_index: int)

## Contains references to all the Pin view objects in order.
## Skips having to disambiguate get_children()[i] and avoids that breaking
## if more children are added.
var pin_refs: Array[Pin]

## Sets if the cylinder should be listening for drag events (and thus emitting
## new_pin_hovered events)
var listening_for_drag: bool = false

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
	pin_refs[pin_index].pin_set = true

## Loads a debug pinspec for and hides all pins.
func clear_all_pins() -> void:
	for i in PinSpec.CYLINDER_COUNT_MAX:
		clear_pin(i)

#endregion

#region input logic
var _active_pins: Array[int] = []

func _handle_card_enter_pin(pin_index: int) -> void:
	if pin_index in _active_pins:
		push_warning("Card re-entered entered pin %s" % pin_index)
		return
	_active_pins.append(pin_index)
	if _active_pins[0] == pin_index:
		new_pin_hovered.emit(pin_index)
	
func _handle_card_exit_pin(pin_index: int) -> void:
	if not pin_index in _active_pins:
		push_warning("Card exited without entering pin %s" % pin_index)
		return
	var current_pin := _active_pins[0]
	_active_pins.erase(pin_index)
	if len(_active_pins) == 0:
		pin_no_longer_hovered.emit()
	elif _active_pins[0] != current_pin:
		new_pin_hovered.emit(_active_pins[0])

func current_active_pin() -> int:
	if len(_active_pins) == 0:
		return -1
	return _active_pins[0]

#endregion

func _ready() -> void:
	pin_refs = [
		$CylinderHBox/Pin1,
		$CylinderHBox/Pin2,
		$CylinderHBox/Pin3,
		$CylinderHBox/Pin4,
		$CylinderHBox/Pin5,
	]
	clear_all_pins()
	for i in len(pin_refs):
		pin_refs[i].pin_clicked.connect(pin_activated.emit.bind(i))
		pin_refs[i].card_entered_pin.connect(_handle_card_enter_pin.bind(i))
		pin_refs[i].card_exited_pin.connect(_handle_card_exit_pin.bind(i))

func _init() -> void:
	pin_refs = []
