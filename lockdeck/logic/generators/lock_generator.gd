## Handles generating sets of locks
class_name LockGenerator

class DifficultyArray:
	const TOTAL_TEMPLATES := 10
	
	var critical: int
	var annoying: int
	var helpful: int
	var empty: int
	var bumps_todo: int
	
	func _init(
		critical_: int, 
		annoying_: int, 
		helpful_: int, 
		bumps_: int = 0
	) -> void:
		critical = critical_
		annoying = annoying_
		helpful = helpful_
		empty = TOTAL_TEMPLATES - (critical + annoying + helpful)
		bumps_todo = bumps_
	
	func copy() -> DifficultyArray:
		return DifficultyArray.new(critical, annoying, helpful, bumps_todo)
	
	func try_bump() -> bool:
		match randi_range(0, 3):
			0:
				if helpful > 0:
					helpful -= 1
					empty += 1
					return true
			1:
				if empty > 0:
					empty -= 1
					annoying += 1
					return true
			2:
				if annoying > 0:
					annoying -= 1
					critical += 1
					return true
			3:
				# lucky!
				return true
		return false
	
	func do_bumps(count: int = -99) -> void:
		if count == -99:
			count = bumps_todo
		
		while count > 0:
			if try_bump():
				count -= 1

static var arc_deck_parameters: Dictionary[LockDeck.GameArcs, DifficultyArray] = {
	LockDeck.GameArcs.EARLY: DifficultyArray.new(2, 3, 2),
	LockDeck.GameArcs.MID: DifficultyArray.new(3, 4, 3),
	LockDeck.GameArcs.LATE: DifficultyArray.new(5, 5, 4)
}

## Pulls a number of depth templates from the total list, returning a smaller
## collection that can be used to build locks. This collection will have at least
## the target hazard and count.
static func get_lockset_deck(
	arc: LockDeck.GameArcs
) -> LockDeck:
	var base_deck := LockDeck.base_template_deck_catalog[arc]
	var parameters := arc_deck_parameters[arc]
	return LockDeck.build_deck(
		base_deck,
		parameters.critical,
		parameters.annoying, 
		parameters.helpful
	)

static var difficulty_parameters: Dictionary[int, DifficultyArray] = {
	0: DifficultyArray.new(0, 1, 1, 0),
	1: DifficultyArray.new(0, 1, 1, 1),
	2: DifficultyArray.new(1, 0, 1, 1),
	3: DifficultyArray.new(1, 1, 1, 1),
	4: DifficultyArray.new(1, 1, 2, 3),
	5: DifficultyArray.new(1, 2, 2, 3),
	6: DifficultyArray.new(1, 2, 2, 4),
	7: DifficultyArray.new(2, 2, 3, 4),
	8: DifficultyArray.new(2, 2, 3, 5),
	9: DifficultyArray.new(2, 2, 3, 6),
	10: DifficultyArray.new(2, 3, 3, 6),
	11: DifficultyArray.new(3, 2, 3, 6),
	12: DifficultyArray.new(3, 3, 3, 6),
}

static func get_difficulty_parameter(difficulty: int) -> DifficultyArray:
	if difficulty in difficulty_parameters:
		return difficulty_parameters[difficulty]
	else:
		var last_difficulty: int = difficulty_parameters.keys()[-1]
		var d_a := difficulty_parameters[last_difficulty]
		d_a.bumps_todo += difficulty - last_difficulty
		return d_a

## Pulls templates from the lockset deck to build a lock deck.
## Target hazard should be lower than the lockset deck
static func get_lock_deck(
	lockset_deck: LockDeck, difficulty: int
) -> LockDeck:
	
	var parameters := get_difficulty_parameter(difficulty).copy()
	parameters.do_bumps()
	
	return LockDeck.build_deck(
		lockset_deck,
		parameters.critical,
		parameters.annoying, 
		parameters.helpful
	)

## Generate a lock_spec given a lock deck and some parameters
static func build_lock(
	deck: LockDeck, pin_count: int, hazard_target: int
) -> LockSpec:
	var pins: Array[PinSpec] = []
	# Array[Array[int))
	var open: Array[Array]
	deck.reset()
	
	# TODO TODO TODO TODO
	for i in pin_count:
		pins.append(PinSpec.new(Depths.EMPTY))
		var pin_open := range(1, PinSpec.PIN_DEPTH_COUNT - 1)
		pin_open.shuffle()
		open.append(pin_open)
	
	var pin_selector := range(0, pin_count)
	
	var hazard := 0
	for template in deck:
		pin_selector.shuffle()
		var placed := 0
		for i in range(pin_count):
			var target: int = pin_selector[i]
			# place the template's depths at pin_selector[i]
			if len(open[target]) < template.depths_per_pin():
				continue
			
			if template.minor_depth:
				var poses: Array[int] = [open[target].pop_front(), open[target].pop_front()]
				pins[target].depths[min(poses[0], poses[1])] = template.minor_depth
				pins[target].depths[max(poses[0], poses[1])] = template.depth
			else:
				var pos: int = open[target].pop_front()
				pins[target].depths[pos] = template.depth
			
			placed += 1
			if placed > template.pin_count(pin_count):
				break
		hazard += template.net_hazard
		if hazard >= hazard_target:
			break
	print("Lock generated! Hazard %s / %s" % [hazard, hazard_target])
	
	for pin in pins:
		pin.finalize()
	
	return LockSpec.new(pins, [])

## Build a level from a difficulty rating
static func get_next_level(difficulty: int) -> LockSpec:
	var pin_count: int = min(difficulty, 5)
	
	var lockset_deck := LockGenerator.get_lockset_deck(
		LockDeck.GameArcs.MID
	)
	var lock_deck := LockGenerator.get_lock_deck(lockset_deck, difficulty)
	var lock := LockGenerator.build_lock(lock_deck, pin_count, difficulty)
	return lock 
