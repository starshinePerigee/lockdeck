## Handles generating loots
class_name LootGenerator

# note that despite being "decks", cards are only removed from the deck if they
# are invalid (such as over-cost for the type budget)
static var CATEGORY_DECKS: Dictionary[Loots.LootsTypes, Array] = {}
static var CATEGORY_WEIGHTS: Dictionary[Loots.LootsTypes, int] = {
	Loots.LootsTypes.COIN: 3,
	Loots.LootsTypes.BAR: 2
}

static var total_weight: float = 0.0

static func get_pile_with_value(
	value: int,
	loot_deck: Array[Loots],
) -> Array[Loots]:
	var pile: Array[Loots] = []
	var deck: Array[Loots] = loot_deck.duplicate()
	var current_value := 0
	
	while current_value < value:
		var i := randi_range(0, len(deck) - 1)
		if deck[i].value <= value - current_value:
			pile.append(deck[i])
			current_value += deck[i].value
		else:
			deck.pop_at(i)
		
		if len(deck) == 0:
			break
	
	print(
		"Generated pile with value %s against target %s"
		% [current_value, value]
	)
	return pile

static func sum_pile(pile: Array[Loots]) -> int:
	var value := 0
	for l in pile:
		value += l.value
	return value

static func get_standard_loot_with_total_value(value: int) -> Array[Loots]:
	var type_deck: Array[Loots.LootsTypes] = []
	type_deck.assign(Loots.LootsTypes.values())
	type_deck.shuffle()
	
	var total_loot: Array[Loots] = []
	
	var value_remainder := 0
	for loot_category in type_deck:
		var allocated_value := int(
			value * CATEGORY_WEIGHTS[loot_category] / total_weight
		)
		value_remainder += allocated_value
		var pile := get_pile_with_value(
			value_remainder,
			CATEGORY_DECKS[loot_category]
		)
		value_remainder -= sum_pile(pile)
		print("Remaining value: %s" % value_remainder)
		total_loot.append_array(pile)
	
	total_loot.append_array(
		get_pile_with_value(
			value_remainder,
			CATEGORY_DECKS[Loots.LootsTypes.COIN]
		)
	)
	return total_loot

static func _static_init() -> void:
	for loot_type in Loots.LootsTypes.values():
		var deck: Array[Loots] = []
		for loots in Loots.TYPE_DICT[loot_type]:
			for __ in loots.category_weight:
				deck.append(loots)
		CATEGORY_DECKS[loot_type] = deck
	
	for weight in CATEGORY_WEIGHTS.values():
		total_weight += weight
