extends Control
## Manages the trash pile

@export var cards: Array[CardSpec]

## Add a card to the trash
func add_card(card: CardSpec) -> void:
	cards.append(card)
	$CardPile.count = len(cards)