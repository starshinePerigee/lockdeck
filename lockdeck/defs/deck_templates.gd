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

# TODO: consider removing probe, force people to puzzle.
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
		PickTemplates.FORK,  # Might replace this
		PickTemplates.LEVER,
		PickTemplates.PROBE
	])
)

static var POWERFUL := DeckTemplates.new(
	"Daring",
	(
		"A deck for the smash and grab. "
		+ "This deck features large picks with big effects, "
		+ "and can tear through basic locks. It might struggle against "
		+ "breakage, but that's why you've brought a few extras."
	),
	func() : return _spec_templates([
		PickTemplates.DIAMOND,
		PickTemplates.DIAMOND,
		PickTemplates.DIAMOND,
		PickTemplates.HOOK,
		PickTemplates.HOOK,
		PickTemplates.RAKE,
		PickTemplates.RAKE,
		PickTemplates.PROBE,
		PickTemplates.LEVER,
		PickTemplates.LEVER,
		PickTemplates.LEVER,
		PickTemplates.PRYBAR
	])
)

static var TRICKY := DeckTemplates.new(
	"Clever",
	(
		"The clever deck makes heavy use of Jam to precisely break down "
		+ "locks pin-by-pin."
		+ "TBR"  # TODO
	),
	func(): return _spec_templates([
		PickTemplates.DIAMOND,
		PickTemplates.DIAMOND,
		PickTemplates.DIAMOND,
		PickTemplates.RAKE,
		PickTemplates.LEVER,
		PickTemplates.PROBE,
		PickTemplates.PROBE,
		PickTemplates.FORK,
		PickTemplates.BALL,
		PickTemplates.BALL,
	])
)

static var CAREFUL := DeckTemplates.new(
	"Patient",
	(
		"The patient deck is perfect for the thief who names their picks "
		+ "and can't stand the thought of losing even one.\n"
		+ "There are no surprises when you map the the interior "
		+ "of each lock before you make any moves."
	),
	func(): return _spec_templates([
		PickTemplates.DIAMOND,
		PickTemplates.RAKE,
		PickTemplates.RAKE,
		PickTemplates.HOOK,
		PickTemplates.HOOK,
		PickTemplates.PROBE,
		PickTemplates.BALL,
		PickTemplates.SNAKE,
		PickTemplates.SNAKE,
	])
)

static var RANDOM := DeckTemplates.new(
	"Random",
	(
		"Grab a random handful of lockpicks and get started.\n"
		+ "Maybe it'll work out this time?"
	),
	PickGenerator.get_many_base_cards.bind(12)
)

static var ALL_DECKS: Array[DeckTemplates] = [
	TUTORIAL,
	STANDARD,
	POWERFUL,
	TRICKY,
	CAREFUL,
	RANDOM
]