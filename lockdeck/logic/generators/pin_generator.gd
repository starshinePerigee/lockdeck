class_name PinGenerator

## Gets a random position for valid playable pins (index 1 - 7)
## Index 0 is base, and index 8 is final.
static func random_pos() -> int:
	return randi_range(1, PinSpec.PIN_DEPTH_COUNT - 2)

static func get_known_test_pin() -> PinSpec:
	var spec := PinSpec.new()
	for i in range(1, PinSpec.PIN_DEPTH_COUNT - 1):
		spec.depths[i] = Depths.EMPTY
	spec.depths[1] = Depths.FORCE
	spec.depths[2] = Depths.JAM
	spec.depths[4] = Depths.KEY
	spec.depths[6] = Depths.BREAK
	return spec

static var FILLER_DEPTHS: Array[Depths] = [Depths.FORCE, Depths.JAM]

## Gets a random "filler" depth
static func get_filler() -> Depths:
	return FILLER_DEPTHS[
		randi_range(
		0, 
		len(FILLER_DEPTHS) - 1
		)
	]

static func get_random_base_pin(difficulty_mod: int = 0) -> PinSpec:
	var spec := PinSpec.new()
	for i in range(1, PinSpec.PIN_DEPTH_COUNT - 1):
		spec.depths[i] = Depths.EMPTY
	
	var pos_1 := random_pos()
	var pos_2 := pos_1
	while pos_2 == pos_1:
		pos_2 = random_pos()
	
	spec.depths[min(pos_1, pos_2)] = Depths.WARN
	spec.depths[max(pos_1, pos_2)] = Depths.BREAK
	
	for i in range(randi_range(0, difficulty_mod)):
		var p := random_pos()
		if spec.depths[p] == Depths.EMPTY:
			spec.depths[p] = Depths.BREAK
	
	for i in range(randi_range(0, 5)):
		var p := random_pos()
		if spec.depths[p] == Depths.EMPTY:
			spec.depths[p] = get_filler()
	
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