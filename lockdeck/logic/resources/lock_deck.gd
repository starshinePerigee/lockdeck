extends Resource
## This is a deck of depth templates with helper methods 
class_name LockDeck

## All the cards in a Difficulty: Array[DepthTemplate) dictionary
var deck: Dictionary[DepthTemplates.Difficulty, Array]

var _pointers: Dictionary[DepthTemplates.Difficulty, int]

enum GameArcs {
	EARLY = 0,
	MID = 1,
	LATE = 2
}

func draw(difficulty: DepthTemplates.Difficulty) -> DeckTemplates:
	_pointers[difficulty] += 1
	if _pointers[difficulty] >= len(deck[difficulty]):
		deck[difficulty].shuffle()
		_pointers[difficulty] = 0
	
	return deck[difficulty][_pointers[difficulty]]

func reset() -> void:
	for difficulty in DepthTemplates.Difficulty:
		_pointers[difficulty] = -1
		deck[difficulty].shuffle()

static func get_template_weight(template: DepthTemplates, arc: GameArcs) -> int:
	match arc:
		GameArcs.EARLY:
			return template.early_weight
		GameArcs.MID:
			return template.mid_weight
		GameArcs.LATE:
			return template.late_weight
	return 0

static var base_template_deck_catalog: Dictionary[GameArcs, LockDeck]

func _init() -> void:
	deck = {}
	for difficulty in DepthTemplates.Difficulty.values():
		deck[difficulty] = []
		_pointers[difficulty] = -1

static func _build_base_template_deck(arc: GameArcs) -> LockDeck:
	var lock_deck := LockDeck.new()
	for difficulty in DepthTemplates.Difficulty.values():
		for depth_template in DepthTemplates.template_catalog[difficulty]:
			for __ in get_template_weight(depth_template, arc):
				lock_deck.deck[difficulty].append(depth_template)
	return lock_deck

static func build_deck(
	source_deck: LockDeck,
	critical: int,
	annoying: int,
	helpful: int
) -> LockDeck:
	var new_deck := LockDeck.new()
	
	source_deck.reset()
	new_deck.deck[
		DepthTemplates.Difficulty.ESSENTIAL
	] = source_deck.deck[
		DepthTemplates.Difficulty.ESSENTIAL
	]
	
	for __ in critical:
		new_deck.deck[DepthTemplates.Difficulty.CRITICAL].append(
			source_deck.draw(DepthTemplates.Difficulty.CRITICAL)
		)
	for __ in annoying:
		new_deck.deck[DepthTemplates.Difficulty.ANNOYING].append(
			source_deck.draw(DepthTemplates.Difficulty.ANNOYING)
		)
	for __ in helpful:
		new_deck.deck[DepthTemplates.Difficulty.HELPFUL].append(
			source_deck.draw(DepthTemplates.Difficulty.HELPFUL)
		)
	return new_deck

static func _static_init() -> void:
	for arc in GameArcs.values():
		base_template_deck_catalog[arc] = _build_base_template_deck(arc)