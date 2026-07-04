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

enum RevealLevel {
	REVEALED = 0,
	CLEAR = 1,
	INTERESTING = 2,
	DANGEROUS = 3,
	UNKNOWN = 4,
}

## Array of depth flavors for this pin. Index 0 is the top flavor, and
## will typically be Depths.BASE
@export var depths: Array[Depths]
## Revealed status array.
@export var reveals: Array[RevealLevel]
## Checks if depths have been tested this turn
@export var checked: Array[bool]
## Current depth index for the pin. Starts at 0, increases as the pin is picked.
@export var pin_position: int
## If the pin has a jam value. Greater than 0 will show the jam indicator.
@export var jam_count: int

## Get the depth flavor that the pin is currently set to.
func current_depth() -> Depths:
	return depths[pin_position]

## Get the visible depth for a pin, or the current one (default)
## Negative numbers index from the back 
func get_visible(idx: int = 99) -> Depths:
	if idx == 99:
		idx = pin_position
	match reveals[idx]:
		RevealLevel.REVEALED:
			return depths[idx]
		RevealLevel.UNKNOWN:
			return Depths.HIDDEN
		RevealLevel.CLEAR:
			return Depths.MARK_CLEAR
		RevealLevel.INTERESTING:
			return Depths.MARK_INTERESTING
		RevealLevel.DANGEROUS:
			return Depths.MARK_DANGEROUS
	return Depths.DEBUG

## Updates a level's reveal level, setting it to the highest option.
func update_visible(idx: int, level: RevealLevel) -> void:
	reveals[idx] = min(reveals[idx], level)

func reset_checked() -> void:
	checked.fill(false)

## Get if the pin is currently revealed
func revealed(idx: int) -> bool:
	return reveals[idx] == RevealLevel.REVEALED

## Returns true if the pin is currently solved.
func is_solved() -> bool:
	return current_depth() in Depths.SOLVE_DEPTHS

## Returns true if the pin is currently jammed
func is_jammed() -> bool:
	return jam_count > 0

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
	return oob

## Reveals a depth (or the current depth if none is provided)
func reveal_position(pos: int = -1) -> void:
	if pos == -1:
		pos = pin_position
	reveals[pos] = RevealLevel.REVEALED

## Adds or removes jam. Sets the pin if jam > 0. Returns true if pin was jammed.
func add_jam(value: int) -> bool:
	var jammed := jam_count > 0
	jam_count = max(0, jam_count + value)
	if jam_count > 0:
		return true
	return jammed

## Reveals a pin in n positions. Does not work through jam.
func reveal_pin(value: int) -> void:
	if jam_count > 0:
		return
	
	var target_position := pin_position + value
	if not (target_position >= PIN_DEPTH_COUNT or pin_position < 0):
		reveals[target_position] = RevealLevel.REVEALED

## Resets the pin to default values but does not change depths.
func reset_pin() -> void:
	pin_position = 0
	jam_count = 0
	reset_checked()

func _init():
	depths = []
	depths.resize(PIN_DEPTH_COUNT)
	depths.fill(Depths.DEBUG)
	depths[0] = Depths.BASE
	depths[-1] = Depths.FINAL
	
	reveals = []
	reveals.resize(PIN_DEPTH_COUNT)
	reveals.fill(RevealLevel.UNKNOWN)
	reveals[0] = RevealLevel.REVEALED
	reveals[-1] = RevealLevel.REVEALED
	
	checked = []
	checked.resize(PinSpec.PIN_DEPTH_COUNT)
	checked.fill(false)

	reset_pin()
