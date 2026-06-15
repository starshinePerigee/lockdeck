extends HBoxContainer
## Keyway is the series of drop targets that pick cards are played to. 

# Don't get too attached - this logic might move entirely to cylinders after we rearrange the 
# play area, and the player just drags the cards directly on to the cylinder.
# Still this is a fine stopgap for now.

## Emitted when a space is actiavted (either by clicking or dropping)
signal space_activated(space_index: int)

var space_refs: Array[CardSpace] = []

@export var space_count: int = PinSpec.CYLINDER_COUNT_MAX:
	set(v):
		space_count = v
		redraw()

func _handle_click(index: int) -> void:
	if index < space_count:
		space_activated.emit(index)

## Gets the first space that collides with the given card_area
func _get_first_collision(card_area: Area2D, exclude: int = -1) -> int:
	var collisions := card_area.get_overlapping_areas()
	for i in len(space_refs):
		if i == exclude:
			continue
		if space_refs[i].get_area() in collisions:
			return i
	return -1

func check_drop(card_area: Area2D) -> void:
	var i := _get_first_collision(card_area)
	if i > -1 and i < space_count:
		space_activated.emit(i)

# TODO: There is a bug where highlights can persist if you release a card in the
# hysteresis area.

func first_highlight(_card_area: Area2D, index: int) -> void:
	for i in space_count:
		if i != index:
			space_refs[i].can_drop = false

func unhighlight(card_area: Area2D, index: int) -> void:
	for i in space_count:
		space_refs[i].can_drop = true
	var c := _get_first_collision(card_area, index)
	if c > -1 and c < space_count:
		space_refs[c].set_highlight()

## Updates the card spaces
func redraw():
	if not is_node_ready():
		await ready

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
	for i in len(space_refs):
		space_refs[i].area_clicked.connect(_handle_click.bind(i))
		space_refs[i].drag_entered.connect(first_highlight.bind(i))
		space_refs[i].drag_exited.connect(unhighlight.bind(i))
	redraw()
