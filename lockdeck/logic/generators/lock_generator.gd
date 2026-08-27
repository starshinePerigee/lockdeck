## Handles generating sets of locks
class_name LockGenerator

# Here is the process for building a lock

# 0: build a catalog of weighted copies of every depth in base_template_deck_catalog

# 1: build your "lockset deck", a sub-deck of depths that is used to build each 
# lock in a heist.
# 1a: get a DifficultyArray (a list of how many of each difficulty should be present)
# for the future lockset deck based on the current arc. This difficulty array 
# 1b: draw from the arc-catalog until you have the required number of depths for your lockset deck

# 2: draw your lock deck from the lockset deck
# 2a: get a DifficultyArray based on the current lock difficulty (separate from it's arc)
# 2b: "bump" the lock's DifficultyArray, modifying its contents in a controlled, limited fashion
# 2c: draw a lock deck from the lockset deck based on the bumped difficulty array

# 3: draw depths from the lock deck to fill out pinspecs

# Saving and loading:
# You should only need two things: the current hiest's lockset deck,
# and the current lock's lock deck. Regen the lock on load

class DifficultyArray:
	const TOTAL_TEMPLATES := 7
	
	var critical: int
	var annoying: int
	var helpful: int
	var empty: int
	var max_critical: int
	var max_annoying: int
	var max_helpful: int
	var bumps_todo: int
	
	func _init(
		critical_: int, 
		annoying_: int, 
		helpful_: int, 
		bumps_: int = 0,
	) -> void:
		critical = critical_
		annoying = annoying_
		helpful = helpful_
		empty = TOTAL_TEMPLATES - (critical + annoying + helpful)
		bumps_todo = bumps_
		max_critical = 10
		max_annoying = 10
		max_helpful = 10
	
	func copy() -> DifficultyArray:
		return DifficultyArray.new(critical, annoying, helpful, bumps_todo)
	
	func set_limit_from_source(source: DifficultyArray) -> void:
		max_critical = source.critical
		max_annoying = source.annoying
		max_helpful = source.helpful
	
	func set_limit_from_deck(source: LockDeck) -> void:
		max_critical = len(source.deck[DepthTemplates.Difficulty.CRITICAL])
		max_annoying = len(source.deck[DepthTemplates.Difficulty.ANNOYING])
		max_helpful = len(source.deck[DepthTemplates.Difficulty.HELPFUL])
	
	func try_bump() -> bool:
		match randi_range(0, 3):
			0:
				if helpful > 0:
					helpful -= 1
					empty += 1
					return true
			1:
				if empty > 0 and annoying < max_annoying:
					empty -= 1
					annoying += 1
					return true
			2:
				if annoying > 0 and critical < max_critical:
					annoying -= 1
					critical += 1
					return true
			3:
				# lucky!
#				if helpful == 0 and empty > 0:
#					helpful += 1
#					empty -= 1
				return true
		return false
	
	func do_bumps(count: int = -99) -> void:
		if count == -99:
			count = bumps_todo
		
		while count > 0:
			if try_bump():
				count -= 1
		
		helpful = min(helpful, max_helpful)
	
	func as_str() -> String:
		return (
			"crit: %s / %s, annoy: %s / %s, help: %s / %s, empty: %s (bump: %s)"
			% [critical, max_critical, annoying, max_annoying, helpful, max_helpful, empty, bumps_todo]
		)

static var arc_deck_parameters: Dictionary[LockDeck.GameArcs, DifficultyArray] = {
	LockDeck.GameArcs.EARLY: DifficultyArray.new(2, 2, 2),
	LockDeck.GameArcs.MID: DifficultyArray.new(2, 3, 2),
	LockDeck.GameArcs.LATE: DifficultyArray.new(3, 4, 3)
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
		parameters.helpful,
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

## Gets a static DifficultyArray from the predefined list (or extended, if needed)
static func get_difficulty_parameter(difficulty: int) -> DifficultyArray:
	if difficulty in difficulty_parameters:
		return difficulty_parameters[difficulty].copy()
	else:
		var last_difficulty: int = difficulty_parameters.keys()[-1]
		var d_a := difficulty_parameters[last_difficulty].copy()
		d_a.bumps_todo += difficulty - last_difficulty
		return d_a

## Get a live bumped DifficultyArray based on a difficulty value 
static func get_difficulty_parameters(
	difficulty: int,
	source: LockDeck = null
) -> DifficultyArray:
	var parameters := get_difficulty_parameter(difficulty).copy()
	if source:
		parameters.set_limit_from_deck(source)
	parameters.do_bumps()
	return parameters

## Pulls templates from the lockset deck to build a lock deck.
## Target hazard should be lower than the lockset deck
static func get_lock_deck(
	lockset_deck: LockDeck, difficulties: DifficultyArray
) -> LockDeck:
	
	return LockDeck.build_deck(
		lockset_deck,
		difficulties.critical,
		difficulties.annoying, 
		difficulties.helpful
	)

## Generate a lock_spec given a lock deck and a pin count
static func build_lock(
	deck: LockDeck, pin_count: int
) -> LockSpec:
	var pins: Array[PinSpec] = []
	# Array[Array[int))
	var open: Array[Array]
	
	# Build the open array (lists of depths per pin in random order)
	# This will determine the order depths are placed in each pin
	for i in pin_count:
		pins.append(PinSpec.new(Depths.EMPTY))
		var pin_open := range(1, PinSpec.PIN_DEPTH_COUNT - 1)
		pin_open.shuffle()
		open.append(pin_open)
	
	# The pin selector is a deck that choses which pins get the depths in a template
	var pin_selector := range(0, pin_count)
	
	for template in deck.draw_all():
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
	
	for pin in pins:
		pin.finalize()
	
	return LockSpec.new(pins, [])

## Build a level from a difficulty rating
static func get_next_level(
	difficulty: int,
	arc: LockDeck.GameArcs = LockDeck.GameArcs.MID,
	pin_count: int = -1
) -> LockSpec:
	if pin_count < 0:
		pin_count = min(difficulty, 5)
	
	print("\n        Generating new lock")
	var lockset_deck := get_lockset_deck(arc)
	var parameters := get_difficulty_parameter(difficulty)
	parameters.do_bumps()
	print(parameters.as_str())
	var lock_deck := get_lock_deck(lockset_deck, parameters)
	lock_deck.print()
	var lock := build_lock(lock_deck, pin_count)
	return lock 
