class_name PinGenerator

## Gets a random position for valid playable pins (index 1 - 7)
## Index 0 is base, and index 8 is final.
static func random_pos() -> int:
	return randi_range(1, PinSpec.PIN_DEPTH_COUNT - 2)

static func get_known_test_pin() -> PinSpec:
	var spec := PinSpec.new()
	for i in range(1, PinSpec.PIN_DEPTH_COUNT - 1):
		spec.depths[i] = Depths.EMPTY
	spec.depths[1] = Depths.PUSH
	spec.depths[2] = Depths.JAM
	spec.depths[4] = Depths.KEY
	spec.depths[5] = Depths.BOUNCE
	spec.depths[6] = Depths.BREAK
	return spec

static var FILLER_DEPTHS: Array[Depths] = [
	Depths.PUSH,
	Depths.JAM,
	Depths.BOUNCE,
]

## Gets a random "filler" depth
static func get_filler() -> Depths:
	return FILLER_DEPTHS[
		randi_range(
		0, 
		len(FILLER_DEPTHS) - 1
		)
	]

## Tries to add the provided depth to a random valid position.
## Returns true if it was added
static func try_add_at_random(spec: PinSpec, depth: Depths) -> bool:
	var p := random_pos()
	if spec.depths[p] == Depths.EMPTY:
		spec.depths[p] = depth
		return true
	return false

static func get_random_base_pin(difficulty_mod: int = 0) -> PinSpec:
	var spec := PinSpec.new()
	for i in range(1, PinSpec.PIN_DEPTH_COUNT - 1):
		spec.depths[i] = Depths.EMPTY
	
	# Place two breaks (one will become a warning)
	var pos_1 := random_pos()
	var pos_2 := pos_1
	while pos_2 == pos_1:
		pos_2 = random_pos()
	
	spec.depths[pos_1] = Depths.BREAK
	spec.depths[pos_2] = Depths.BREAK
	
	for i in range(randi_range(0, difficulty_mod)):
		try_add_at_random(spec, Depths.BREAK)
	
	for i in range(randi_range(0, 5)):
		try_add_at_random(spec, get_filler())
	
	# Add more key depths at higher difficulty because i like you
	if randi_range(0, 9) < 4 + difficulty_mod:
		try_add_at_random(spec, Depths.KEY)
	
	# Make the first break a warning
	for i in range(1, PinSpec.PIN_DEPTH_COUNT):
		if spec.depths[i] == Depths.BREAK:
			spec.depths[i] = Depths.WARN
			break
	
	# Do some other validation checks
	for i in range(1, PinSpec.PIN_DEPTH_COUNT):
		if spec.depths[i] == Depths.PUSH and i > PinSpec.PIN_DEPTH_COUNT - 2:
			spec.depths[i] = Depths.EMPTY 
	
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
