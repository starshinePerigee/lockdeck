extends Control
## Manages the hand logic and updates the hand view

## The one true reference for the current state of cards in hand.
## Length is total number of cards in hand. Can be empty.
@export var cards: Array[CardSpec]

func count() -> int:
	return len(cards)

## Add a single card to the hand. Added to the right side.
func add_card(card: CardSpec) -> void:
	cards.append(card)
	$Hand.redraw(cards)

## Add multiple cards to the hand. Added to the right side.
func add_cards(new_cards: Array[CardSpec]) -> void:
	cards.append_array(new_cards)
	$Hand.redraw(cards)

## Removes a specific card by CardSpec.unique_id
func remove_card(card: CardSpec) -> Vector2:
	for i in range(len(cards)):
		if cards[i].unique_id == card.unique_id:
			cards.pop_at(i)
			var space: CardSpace = $Hand.spaces[i]
			$Hand.redraw(cards)
			
			if space.card_spec.unique_id != card.unique_id:
				push_warning("Hand space:card mismatch!")
				return global_position
			else:
				return space.global_position
	push_warning("Failed to remove card %s with UID %s" % [card.pick_name, card.unique_id])
	return Vector2(-2000, -2000)

## Remove the current hand and load a new one, returning them.
func remove_all_cards() -> Array[CardSpec]:
	var old_cards := cards.duplicate()
	cards = []
	$Hand.redraw(cards)
	return old_cards
