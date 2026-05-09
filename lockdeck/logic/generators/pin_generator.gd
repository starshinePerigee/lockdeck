class_name PinGenerator

static func get_random_base_pin() -> PinSpec:
	var spec = PinSpec.new()
	for i in range(1, 8):
		spec.depths[i] = DepthData.DepthFlavors.EMPTY
		
	var key_loc = randi_range(1, 7)
	spec.depths[key_loc] = DepthData.DepthFlavors.KEY
	
	if key_loc < 7:
		spec.depths[randi_range(key_loc + 1, 7)] = DepthData.DepthFlavors.BREAK
	
	spec.pin_set = false
	return spec
