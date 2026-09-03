extends Control
## Manages the deck

## Emitted if more cards are drawn than are present in the deck
signal draw_empty

## Emitted when the reload animation finishes
signal reload_finish

signal display_cards(Array)

var discard_pos := Vector2(1000, 500)

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

func get_random_pointers(n: int) -> Array[CardSpec]:
	var shuffled: Array = cards.duplicate()
	shuffled.shuffle()
	var ret: Array[CardSpec]
	ret.assign(shuffled.slice(0, n))
	return ret

## Put cards back in the deck from discard
func add_cards(new_cards: Array[CardSpec]) -> void:
	#TODO
	cards.append_array(new_cards)
	redraw()

func load_cards(new_cards: Array[CardSpec]) -> void:
	cards.append_array(new_cards)
	redraw()

func remove_card(card: CardSpec) -> void:
	for i in range(len(cards)):
		if cards[i].unique_id == card.unique_id:
			cards.pop_at(i)
			redraw()
			return
	push_warning("Failed to remove card %s with UID %s" % [card.pick_name, card.unique_id])

## Remove all cards
func clear_all() -> void:
	cards.clear()

func sort_card_id(a: CardSpec, b:CardSpec) -> bool:
	if a.unique_id < b.unique_id:
		return true
	return false

func load_display() -> void:
	var cards_sorted := cards.duplicate()
	cards_sorted.sort_custom(sort_card_id)
	display_cards.emit(cards_sorted)

## Redraw the deck
func redraw():
	var c := count()
	$CardPile.count = c
	$DeckLabel.text = "Deck: %s" % c

func get_nice_rect() -> Rect2:
	return $DeckLabel.get_global_rect().grow(16)

func request_tooltip() -> void:
	TooltipManager.request_tooltip(
		get_nice_rect,
		(
			"This is your deck.\n\n"
			+ "After you use a pick, you'll draw cards from your deck until you have "
			+ "at least three cards in your hand, or your deck is empty.\n\n"
			+ "Once your deck is empty, refil it by ending your turn."
		)
	)

func _ready() -> void:
	$DeckLabel.mouse_entered.connect(request_tooltip)
	$DeckLabel.pressed.connect(load_display)
