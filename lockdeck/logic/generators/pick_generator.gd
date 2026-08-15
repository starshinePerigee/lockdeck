class_name PickGenerator

static func get_debug_spec() -> CardSpec:
	return CardSpec.from_template(PickTemplates.DEBUG)

static func get_random_base_card() -> CardSpec:
	var template: PickTemplates = PickTemplates.valid_templates.pick_random()
	var spec := CardSpec.from_template(template)
	return spec

static func get_many_base_cards(n: int) -> Array[CardSpec]:
	var cards: Array[CardSpec] = []
	for _i in range(n):
		cards.append(get_random_base_card())
	return cards

static func get_card_with_rarity(rarity: PickTemplates.Rarities) -> CardSpec:
	return CardSpec.from_template(
		PickTemplates.rarity_catalog[rarity].pick_random()
	)

static func get_temporary_cards(count: int) -> Array[CardSpec]:
	var new_cards: Array[CardSpec] = []
	
	PickTemplates.temporary_picks.shuffle()
	for i in count:
		new_cards.append(CardSpec.from_template(PickTemplates.temporary_picks[i]))
	
	for card in new_cards:
		card.ability = Abilities.TEMPORARY
	
	return new_cards

static func get_rarity_set_with_template_value(
	count: int, 
	template_value: int
) -> Array[PickTemplates.Rarities]:
	var rarity_set: Array[PickTemplates.Rarities] = []
	var final_delta := -999_999
	for i in 10:
		var new_rarity_set: Array[PickTemplates.Rarities] = []
		for j in count:
			new_rarity_set.append(PickTemplates.rarity_catalog.keys().pick_random())
		var current_delta: int = new_rarity_set.reduce(func(sum, r): return sum + r, 0)
		if abs(current_delta) < abs(final_delta):
			final_delta = current_delta
			rarity_set = new_rarity_set
		if current_delta == 0:
			break
			
	return rarity_set

## Gets n cards with total template value (trash=0, great=4, etc)
static func get_n_cards_with_template_value(
	count: int,
	template_value: int
) -> Array[CardSpec]:
	var new_cards: Array[CardSpec] = []
	for rarity in get_rarity_set_with_template_value(count, template_value):
		new_cards.append(get_card_with_rarity(rarity))
	return new_cards

static func get_shop_spread() -> Array[CardSpec]:
	var new_cards: Array[CardSpec] = get_temporary_cards(3)
	
	for rarity in PickTemplates.rarity_catalog.keys():
		new_cards.append(get_card_with_rarity(rarity))
	
	return new_cards