extends Control
## Manages the deck

## Emitted if more cards are drawn than are present in the deck
signal draw_empty

@export var cards: Array[CardSpec]

func count() -> int:
	return len(cards)

## Try to draw n cards, returning less if less are present.
func draw_cards(n: int) -> Array[CardSpec]:
	if count() < n:
		draw_empty.emit()
		n = count()
	var many_cards: Array[CardSpec] = []
	for i in range(n):
		many_cards.append(cards.pop_at(
			randi_range(0, len(cards) - 1)
		))
	redraw()
	return many_cards

## Put cards back in the deck
func add_cards(new_cards: Array[CardSpec]) -> void:
	cards.append_array(new_cards)
	redraw()

## Redraw the deck
func redraw():
	$CardPile.count = len(cards)