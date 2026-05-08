@tool
extends HBoxContainer

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
	space_count = SPACE_COUNT
	redraw()
