extends Control
# The view for the hand and all the cards in it

## Raised when a card is clicked or a drag starts
signal card_selected(card: CardSpec)

signal card_tapped(space: CardSpace)
signal card_dragged(space: CardSpace)
signal card_dropped(space: CardSpace)

const CARD_SPACE := preload("res://objects/card/card_space.tscn")
# starts at "1 card"
const CARD_WIDTH := 128
const SIZE_SCALE := [0, 25, 15, 0, -10, -25, -40, -52, -60, -66, -70, -73, -75]
const HIDE_OFFSET := 102
const HIDE_PIXELS_PER_SEC := 680

## Disables meaningful card interactions
var disabled := false:
	set(v):
		disabled = v
		for child in $Hand.get_children():
			child.disabled = disabled

var _tween: Tween = null

## Hides (moves out of the way) the hand
func hide_hand() -> void:
	if _tween:
		_tween.kill()
	
	_tween = create_tween()
	$Hand.position = Vector2(0, HIDE_OFFSET)

func unhide_hand() -> void:
	$Hand.position = Vector2(0, 0)

## Forces full redraw
func redraw(cards: Array[CardSpec]) -> void:
	for child in $Hand.get_children():
		$Hand.remove_child(child)
		child.queue_free()
	
	# we gotta do this shit manually for dumb godot reasons
	var sep_index := clampi(len(cards) - 1, 0,len(SIZE_SCALE) - 1)
	var separation: int = SIZE_SCALE[sep_index]
	var space_delta := CARD_WIDTH + separation
	var total_size := len(cards) * space_delta
	var start_pos := ((size.x - total_size) - 64) / 2
	
	for i in len(cards):
		var spec := cards[i]
		if spec == null:
			continue
		
		var space := CARD_SPACE.instantiate()
		space.card_spec = spec
		space.has_card = true
		space.z_index = 100 * i
		space.position.x = start_pos + ((CARD_WIDTH + separation) * i)
		
		space.card_tapped.connect(card_selected.emit.bind(spec))
		space.card_picked_up.connect(card_selected.emit.bind(spec))
		space.card_tapped.connect(card_tapped.emit.bind(space))
		space.card_picked_up.connect(card_dragged.emit.bind(space))
		space.card_dropped.connect(card_dropped.emit.bind(space))
		
		$Hand.add_child(space)

func get_spaces() -> Array[CardSpace]:
	var spaces: Array[CardSpace] = []
	for space in $Hand.get_children():
		if space is CardSpace:
			spaces.append(space)
	return spaces

func _ready() -> void:
	redraw([])
	if get_tree().current_scene == self:
		redraw(PickGenerator.get_many_base_cards(7))
