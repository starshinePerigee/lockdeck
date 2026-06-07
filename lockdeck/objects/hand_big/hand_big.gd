@tool
extends Container

signal card_selected(card_spec: CardSpec, card_index: int)
signal card_dropped(card_spec: CardSpec, card_area: Area2D, card_index: int)
signal card_deselected(card_index: int)

const CARD_SPACE = preload("res://objects/card/card_space.tscn")
# starts at "1 card"
const SIZE_SCALE = [0, 25, 20, 15, 10, 0, -5, -10, -15, -20, -25]

# this performs like pants
# TODO: make this not rebuild every card every time it changes
@export var cards: Array[CardSpec] = []:
	set(v):
		cards = v
		for i in len(cards):
			if cards[i] == null:
				cards[i] = CardSpec.new()
		current_card = -1
		_redraw()

@export var current_card: int = -1

func get_space() -> CardSpace:
	return $Hand.get_children()[current_card]

func card_select(card_index: int) -> void:
	if current_card != card_index:
		card_deselect()
		current_card = card_index
		card_selected.emit(cards[card_index], card_index)

func card_deselect() -> void:
	if current_card >= 0:
		get_space().highlighted = false
		card_deselected.emit(current_card)
		current_card = -1

func card_tap(card_index: int) -> void:
	card_select(card_index)
	get_space().highlighted = true

func card_pick_up(card_index: int) -> void:
	card_select(card_index)
	get_space().z_boost = true

func card_drop(card_area: Area2D, card_index: int) -> void:
	card_dropped.emit(cards[card_index], card_area, card_index)
	card_deselect()

func _redraw() -> void:
	"""Force a full redraw"""
	if not is_node_ready():
		await ready
		
	for child in $Hand.get_children():
		$Hand.remove_child(child)
		child.queue_free()
	
	for i in len(cards):
		var spec := cards[i]
		# TODO: probably need a factory method to prevent the double-init
		var space := CARD_SPACE.instantiate()
		space.card_spec = spec
		space.has_card = true
		$Hand.add_child(space)
		space.card_tapped.connect(card_tap.bind(i))
		space.card_picked_up.connect(card_pick_up.bind(i))
		space.card_dropped.connect(card_drop.bind(i))

	var space_index = clampi(
		$Hand.get_child_count() - 1,
		0,
		len(SIZE_SCALE)
	)
	var space: int = SIZE_SCALE[space_index]
	$Hand.add_theme_constant_override("separation", space)

func _ready() -> void:
	_redraw()
