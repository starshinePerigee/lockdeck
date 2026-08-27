extends Resource
## This is a deck of depth templates with helper methods 
class_name LockDeck

## All the cards in a Difficulty: Array[DepthTemplate) dictionary
@export var deck: Dictionary[DepthTemplates.Difficulty, Array]

## used to track your position in the deck while you are drawing cards
## (decks are not shuffled between each card draw; only once exhausted)
var _pointers: Dictionary[DepthTemplates.Difficulty, int]

enum GameArcs {
	INVALID = -1,
	EARLY = 0,
	MID = 1,
	LATE = 2
}

func draw(difficulty: DepthTemplates.Difficulty) -> DepthTemplates:
	_pointers[difficulty] += 1
	if _pointers[difficulty] >= len(deck[difficulty]):
		deck[difficulty].shuffle()
		_pointers[difficulty] = 0
	
	return deck[difficulty][_pointers[difficulty]]

func reset() -> void:
	for difficulty in DepthTemplates.Difficulty.values():
		_pointers[difficulty] = -1
		deck[difficulty].shuffle()

func print() -> void:
	for difficulty in DepthTemplates.Difficulty:
		print(difficulty)
		for template in deck[DepthTemplates.Difficulty[difficulty]]:
			print("    %s" % template.as_str())

func draw_all() -> Array[DepthTemplates]:
	reset()
	
	var drawn_templates: Array[DepthTemplates] = []
	for difficulty in [
		DepthTemplates.Difficulty.ESSENTIAL,
		DepthTemplates.Difficulty.CRITICAL,
		DepthTemplates.Difficulty.HELPFUL,
		DepthTemplates.Difficulty.ANNOYING,
		DepthTemplates.Difficulty.EMPTY,
	]:
		drawn_templates.append_array(deck[difficulty])
	
	return drawn_templates

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
