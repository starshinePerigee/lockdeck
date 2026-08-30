extends Control
# The view for the hand and all the cards in it

## Raised when a card is clicked or a drag starts
signal card_selected(card: CardSpec)

## Holds live references to every card in this hand
var space_refs: Array[CardSpace]

const CARD_SPACE := preload("res://objects/card/card_space.tscn")
# starts at "1 card"
const SIZE_SCALE := [0, 25, 15, 0, -10, -25, -40, -52, -60, -66, -70, -73, -75]
const HIDE_OFFSET := 102

## Hides (moves out of the way) the hand
func hide_hand() -> void:
	$Hand.position = Vector2(0, HIDE_OFFSET)

func unhide_hand() -> void:
	$Hand.position = Vector2(0, 0)

## Forces full redraw
func redraw(cards: Array[CardSpec]) -> void:
	space_refs = []
	for child in $Hand.get_children():
		$Hand.remove_child(child)
		child.queue_free()
	
	for i in len(cards):
		var spec := cards[i]
		if spec == null:
			continue
		
		var space := CARD_SPACE.instantiate()
		space.card_spec = spec
		space.has_card = true
		space.z_index = 100 * i
		space.card_tapped.connect(card_selected.emit.bind(spec))
		space.card_picked_up.connect(card_selected.emit.bind(spec))
		$Hand.add_child(space)
		space_refs.append(space)

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
