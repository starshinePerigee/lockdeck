extends Control
## Manages the hand logic and updates the hand view

## Raised when a card is clicked or a drag starts
signal hand_selected(card: CardSpec)

## Raised when a card is unselected or a drag ends (but after hand_dropped)
signal hand_deselected()

## Raised when a card is started dragging
signal hand_dragged(card_area: Area2D, card: CardSpec)

## Raised when a dragged card is dropped
signal hand_dropped(card_area: Area2D, card: CardSpec)

## The one true reference for the current state of cards in hand.
## Length is total number of cards in hand. Can be empty.
@export var cards: Array[CardSpec]

func count() -> int:
	return len(cards)

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
	$Hand.redraw(cards)
	return old_cards

func _handle_select(card_index: int) -> void:
	hand_selected.emit(cards[card_index])

func _handle_deselect(_card_index: int) -> void:
	hand_deselected.emit()

func _handle_pick_up(card_area: Area2D, card_index: int) -> void:
	hand_dragged.emit(card_area, cards[card_index])
	
func _handle_drop(card_area: Area2D, card_index: int) -> void:
	hand_dropped.emit(card_area, cards[card_index])

func _ready() -> void:
	$Hand.card_selected.connect(_handle_select)
	$Hand.card_deselected.connect(_handle_deselect)
	$Hand.card_dragged.connect(_handle_pick_up)
	$Hand.card_dropped.connect(_handle_drop)
