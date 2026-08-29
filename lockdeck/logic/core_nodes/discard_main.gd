extends Control
## Manages the discard pile

const DISCARD_SELECTED := preload("res://assets/hand/discard_selected.png")
const DISCARD_DESELECTED := preload("res://assets/hand/discard_deselected.png")

## Discard pile pressed
signal discard_pressed()
signal discard_hovered()
signal discard_unhovered()

signal display_cards(Array)

@export var cards: Array[CardSpec]

@export var show_icon: bool = false:
	set(v):
		show_icon = v
		icon_selected = false

@export var icon_selected: bool = false:
	set(v):
		icon_selected = v
		if icon_selected:
			$DiscardIcon.texture = DISCARD_SELECTED
			discard_hovered.emit()
		else:
			$DiscardIcon.texture = DISCARD_DESELECTED
			discard_unhovered.emit()

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

func remove_cards(dis_cards: Array[CardSpec]) -> void:
	for card in dis_cards:
		if card not in cards:
			push_error(
				"Tried to remove card %s [%s] but not in discard!"
				% [card.pick_name, card.unique_id]
			)
			continue
		cards.erase(card)

## Get all cards from the discard pile
func empty_deck() -> Array[CardSpec]:
	var old_cards: = cards
	cards = []
	$CardPile.count = 0
	update_label()
	return old_cards

func bump_label() -> void:
	update_label(count() + 1)

func update_label(n: int = -1) -> void:
	if n == -1:
		n = count()
	$DiscardLabel.text = "Discard: %s" % n

func show_display() -> void:
	display_cards.emit(cards)

func request_tooltip() -> void:
	var rect: Rect2 = $DiscardIcon.get_global_rect()
	if not icon_selected:
		rect = rect.grow_side(Side.SIDE_TOP, -12)
	TooltipManager.request_tooltip(
		rect,
		(
			"This is your discard space. \n\n"
			+ "Drag a pick here or click here with a pick selected to discard it.\n\n"
			+ "After discarding a pick, you will draw from your deck until you have three cards in hand, "
			+ "or your deck is empty.\n\n"
			+ "Discarding a pick counts as using a pick, so your pick can break if you're in your " 
			+ "third turn, pins resting on non-exhausted depths will activate, "
			+ "bombs will go off, etc."
		)
	)

func request_button_tooltip() -> void:
	TooltipManager.request_tooltip(
		$DiscardLabel.get_global_rect().grow_individual(20, 20, 20, 10),
		(
			"This is your discard pile.\n\n"
			+ "Picks used or discarded are kept here. "
			+ "End your turn to shuffle them back into your deck.\n\n"
			+ "Click this button to see all picks currently in your discard pile."
		)
	)

func _ready() -> void:
	$DiscardIcon.discard_icon_clicked.connect(discard_pressed.emit)
	$DiscardIcon.mouse_entered.connect(do_mouse_enter)
	$DiscardIcon.mouse_entered.connect(request_tooltip)
	$DiscardIcon.mouse_exited.connect(do_mouse_exit)
	$DropArea.area_entered.connect(_handle_enter_exit.bind(true))
	$DropArea.area_exited.connect(_handle_enter_exit.bind(false))
	$DiscardLabel.mouse_entered.connect(request_button_tooltip)
	$DiscardLabel.pressed.connect(show_display)
