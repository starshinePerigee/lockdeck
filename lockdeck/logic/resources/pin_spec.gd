extends Resource
class_name PinSpec

@export var depths: Array[DepthData.DepthFlavors]
@export var reveals: Array[bool]
@export var pin_position: int
@export var pin_set: bool

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
		DepthData.DepthFlavors.BOUNCE,
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
		true,
	]
	pin_position = 0
	pin_set = true
