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
		"Learn how to play Handful of Lockpicks."
		+ "\n\nSelecting this deck will enable tutorial mode, which will walk you through "
		+ "the game's basic mechanics."
	),
	func(): return _spec_templates([
		PickTemplates.TINY_HOOK,
		PickTemplates.TINY_HOOK,
		PickTemplates.TINY_HOOK,
	])
)

static var STANDARD := DeckTemplates.new(
	"Standard",
	(
		"A reliable, well rounded deck."
		+ "\n\nThe standard deck is capable of opening almost any lock"
		+ " and making use of any pick you find."
	),
	func(): return _spec_templates([
		PickTemplates.ONE_ONE_FLAT_RAKE,
		PickTemplates.BROAD_PUSH_REVEAL_RAKE,
		PickTemplates.MEDIUM_FOUR_REACH_DIAMOND,
		PickTemplates.TWO_FOUR_TWO_DIAMOND,
		PickTemplates.TWO_FOUR_TWO_DIAMOND,
		PickTemplates.THREE_STACK_CRUSH,
		PickTemplates.CLASSIC_HOOK,
		PickTemplates.CLASSIC_HOOK,
		PickTemplates.ONE_TWO_JAM,
		PickTemplates.FORK_JAM
	])
)

static var POWERFUL := DeckTemplates.new(
	"Daring",
	(
		"A deck for the smash and grab."
		+ "\n\nThis deck features large picks with big effects. "
		+ "It might struggle against "
		+ "breakage, but that's why you've brought a few extras."
	),
	func() : return _spec_templates([
		PickTemplates.EIGHT_PUSH_DEEP_BOMB_RAKE,
		PickTemplates.TWO_ONE_FLAT_RAKE,
		PickTemplates.TWO_ONE_FLAT_RAKE,
		PickTemplates.NOISY_FOUR_PUSH_RAKE,
		PickTemplates.NOISY_FOUR_PUSH_RAKE,
		PickTemplates.MEDIUM_FOUR_REACH_DIAMOND,
		PickTemplates.MEDIUM_FOUR_REACH_DIAMOND,
		PickTemplates.TRIANGLE_CRUSH_DIAMOND,
		PickTemplates.TRIANGLE_CRUSH_DIAMOND,
		PickTemplates.LARGE_TEST_DIAMOND,
		PickTemplates.PUSH_CRUSH,
		PickTemplates.PUSH_JAM_RAKE,
	])
)

static var TRICKY := DeckTemplates.new(
	"Clever",
	(
		"The clever deck makes heavy use of Jam to precisely break down "
		+ "locks pin-by-pin, shaping it's valuable rakes to prevent surprise damage."
	),
	func(): return _spec_templates([
		PickTemplates.DEEP_REVEAL_RAKE,
		PickTemplates.TEST_ACROSS_WITH_JAM_RAKE,
		PickTemplates.NOISY_FOUR_PUSH_RAKE,
		PickTemplates.TWO_ONE_FLAT_RAKE,
		PickTemplates.TWO_ONE_FLAT_RAKE,
		PickTemplates.OFFSET_FINISHER_DIAMOND,
		PickTemplates.OFFSET_FINISHER_DIAMOND,
		PickTemplates.LARGE_TEST_DIAMOND,
		PickTemplates.ONE_TWO_JAM,
		PickTemplates.FORK_JAM
	])
)

static var CAREFUL := DeckTemplates.new(
	"Patient",
	(
		"The patient deck is perfect for the thief who names their picks "
		+ "and can't stand the thought of losing even one."
		+ "\n\nThere are no surprises when you bring this much Test."
	),
	func(): return _spec_templates([
		PickTemplates.THREE_REVEAL_RAKE,
		PickTemplates.DARK_TEST_RAKE,
		PickTemplates.DARK_TEST_RAKE,
		PickTemplates.PUSH_JAM_RAKE,
		PickTemplates.MEDIUM_FOUR_REACH_DIAMOND,
		PickTemplates.BONUS_REVEAL_HOOK,
		PickTemplates.CLASSIC_HOOK,
		PickTemplates.CLASSIC_HOOK,
		PickTemplates.THREE_TEST_HOOK,
		PickTemplates.FOCUS_LENS_JAM,
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