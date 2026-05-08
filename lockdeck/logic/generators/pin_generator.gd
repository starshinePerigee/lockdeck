class_name PinGenerator

static func get_random_base_pin() -> PinSpec:
	var pin_core = [
		DepthData.DepthFlavors.BREAK,
		DepthData.DepthFlavors.KEY,
		DepthData.DepthFlavors.EMPTY,
		DepthData.DepthFlavors.EMPTY,
		DepthData.DepthFlavors.EMPTY,
		DepthData.DepthFlavors.EMPTY,
		DepthData.DepthFlavors.EMPTY
	]
	pin_core.shuffle()
	var spec = PinSpec.new()
	for i in range(len(pin_core)):
		spec.depths[i + 1] = pin_core[i]
	spec.pin_set = false
	return spec
