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
		$DiscardIcon.visible = show_icon

@export var icon_selected: bool = false:
	set(v):
		icon_selected = v
		if icon_selected:
			$DiscardIcon.texture = DISCARD_SELECTED
			update_label(count() + 1)
		else:
			$DiscardIcon.texture = DISCARD_DESELECTED
			update_label()

## Both listening_for_ variables might be unnecessary actually
@export var listening_for_mouse: bool = false

func do_mouse_enter() -> void:
	if listening_for_mouse:
		icon_selected = true

func do_mouse_exit() -> void:
	if listening_for_mouse:
		icon_selected = false

@export var listening_for_drag: bool = false

func _handle_enter_exit(area: Area2D, entered: bool) -> void:
	if not listening_for_drag:
		return
	var parent := area.get_parent()
	if parent is PickCard:
		icon_selected = entered

## Returns true a a card was dragged in this area
func is_dragged_into() -> bool:
	return listening_for_drag and icon_selected

func count() -> int:
	return len(cards)

## Add multiple cards to the discard pile
func add_cards(dis_cards: Array[CardSpec]) -> void:
	cards.append_array(dis_cards)
	$CardPile.count = len(cards)
	update_label()

func add_card(card: CardSpec) -> void:
	cards.append(card)
	$CardPile.count = count()
	update_label()

## Get all cards from the discard pile
func empty_deck() -> Array[CardSpec]:
	var old_cards: = cards
	cards = []
	$CardPile.count = 0
	update_label()
	return old_cards

func update_label(n: int = -1) -> void:
	if n == -1:
		n = count()
	$Label.text = "Discard: %s" % n

func _ready() -> void:
	$CardPile.pile_pressed.connect(discard_pressed.emit)
	$CardPile/Button.mouse_entered.connect(do_mouse_enter)
	$CardPile/Button.mouse_exited.connect(do_mouse_exit)
	$DropArea.area_entered.connect(_handle_enter_exit.bind(true))
	$DropArea.area_exited.connect(_handle_enter_exit.bind(false))
