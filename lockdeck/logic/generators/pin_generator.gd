class_name PinGenerator

static func get_known_test_pin() -> PinSpec:
	var spec := PinSpec.new()
	for i in range(1, 9):
		spec.depths[i] = Depths.EMPTY
	spec.depths[4] = Depths.KEY
	spec.depths[6] = Depths.BREAK
	return spec

static func get_random_base_pin() -> PinSpec:
	var spec := PinSpec.new()
	for i in range(1, 9):
		spec.depths[i] = Depths.EMPTY
		
	var key_loc := randi_range(1, 8)
	spec.depths[key_loc] = Depths.KEY
	
	if key_loc < 8:
		spec.depths[randi_range(key_loc + 1, 8)] = Depths.BREAK
	
	spec.pin_set = false
	return spec

static func build_test_lock(cylinders: int = 4) -> Array[PinSpec]:
	var pin_specs: Array[PinSpec] = []
	for i in range(cylinders):
		if i < 3:
			pin_specs.append(get_known_test_pin())
		else:
			pin_specs.append(get_random_base_pin())
	return pin_specs