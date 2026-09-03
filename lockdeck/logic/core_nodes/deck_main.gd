extends Control
## Manages the deck

## Emitted if more cards are drawn than are present in the deck
signal draw_empty

## Emitted when the reload animation finishes
signal reload_progress(int)
signal reload_finish

signal display_cards(Array)

const CARD_FLIGHT_TIME := 0.45
const CARD_TAKEOFF_TIME := 0.4

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
	cards.append_array(new_cards)
	var interval := CARD_TAKEOFF_TIME / count() + 0.02
	# tween instead of a timer
	var tween := create_tween()
	tween.tween_callback(reload_progress.emit.bind(0))
	for i in len(new_cards):
		tween.tween_callback(_animate_draw_from_discard.bind(i + 1))
		tween.tween_interval(interval)
	if len(new_cards) > 0:
		tween.tween_interval((CARD_FLIGHT_TIME + 0.1) - interval)
	tween.tween_callback(_finish_reload)
	tween.tween_callback(redraw)

func _finish_reload() -> void:
	print("reload finished")
	reload_finish.emit.call_deferred()

const CARD_BACK := preload("res://assets/card/card_back_static.png")

func _animate_draw_from_discard(i: int) -> void:
	var card := TextureRect.new()
	add_child(card)
	card.texture = CARD_BACK
	card.position = discard_pos
	card.z_index = 3100
	
	var x_tween := card.create_tween()
	x_tween.set_trans(Tween.TRANS_LINEAR)
	x_tween.tween_callback(reload_progress.emit.bind(i))
	x_tween.tween_property(card, "position:x", 0 - 120, CARD_FLIGHT_TIME)
	x_tween.tween_callback(remove_child.bind(card))
	x_tween.tween_callback(card.queue_free)
	
	var y_tween := card.create_tween()
	y_tween.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	y_tween.tween_property(
		card,
		"position:y",
		-120 - randi_range(0, 40),
		CARD_FLIGHT_TIME / 2
	)
	y_tween.set_ease(Tween.EASE_IN)
	y_tween.tween_property(card, "position:y", position.y - 30, CARD_FLIGHT_TIME / 2)

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

var _current_label := 0
func update_label(n: int = 0) -> void:
	$DeckLabel.text = "Deck: %s" % (_current_label + n)

func update_pile(n: int = 0) -> void:
	$CardPile.count = _current_label + n

## Redraw the deck
func redraw():
	_current_label = count()
	update_label()
	update_pile()

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
	reload_progress.connect(update_pile)
	reload_progress.connect(update_label)
	reload_finish.connect(redraw)
