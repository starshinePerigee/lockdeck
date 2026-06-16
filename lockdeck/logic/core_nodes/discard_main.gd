extends Control
## Manages the discard pile

## Discard clicked to reload
signal discard_pressed()

@export var cards: Array[CardSpec]

func count() -> int:
	return len(cards)

## Add a card to the discard pile
func add_cards(discards: Array[CardSpec]) -> void:
	cards.append_array(discards)

## Get all cards from the discard pile
func empty_deck() -> Array[CardSpec]:
	var old_cards: = cards
	cards = []
	return old_cards

func _ready() -> void:
	$CardPile.pile_pressed.connect(discard_pressed.emit)