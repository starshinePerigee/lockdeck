class_name PickGenerator

static func get_random_base_card() -> CardSpec:
	var template: PickTemplates = PickTemplates.valid_templates.pick_random()
	var spec := CardSpec.from_template(template)
	return spec

static func get_many_base_cards(n: int) -> Array[CardSpec]:
	var cards: Array[CardSpec] = []
	for _i in range(n):
		cards.append(get_random_base_card())
	return cards

static var STANDARD_TEST_CARDS: Array[PickTemplates] = [
	PickTemplates.DIAMOND,
	PickTemplates.HOOK,
	PickTemplates.SNAKE,
	PickTemplates.RAKE,
	PickTemplates.BALL,
	PickTemplates.LEVER,
	PickTemplates.FORK,
	PickTemplates.HOOK,
	PickTemplates.SNAKE,
	PickTemplates.DIAMOND,
	PickTemplates.FORK,
	PickTemplates.HOOK,
	PickTemplates.SNAKE,
	PickTemplates.BALL,
	PickTemplates.DIAMOND,
]

static func get_standard_test_hand(n: int) -> Array[CardSpec]:
	var cards: Array[CardSpec] = []
	cards.assign(STANDARD_TEST_CARDS.slice(0, n).map(CardSpec.from_template))
	return cards
