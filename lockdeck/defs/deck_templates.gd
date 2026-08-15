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
		PickTemplates.HOOK_PRECISE_BASIC,
		PickTemplates.HOOK_PRECISE_BASIC,
		PickTemplates.HOOK_PRECISE_BASIC,
	])
)

static var STANDARD := DeckTemplates.new(
	"Standard",
	(
		"A balanced set of picks. It can tackle any early lock, and can use most picks you find."
		+ "\n\nIts biggest weakness is a lack of push. Add picks quickly or be locked out."
	),
	func(): return _spec_templates([
		PickTemplates.RAKE_BULK_TEST_BASIC,
		PickTemplates.RAKE_HYBRID_S_BASIC,
		PickTemplates.DIAMOND_THREE_PUSH_BASIC,
		PickTemplates.DIAMOND_THREE_PUSH_BASIC,
		PickTemplates.DIAMOND_REVEAL_BASIC,
		PickTemplates.HOOK_PUSHY_BASIC,
		PickTemplates.HOOK_PUSHY_BASIC,
		PickTemplates.WRENCH_END_TURN_BASIC
	])
)

static var POWERFUL := DeckTemplates.new(
	"Daring",
	(
		"A deck full of powerful rakes, designed for the quick heist or smash-and-grab."
		+ "\n\nMake sure you grab every speed bonus - you'll need the extra gold for repairs."
	),
	func() : return _spec_templates([
		PickTemplates.RAKE_BULK_PUSH_BASIC,
		PickTemplates.RAKE_BULK_PUSH_BASIC,
		PickTemplates.RAKE_GAPS_BASIC,
		PickTemplates.RAKE_BULK_TEST_BASIC,
		PickTemplates.RAKE_HYBRID_S_BASIC,
		PickTemplates.HOOK_PUSHY_BASIC,
		PickTemplates.DIAMOND_DARK_BASIC,
		PickTemplates.WRENCH_ISOLATION_BASIC
	])
)

static var CAREFUL := DeckTemplates.new(
	"Patient",
	(
		"The hooks in this deck let you approch each lock carefully, tackling one pin at a time."
		+ "\n\nSave your torsion wrench for the end of the turn, as this strategy takes time."
	),
	func(): return _spec_templates([
		PickTemplates.RAKE_GAPS_BASIC,
		PickTemplates.DIAMOND_THREE_PUSH_BASIC,
		PickTemplates.DIAMOND_FINISHER_BASIC,
		PickTemplates.HOOK_PRECISE_BASIC,
		PickTemplates.HOOK_PRECISE_BASIC,
		PickTemplates.HOOK_PUSHY_BASIC,
		PickTemplates.HOOK_PUSHY_BASIC,
		PickTemplates.HOOK_CLOSE_TEST_BASIC,
		PickTemplates.WRENCH_TRICKS_BASIC,
	])
)

static var TRICKY := DeckTemplates.new(
	"Clever",
	(
		"Careful manipulation of jam will let you turn your heavy rakes and diamonds into surgical instruments."
		+ "\n\nYou only have four of them, so don't be reckless!"
	),
	func(): return _spec_templates([
		PickTemplates.HOOK_JUMP_TEST_BASIC,
		PickTemplates.WRENCH_LOCK_N_BLOCK_BASIC,
		PickTemplates.WRENCH_ISOLATION_BASIC,
		PickTemplates.WRENCH_TRICKS_BASIC,
		PickTemplates.DIAMOND_THREE_PUSH_BASIC,
		PickTemplates.DIAMOND_DARK_BASIC,
		PickTemplates.RAKE_BULK_PUSH_BASIC,
		PickTemplates.RAKE_BULK_PUSH_BASIC
	])
)

static var RANDOM := DeckTemplates.new(
	"Random",
	(
		"Grab a random handful of lockpicks and get started."
		+ "\n\nMaybe it'll work out this time?"
	),
	PickGenerator.get_many_base_cards.bind(10)
)

static var ALL_DECKS: Array[DeckTemplates] = [
	TUTORIAL,
	STANDARD,
	POWERFUL,
	TRICKY,
	CAREFUL,
	RANDOM
]