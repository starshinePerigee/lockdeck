@tool
extends HBoxContainer

signal card_selected(card_spec: CardSpec, card_index: int)

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
		_redraw()

@export var current_highlight: int = -1:
	set(v):
		if current_highlight < len(cards) and current_highlight >= 0:
			get_children()[current_highlight].highlighted = false
		current_highlight = v
		if current_highlight < len(cards) and current_highlight >= 0:
			get_children()[current_highlight].highlighted = true

func reset_highlight():
	current_highlight = -1

func card_select(card_index: int):
	current_highlight = card_index
	card_selected.emit(cards[card_index], card_index)

func _redraw() -> void:
	"""Force a full redraw"""
	if not is_node_ready():
		await ready
		
	for child in get_children():
		remove_child(child)
		child.queue_free()
	
	for i in len(cards):
		var spec := cards[i]
		# TODO: probably need a factory method to prevent the double-init
		var space := CARD_SPACE.instantiate()
		space.card_spec = spec
		space.has_card = true
		add_child(space)
		space.card_pressed.connect(card_select.bind(i))

	var space_index = clampi(
		get_child_count() - 1,
		0,
		len(SIZE_SCALE)
	)
	var space: int = SIZE_SCALE[space_index]
	add_theme_constant_override("separation", space)

func _ready() -> void:
	_redraw()
