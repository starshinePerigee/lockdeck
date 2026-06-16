extends Control
## Manages the discard pile

## Discard clicked to reload
signal discard_pressed()

@export var cards: Array[CardSpec]

func count() -> int:
	return len(cards)

## Add multiple cards to the discard pile
func add_cards(dis_cards: Array[CardSpec]) -> void:
	cards.append_array(dis_cards)
	$CardPile.count = len(cards)

func add_card(card: CardSpec) -> void:
	cards.append(card)
	$CardPile.count = len(cards)

## Get all cards from the discard pile
func empty_deck() -> Array[CardSpec]:
	var old_cards: = cards
	cards = []
	$CardPile.count = 0
	return old_cards

func _ready() -> void:
	$CardPile.pile_pressed.connect(discard_pressed.emit)