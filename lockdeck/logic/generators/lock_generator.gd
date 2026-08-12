## Handles generating sets of locks
class_name LockGenerator

enum GameArcs {
	EARLY = 0,
	MID = 1,
	LATE = 2
}

## Maximum amount of extra hazard to accumulate trying to get target count
const HAZARD_MARGIN := 5

## How many times to skip before just accepting the current configuration
const SKIP_THRESHOLD := 3

static func get_template_weight(template: DepthTemplates, arc: GameArcs) -> int:
	match arc:
		GameArcs.EARLY:
			return template.early_weight
		GameArcs.MID:
			return template.mid_weight
		GameArcs.LATE:
			return template.late_weight
	return 0

static func get_base_template_deck(arc: GameArcs) -> Array[DepthTemplates]:
	var deck: Array[DepthTemplates] = []
	for template in DepthTemplates.ALL_TEMPLATES:
		for __ in get_template_weight(template, arc):
			deck.append(template)
	return deck

## Pulls a number of depth templates from the total list, returning a smaller
## collection that can be used to build locks. This collection will have at least
## the target hazard and count.
static func get_lockset_deck(
	arc: GameArcs,
	target_hazard: int,
	target_count: int
) -> Array[DepthTemplates]:
	var base_deck := get_base_template_deck(arc)
	base_deck.shuffle()
	
	var current_hazard := 0
	var lockset_deck: Array[DepthTemplates] = []
	
	for template in base_deck:
		lockset_deck.append(template)
		if template.net_hazard > 0:
			# negative hazards should affect lock building, but we don't wnat them
			# to over-burden the actual deck at this stage
			current_hazard += template.net_hazard
		
		if (
			current_hazard >= target_hazard 
			and len(lockset_deck) >= target_count
		):
			break 
	
	print(
		"Generated lockset deck. Count: %s vs target %s, hazard: %s vs target %s"
		% [len(lockset_deck), target_count, current_hazard, target_hazard]
	)
		
	return lockset_deck

## Pulls templates from the lockset deck to build a lock deck.
## Target hazard should be lower than the lockset deck
static func get_lock_deck(
	lockset_deck: Array[DepthTemplates], target_hazard: int
) -> Array[DepthTemplates]:
	lockset_deck.shuffle()
	
	var current_hazard := 0
	# Always include a break:
	var lock_deck: Array[DepthTemplates] = [DepthTemplates.BREAK]
	
	for template in lockset_deck:
		lock_deck.append(template)
		current_hazard += template.net_hazard
		
		if current_hazard >= target_hazard:
			break 
	
	return lock_deck

## Generate a lock_spec given a lock deck and some parameters
static func build_lock(
	deck: Array[DepthTemplates], pin_count: int, hazard_target: int
) -> LockSpec:
	var pins: Array[PinSpec] = []
	# Array[Array[int))
	var open: Array[Array]
	
	# pop Break, shuffle, and re-add it at the front
	deck.erase(DepthTemplates.BREAK)
	deck.shuffle()
	deck.insert(0, DepthTemplates.BREAK)
	
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
	
	return LockSpec.new(pins, deck)

## Build a level from a difficulty rating
static func get_next_level(difficulty: int) -> LockSpec:
	var pin_count: int = min(difficulty, 5)
	var hazard_target := difficulty + 3
	
	var lockset_deck := LockGenerator.get_lockset_deck(
		LockGenerator.GameArcs.MID,
		difficulty + 5,
		8
	)
	var lock_deck := LockGenerator.get_lock_deck(lockset_deck, hazard_target)
	var lock := LockGenerator.build_lock(lock_deck, pin_count, hazard_target)
	return lock 
