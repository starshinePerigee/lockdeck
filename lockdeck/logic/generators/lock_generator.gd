## Handles generating sets of locks
class_name LockGenerator

enum GameArcs {
	EARLY = 0,
	MID = 1,
	LATE = 2
}

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

#func generate(pin_count: int, hazard_target: int) -> LockSpec:
#	pass
