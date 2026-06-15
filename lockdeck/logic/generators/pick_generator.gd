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