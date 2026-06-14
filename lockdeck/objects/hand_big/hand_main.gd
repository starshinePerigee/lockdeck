extends Control
## Manages the hand logic and updates the hand view

## The one true reference for the current state of cards in hand.
## Length is total number of cards in hand. Can be empty.
@export var cards: Array[CardSpec]

## Add a single card to the hand. Added to the right side.
func add_card(card: CardSpec) -> void:
	cards.append(card)
	$Hand.redraw(cards)

## Remove a specific card by index, returning it.
func remove_card(index: int) -> CardSpec:
	if index >= len(cards):
		push_error("Tried to remove card at high index %s", index)
		return
	var old_card: CardSpec = cards.pop_at(index)
	$Hand.redraw(cards)
	return old_card

## Remove the current hand and load a new one, returning them.
func load_new_hand(new_cards: Array[CardSpec] = []) -> Array[CardSpec]:
	var old_cards := cards.duplicate()
	cards = new_cards.duplicate()
	print("loaded %s" %len(new_cards))
	$Hand.redraw(cards)
	return old_cards
	