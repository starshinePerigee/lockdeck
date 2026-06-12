extends Resource
## PinSpec is the dataclass that describes a single pin's status.
## It includes an array of depth flavors, depth reveal statuses, 
## as well as other pin information like jam and unlock indicatiors.
class_name PinSpec

## Maxmimum number of cylinders.
## This is a deep assumption - changing this will break *everything*.
## so dont.
const CYLINDER_COUNT_MAX := 5

## Array of depth flavors for this pin. Index 0 is the top flavor, and
## will typically be DepthFlavors.BASE
@export var depths: Array[DepthData.DepthFlavors]
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
func current_depth() -> DepthData.DepthFlavors:
	return depths[pin_position]

func _init():
	depths = [
		DepthData.DepthFlavors.BASE,
		DepthData.DepthFlavors.DEBUG,
		DepthData.DepthFlavors.DEBUG,
		DepthData.DepthFlavors.DEBUG,
		DepthData.DepthFlavors.DEBUG,
		DepthData.DepthFlavors.DEBUG,
		DepthData.DepthFlavors.DEBUG,
		DepthData.DepthFlavors.DEBUG,
		DepthData.DepthFlavors.DEBUG,
	]
	reveals = [
		true,
		false,
		false,
		false,
		false,
		false,
		false,
		false,
		false,
	]
	pin_position = 0
	pin_set = false
	key_set = false
	jam_count = 0
