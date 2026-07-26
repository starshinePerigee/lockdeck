extends Resource
## Defines starting decks
class_name DeckTemplates

var deck_name: String
var description: String
## Should return an array of CardSpecs
var deck_gen: Callable

static func _spec_templates(templates: Array[PickTemplates]) -> Array[CardSpec]:
	var specs: Array[CardSpec] = []
	for template in templates:
		specs.append(CardSpec.from_template(template))
	return specs

func _init(
	deck_name_: String,
	description_: String,
	deck_gen_: Callable
):
	deck_name = deck_name_
	description = description_
	deck_gen = deck_gen_

static var TUTORIAL := DeckTemplates.new(
	"Tutorial",
	(
		"Learn how to play Handful of Lockpicks.\n"
		+ "Selecting this deck will enable tutorial mode, which will walk you through "
		+ "the game's basic mechanics."
	),
	func(): return _spec_templates([
		PickTemplates.DIAMOND,
		PickTemplates.DIAMOND,
		PickTemplates.DIAMOND,
	])
)

static var STANDARD := DeckTemplates.new(
	"Standard",
	(
		"A reliable, well rounded deck, capable of opening almost any lock. "
		+ "The standard deck features copies of every basic card and has access "
		+ "to all five card effects."
	),
	func(): return _spec_templates([
		PickTemplates.DIAMOND,
		PickTemplates.DIAMOND,
		PickTemplates.HOOK,
		PickTemplates.HOOK,
		PickTemplates.SNAKE,
		PickTemplates.RAKE,
		PickTemplates.BALL,
		PickTemplates.FORK,
		PickTemplates.LEVER,
		PickTemplates.PROBE
	])
)

static var ALL_DECKS: Array[DeckTemplates] = [
	TUTORIAL,
	STANDARD,
]