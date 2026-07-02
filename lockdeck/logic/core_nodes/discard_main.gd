extends Control
## Manages the discard pile

const DISCARD_SELECTED := preload("res://assets/hand/discard_selected.png")
const DISCARD_DESELECTED := preload("res://assets/hand/discard_deselected.png")

## Discard pile pressed
signal discard_pressed()

@export var cards: Array[CardSpec]

@export var show_icon: bool = false:
	set(v):
		show_icon = v
		icon_selected = false
		$CardPile/Label.visible = not show_icon
		$DiscardIcon.visible = show_icon

@export var icon_selected: bool = false:
	set(v):
		icon_selected = v
		if icon_selected:
			$DiscardIcon.texture = DISCARD_SELECTED
		else:
			$DiscardIcon.texture = DISCARD_DESELECTED

@export var listening_for_mouse: bool = false

func do_mouse_enter() -> void:
	if listening_for_mouse:
		icon_selected = true

func do_mouse_exit() -> void:
	if listening_for_mouse:
		icon_selected = false

func count() -> int:
	return len(cards)

## Add multiple cards to the discard pile
func add_cards(dis_cards: Array[CardSpec]) -> void:
	cards.append_array(dis_cards)
	$CardPile.count = len(cards)

func add_card(card: CardSpec) -> void:
	cards.append(card)
	$CardPile.count = len(cards)

## Get all cards from the discard pile
func empty_deck() -> Array[CardSpec]:
	var old_cards: = cards
	cards = []
	$CardPile.count = 0
	return old_cards

func _ready() -> void:
	$CardPile.pile_pressed.connect(discard_pressed.emit)
	$CardPile/Button.mouse_entered.connect(do_mouse_enter)
	$CardPile/Button.mouse_exited.connect(do_mouse_exit)
	$CardPile/Label.rotation = deg_to_rad(-90)
	$CardPile/Label.position = Vector2(-20, 145)
