@tool
extends HBoxContainer

signal card_activated(card_index: int, card_spec: CardSpec)

const SPACE_COUNT = 5

var space_refs: Array[CardSpace] = []

@export var space_count: int = SPACE_COUNT:
	set(v):
		space_count = v
		
		if not is_node_ready():
			await ready
		
		redraw()

@export var cards: Dictionary[int, CardSpec] = {}:
	set(v):
		cards = v
		
		if not is_node_ready():
			await ready
			
		redraw()

func handle_click(card_index: int):
	card_activated.emit(card_index, space_refs[card_index].card_spec)

func redraw():
	if len(space_refs) == 0:
			return
			
	for i in range(SPACE_COUNT):
		space_refs[i].closed = i >= space_count
		if i in cards:
			space_refs[i].card_spec = cards[i]
			space_refs[i].has_card = true
		else:
			space_refs[i].has_card = false

func _ready() -> void:
	space_refs = [
		$CardSpace1,
		$CardSpace2,
		$CardSpace3,
		$CardSpace4,
		$CardSpace5
	]
	
	for i in range(len(space_refs)):
		var bound_click = handle_click.bind(i)  # owo
		space_refs[i].card_pressed.connect(bound_click)
	
	space_count = SPACE_COUNT
	redraw()
