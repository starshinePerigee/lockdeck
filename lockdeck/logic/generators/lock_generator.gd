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

static func get_lockset_deck(
	arc: GameArcs,
	target_hazard: int,
	target_count: int
) -> Array[DepthTemplates]:
	var base_deck := get_base_template_deck(arc)
	base_deck.shuffle()
	
	var current_hazard := 0
	var lockset_deck: Array[DepthTemplates] = []
	var skip_count := 0
	
	# TODO: if deck is super borked (skip count maxxed), retry entirely
	for template in base_deck:
		var future_hazard := current_hazard + template.net_hazard
		var hazard_delta := future_hazard - target_hazard
		
		# check if we are over-hazarded
		if hazard_delta > 0:
			var add_anyway: bool = randi_range(0, 5) > hazard_delta
			if not add_anyway:
				# use a skip
				skip_count += 1
				if skip_count > SKIP_THRESHOLD:
					print(
						"Returning deck with extra hazard. Hazard: %s vs %s target"
						% [future_hazard, target_hazard]
					)
					break
				else:
					continue
		current_hazard = future_hazard
		lockset_deck.append(template)
		
		# check if we are at the count limit
		if len(lockset_deck) >= target_count:
			#
			if hazard_delta >= 0:
				print(
					"Happy deck. Count: %s vs target %s, hazard: %s vs target %s"
					% [len(lockset_deck), target_count, current_hazard, target_hazard]
				)
				break
			
			var break_early: bool = randi_range(0, 5) > -hazard_delta
			if break_early:
				print(
					"Semi-happy deck. Count: %s vs target %s, hazard: %s vs target %s"
					% [len(lockset_deck), target_count, current_hazard, target_hazard]
				)
				break
			else:
				# use a skip
				skip_count += 1
				if skip_count > SKIP_THRESHOLD:
					print(
						"Returning deck with insufficent hazard. Hazard: %s vs %s target"
						% [current_hazard, target_hazard]
					)
					break
				else:
					continue
	print("Skip count: %s" % skip_count)
	return lockset_deck

#func generate(pin_count: int, hazard_target: int) -> LockSpec:
#	pass
