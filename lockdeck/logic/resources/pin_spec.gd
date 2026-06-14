extends Resource
## PinSpec is the dataclass that describes a single pin's status.
## It includes an array of depth flavors, depth reveal statuses, 
## as well as other pin information like jam and unlock indicatiors.
class_name PinSpec

## Maxmimum number of cylinders.
## This is a deep assumption - changing this will break *everything*.
## so dont.
const CYLINDER_COUNT_MAX := 5

## Number of depths
## This is also pretty deep so maybe don't touch it?
const PIN_DEPTH_COUNT := 9

## Array of depth flavors for this pin. Index 0 is the top flavor, and
## will typically be Depths.BASE
@export var depths: Array[Depths]
## Revealed status array. True shows the depth texture, false shows "?"
@export var reveals: Array[bool]
## Current depth index for the pin. Starts at 0, increases as the pin is picked.
@export var pin_position: int
## If the pin is "set" (will not fall during the next fall step). Greys out the pin.
@export var pin_set: bool
## If the pin is ready to unlock. Shows the unlock graphic.
@export var key_set: bool
## If the pin has a jam value. Greater than 0 will show the jam indicator.
@export var jam_count: int

## Get the depth flavor that the pin is currently set to.
func current_depth() -> Depths:
	return depths[pin_position]

## Touch the pin
func unset_pin() -> void:
	pin_set = false
	key_set = false

## Move the pin forward (if positive) or backwards (if negative), returning true if oob'ed.
func advance_pin(relative: int = 0, absolute: int = -1) -> bool:
	if add_jam(-1):
		return false
	
	var oob := false
	if absolute >= 0:
		pin_position = absolute
	pin_position += relative
	if pin_position >= PIN_DEPTH_COUNT or pin_position < 0:
		pin_position = clamp(pin_position, 0, PIN_DEPTH_COUNT - 1)
		oob = true
	
	reveals[pin_position] = true
	return oob

## Adds or removes jam. Sets the pin if jam > 0. Returns true if pin was jammed.
func add_jam(value: int) -> bool:
	var jammed := jam_count > 0
	jam_count = max(0, jam_count + value)
	if jam_count > 0:
		pin_set = true
		return true
	else:
		unset_pin()
		return jammed

## Reveals a pin in n positions. Unsets the pin.
func reveal_pin(value: int) -> void:
	if add_jam(-1):
		return
	
	var reveal_position := pin_position + value
	if not (reveal_position >= PIN_DEPTH_COUNT or pin_position < 0):
		reveals[reveal_position] = true

## Resets the pin to default values but does not change depths.
func reset_pin():
	depths.fill(Depths.DEBUG)
	depths[0] = Depths.BASE
	
	reveals.fill(false)
	reveals[0] = true
	
	pin_position = 0
	pin_set = false
	key_set = false
	jam_count = false

func _init():
	depths = []
	depths.resize(PIN_DEPTH_COUNT)
	
	reveals = []
	reveals.resize(PIN_DEPTH_COUNT)
	
	reset_pin()
