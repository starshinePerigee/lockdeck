extends Control
## Manages the deck

@export var cards: Array[CardSpec]

func has_cards() -> bool:
	return len(cards) > 0

## Draw a card from the deck
func draw_card() -> CardSpec:
	if len(cards) == 0:
		push_error("Attempted to draw from empty deck!")
		return CardSpec.from_template(PickTemplates.DRAW_FAILED)
	var card: CardSpec = cards.pop_at(
		randi_range(0, len(cards) - 1)
	)
	redraw()
	return card

## Put cards back in the deck
func add_cards(new_cards: Array[CardSpec]) -> void:
	cards.append_array(new_cards)
	redraw()

## Redraw the deck
func redraw():
	$CardPile.count = len(cards)