extends Control
## Manages the discard pile

@export var cards: Array[CardSpec]

## Add a card to the discard pile
func add_card(card: CardSpec) -> void:
	cards.append(card)

## Get all cards from the discard pile
func empty_deck() -> Array[CardSpec]:
	var old_cards: = cards
	cards = []
	return old_cards