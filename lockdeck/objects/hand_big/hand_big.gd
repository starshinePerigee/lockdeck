extends Container
# The view for the hand and all the cards in it

signal card_selected(card_index: int)
signal card_deselected(card_index: int)
signal card_dragged(card_area: Area2D, card_index: int)
signal card_dropped(card_area: Area2D, card_index: int)

const CARD_SPACE := preload("res://objects/card/card_space.tscn")
# starts at "1 card"
const SIZE_SCALE := [0, 25, 20, 15, 10, 0, -5, -10, -15, -20, -25, -30]

var current_card: int = -1

func get_space() -> CardSpace:
	return $Hand.get_children()[current_card]

func _disable_others(card_index: int) -> void:
	for i in len($Hand.get_children()):
		if i != card_index:
			var space := $Hand.get_child(i)
			space.mouse_filter = Control.MOUSE_FILTER_IGNORE
			space.get_node("PickCard").mouse_filter = Control.MOUSE_FILTER_IGNORE

func _enable_all() -> void:
	for space in $Hand.get_children():
		space.mouse_filter = Control.MOUSE_FILTER_STOP
		space.get_node("PickCard").mouse_filter = Control.MOUSE_FILTER_STOP

func card_select(card_index: int) -> void:
	if current_card != card_index:
		card_deselect()
		current_card = card_index
		card_selected.emit(card_index)

func card_deselect() -> void:
	if current_card >= 0:
		get_space().highlighted = false
		card_deselected.emit(current_card)
		current_card = -1

func card_tap(card_index: int) -> void:
	card_select(card_index)
	get_space().highlighted = true

func card_pick_up(card_area: Area2D, card_index: int) -> void:
	card_dragged.emit(card_area, card_index)
	card_select(card_index)
	get_space().z_boost = true
	_disable_others(card_index)

func card_drop(card_area: Area2D, card_index: int) -> void:
	card_dropped.emit(card_area, card_index)
	card_deselect()
	_enable_all()

## Forces full redraw
func redraw(cards: Array[CardSpec]) -> void:
	for child in $Hand.get_children():
		$Hand.remove_child(child)
		child.queue_free()
	
	for i in len(cards):
		var spec := cards[i]
		if spec == null:
			continue
		
		# TODO: probably need a factory method to prevent the double-init
		var space := CARD_SPACE.instantiate()
		space.card_spec = spec
		space.has_card = true
		$Hand.add_child(space)
		space.card_tapped.connect(card_tap.bind(i))
		space.card_picked_up.connect(card_pick_up.bind(i))
		space.card_dropped.connect(card_drop.bind(i))

	var sep_index := clampi(
		$Hand.get_child_count() - 1,
		0,
		len(SIZE_SCALE) - 1
	)
	var separation: int = SIZE_SCALE[sep_index]
	$Hand.add_theme_constant_override("separation", separation)

func ready() -> void:
	redraw([])
