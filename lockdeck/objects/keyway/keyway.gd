extends HBoxContainer
## Keyway is the series of drop targets that pick cards are played to. 

# Don't get too attached - this logic might move entirely to cylinders after we rearrange the 
# play area, and the player just drags the cards directly on to the cylinder.
# Still this is a fine stopgap for now.

var space_refs: Array[CardSpace] = []

@export var space_count: int = PinSpec.CYLINDER_COUNT_MAX:
	set(v):
		space_count = v
		
		if not is_node_ready():
			await ready
		
		redraw()

## Updates the card spaces
func redraw():
	for i in range(0, space_count):
		space_refs[i].can_drop = true
		space_refs[i].closed = false
	
	for i in range(space_count, PinSpec.CYLINDER_COUNT_MAX):
		space_refs[i].can_drop = false
		space_refs[i].closed = true

func _ready() -> void:
	space_refs = [
		$CardSpace1,
		$CardSpace2,
		$CardSpace3,
		$CardSpace4,
		$CardSpace5
	]
	redraw()
