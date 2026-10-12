extends Resource
## This is a deck of depth templates with helper methods 
class_name LockDeck

## All the cards in a Difficulty: Array[DepthTemplate) dictionary
@export var deck: Dictionary[DepthTemplates.Difficulty, Array]

## used to track your position in the deck while you are drawing cards
## (decks are not shuffled between each card draw; only once exhausted)
var _pointers: Dictionary[DepthTemplates.Difficulty, int]

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

func get_unique_depths() -> Dictionary[DepthTemplates.Difficulty, Array]:
	var depths: Dictionary[DepthTemplates.Difficulty, Array] = {}
	for key in deck.keys():
		if len(deck[key]) == 0:
			continue
		
		depths[key] = []
		for template in deck[key]:
			if template.depth not in depths[key]:
				depths[key].append(template.depth)
			if template.minor_depth and template.minor_depth not in depths[key]:
				depths[key].append(template.minor_depth)
	return depths

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

func reify() -> void:
	for key in deck.keys():
		for template in deck[key]:
			template.reify()

func _init() -> void:
	deck = {}
	for difficulty in DepthTemplates.Difficulty.values():
		deck[difficulty] = []
		_pointers[difficulty] = -1

static func from_template_array(templates: Array[DepthTemplates]) -> LockDeck:
	var lock_deck := LockDeck.new()
	for template in templates:
		lock_deck.deck[template.difficulty].append(template)
	return lock_deck

## Builds the current global template deck based on current progress
static func base_template_deck() -> LockDeck:
	var unlocked: Array[DepthTemplates] = []
	unlocked.append_array(DepthTemplates.STARTING_TEMPLATES)
	unlocked.append_array(
		DepthTemplates.UNLOCK_ORDER.slice(
			0,
			MetaProgression.instance().depth_level
		)
	)
	
	var lock_deck := LockDeck.new()
	for difficulty in DepthTemplates.Difficulty.values():
		for depth_template in DepthTemplates.template_catalog[difficulty]:
			if depth_template in unlocked:
				for __ in depth_template.weight:
					lock_deck.deck[difficulty].append(depth_template)
	return lock_deck

static func build_deck(
	source_deck: LockDeck,
	critical: int,
	annoying: int,
	helpful: int,
	mandatory: DepthTemplates = null
) -> LockDeck:
	var new_deck := LockDeck.new()
	
	source_deck.reset()
	new_deck.deck[
		DepthTemplates.Difficulty.ESSENTIAL
	] = source_deck.deck[
		DepthTemplates.Difficulty.ESSENTIAL
	]
	
	if mandatory:
		match mandatory.difficulty:
			DepthTemplates.Difficulty.CRITICAL:
				critical = max(0, critical - 1)
			DepthTemplates.Difficulty.ANNOYING:
				annoying = max(0, annoying - 1)
			DepthTemplates.Difficulty.HELPFUL:
				helpful = max(0, helpful - 1)
			_:
				pass
		new_deck.deck[mandatory.difficulty].append(mandatory)
	
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

