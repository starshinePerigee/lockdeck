extends Control
# The view for the hand and all the cards in it

signal card_selected(card_index: int)

signal card_untapped()
signal card_dragged(card_area: Area2D, card_index: int)
signal card_definitive_dragged()
signal card_dropped(card_area: Area2D, card_index: int)

const CARD_SPACE := preload("res://objects/card/card_space.tscn")
# starts at "1 card"
const SIZE_SCALE := [0, 25, 15, 0, -10, -25, -40, -52, -60, -66, -70, -73, -75]
const HIDE_OFFSET := 102

func get_card_refs() -> Array[CardSpace]:
	var spaces: Array[CardSpace] = []
	for child in $Hand.get_children():
		if child is CardSpace:
			spaces.append(child)
	return spaces

## Hides (moves out of the way) the hand
func hide_hand() -> void:
	$Hand.position = Vector2(0, HIDE_OFFSET)

func unhide_hand() -> void:
	$Hand.position = Vector2(0, 0)

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
		space.z_index = 100 * i
		$Hand.add_child(space)

	var sep_index := clampi(
		$Hand.get_child_count() - 1,
		0,
		len(SIZE_SCALE) - 1
	)
	var separation: int = SIZE_SCALE[sep_index]
	$Hand.add_theme_constant_override("separation", separation)
	size = $Hand.size

func ready() -> void:
	redraw([])
