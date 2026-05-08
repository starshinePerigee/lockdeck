@tool
extends Control

@export var card_specs: Dictionary[int, CardSpec] = {}:
	set(v):
		card_specs = v
		
		if not is_node_ready():
			await ready
		
		for i in range(len(space_refs)):
			if i in card_specs:
				space_refs[i].card_spec = card_specs[i]
				space_refs[i].has_card = true
			else:
				space_refs[i].has_card = false

var space_refs: Array[CardSpace] = []

func _ready():
	space_refs = [
		$CardSpace1,
		$CardSpace2,
		$CardSpace3
	]
