extends Control
#
signal game_fail
signal game_win

#region game state variables
@export var CYLINDER_COUNT := 4
@export var DECK_COUNT := 10
@export var HAND_SIZE := 3
@export var COUNTDOWN_TIME := 2
@export var REVEAL_ALL := false

enum InputState {
	INACTIVE,
	ACTIVE_SELECT,
	ACTIVE_DRAG
}
var current_state := InputState.INACTIVE

## Holds the most recent active card (even if a card isn't active)
var active_card: CardSpec
#endregion

var card_is_selected := false

func set_state(state: InputState) -> void:
	if current_state == state:
		return
	print("Set state: %s" % state)
	current_state = state
	
	match state:
		InputState.INACTIVE:
			$LockBody/IndicatorPick.go_hide()
		InputState.ACTIVE_SELECT:
			$LockBody/IndicatorPick.go_stow()
			$Notifications.clear()
		InputState.ACTIVE_DRAG:
			$LockBody/IndicatorPick.go_stow()
			$Notifications.clear()

func pick_selected(card: CardSpec) -> void:
	if current_state == InputState.INACTIVE:
		set_state(InputState.ACTIVE_SELECT)
		active_card = card

func pin_cursored(pin_index) -> void:
	if current_state == InputState.ACTIVE_SELECT:
		$LockBody/IndicatorPick.go_index(pin_index)
		
func pin_uncursored() -> void:
	if current_state == InputState.ACTIVE_SELECT:
		$LockBody/IndicatorPick.go_stow()

func pick_deselected() -> void:
	set_state(InputState.INACTIVE)

func pick_dragged(_card_area: Area2D, card: CardSpec) -> void:
	set_state(InputState.ACTIVE_DRAG)
	active_card = card

func pin_hovered(pin_index):
	if current_state == InputState.ACTIVE_DRAG:
		$LockBody/IndicatorPick.go_index(pin_index)

func pin_unhovered():
	if current_state == InputState.ACTIVE_DRAG:
		$LockBody/IndicatorPick.go_stow()

func pick_dropped(card_area: Area2D, card: CardSpec) -> void:
	set_state(InputState.INACTIVE)
	var target: int = $LockBody/CylinderMain.get_current_drag_target()
	if target >= 0:
		do_pick(card, target)

func pick_activated(space_index: int) -> void:
	if current_state == InputState.INACTIVE:
		return
	do_pick(active_card, space_index)

func break_pick(card: CardSpec) -> void:
	$TrashMain.add_card(card)
	$Notifications.notify(Notifications.BREAK)
	if ($HandMain.count() + $DeckMain.count() + $DiscardMain.count()) == 0:
		$Notifications.notify(Notifications.FAILURE)
		game_fail.emit()

## Handle all steps from pick activation
func do_pick(card: CardSpec, cylinder: int) -> void:
	# main pick logic lives here:
	print("Applying pick %s on cylinder %s" % [card.pick_name, cylinder])
	var result: ResultSpec = $LockBody/CylinderMain.execute(card, cylinder)
	
	$HandMain.deselect()
	$HandMain.remove_card(card)
	if result.pick_broke:
		break_pick(card)
	else:
		$DiscardMain.add_card(card)
	
	if result.lock_solved:
		game_win.emit()
		$Notifications.notify(Notifications.UNLOCK)
	
	draw_to_five()
	$CountdownMain.highlight = $HandMain.count() == 0

func discard_hand() -> void:
	$DiscardMain.add_cards($HandMain.load_new_hand())

func draw_to_five() -> void:
	var cards_to_draw: int = HAND_SIZE - $HandMain.count()
	if cards_to_draw <= 0:
		return
	$HandMain.add_cards($DeckMain.draw_cards(cards_to_draw))

## Discards the current hand and draws up to five cards
func draw_new_hand() -> void:
	var extra_cards: Array[CardSpec] = $HandMain.load_new_hand(
		$DeckMain.draw_cards(HAND_SIZE)
	)
	if len(extra_cards) > 0:
		push_warning("%s extra cards in hand after drawing.")
		$DiscardMain.add_cards(extra_cards)

## Move discard back into deck
func reload_deck() -> void:
	if $DiscardMain.count() > 0:
		$DeckMain.add_cards($DiscardMain.empty_deck())
		$Notifications.notify(Notifications.RELOAD)

## perform the end of turn step once the player clicks the discard (if it's valid)
func end_turn() -> void:
	$Notifications.clear()
	$CountdownMain.highlight = false
	$CountdownMain.count_down()
	$LockBody/CylinderMain.reset_all_pins()
	discard_hand()
	reload_deck()
	draw_new_hand()

func _ready() -> void:
	$CountdownMain.countdown_pressed.connect(end_turn)
	$HandMain.hand_selected.connect(pick_selected)
	$HandMain.hand_deselected.connect(pick_deselected)
	$HandMain.hand_dragged.connect(pick_dragged)
	$HandMain.hand_dropped.connect(pick_dropped)
	
	$LockBody/CylinderMain/Cylinders.new_pin_hovered.connect(pin_hovered)
	$LockBody/CylinderMain/Cylinders.pin_no_longer_hovered.connect(pin_unhovered)
	$LockBody/CylinderMain/Cylinders.new_pin_cursored.connect(pin_cursored)
	$LockBody/CylinderMain/Cylinders.pin_no_longer_cursored.connect(pin_uncursored)
	$LockBody/CylinderMain/Cylinders.pin_activated.connect(pick_activated)

	$Notifications.clear()
	$LockBody/CylinderMain.load_new_pins(PinGenerator.build_test_lock(CYLINDER_COUNT))
	$CountdownMain.set_count(COUNTDOWN_TIME)

	$DeckMain.add_cards(PickGenerator.get_standard_test_hand(DECK_COUNT))
	draw_new_hand()
