class_name PinGenerator

static func get_known_test_pin() -> PinSpec:
	var spec := PinSpec.new()
	for i in range(1, 9):
		spec.depths[i] = Depths.EMPTY
	spec.depths[4] = Depths.KEY
	spec.depths[6] = Depths.BREAK
	return spec

static var FILLER_DEPTHS: Array[Depths] = [Depths.FORCE, Depths.JAM]

static func get_random_base_pin(difficulty_mod: int = 0) -> PinSpec:
	var spec := PinSpec.new()
	for i in range(1, 9):
		spec.depths[i] = Depths.EMPTY
		
	var key_loc := randi_range(1, 8)
	spec.depths[key_loc] = Depths.KEY
	
	if key_loc < 8:
		spec.depths[randi_range(key_loc + 1, 8)] = Depths.BREAK
		
	for i in range(randi_range(0, difficulty_mod)):
		if spec.depths[i] == Depths.EMPTY:
			spec.depths[i] = Depths.BREAK
	
	for i in range(randi_range(0, 5)):
		if spec.depths[i] == Depths.EMPTY:
			spec.depths[i] = FILLER_DEPTHS[randi_range(0, len(FILLER_DEPTHS) - 1)]
	
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

static func build_real_lock(cylinders: int = 1, difficulty_mod: int = 0) -> Array[PinSpec]:
	var pin_specs: Array[PinSpec] = []
	for i in range(cylinders):
		pin_specs.append(get_random_base_pin(difficulty_mod))
	return pin_specs