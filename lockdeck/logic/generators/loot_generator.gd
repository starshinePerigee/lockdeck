## Handles generating loots
class_name LootGenerator

static var COIN_DECK: Array[Loots] = []

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

static func _static_init() -> void:
	for coin in Loots.ALL_COINS:
		for __ in coin.category_weight:
			COIN_DECK.append(coin)
	