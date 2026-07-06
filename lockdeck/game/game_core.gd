extends Control

signal game_fail
signal game_win

#region game state variables
@export var CYLINDER_COUNT := 4
@export var DIFFICULTY_MOD := 1
@export var DECK_COUNT := 10
@export var HAND_SIZE := 3
@export var COUNTDOWN_TIME := 2
@export var REVEAL_ALL := false

var DEBUG_MODE := false

enum InputState {
	REFRESH_PENDING,  # used to refresh a state
	INACTIVE,
	ACTIVE_SELECT,
	ACTIVE_DRAG,
	VIEW_ALL,
	COMPLETE
}
var current_state := InputState.INACTIVE

## Holds the most recent active card (even if a card isn't active)
var active_card: CardSpec
#endregion

func set_state(state: InputState) -> void:
	if current_state == state:
		return
	current_state = state
	
	match state:
		InputState.REFRESH_PENDING:
			pass
		InputState.INACTIVE:
			$LockBody/IndicatorPick.go_hide()
			$HandMain/Hand.unhide_hand()
			$HandMain/Hand.enable_all()
			$HandMain.deselect()
			$LockBody/CylinderMain.position = Vector2(0, 0)
			$PreviousButton.disable = false
			$PreviousButton.show_see_prev = true
			$LastHint.visible = false
			reset_countdown()
			$CountdownMain.button_disable = false
			$DiscardMain.show_icon = false
			$DiscardMain.listening_for_mouse = false
		InputState.COMPLETE:
			$HandMain/Hand.disable_all()
			$CountdownMain.button_disable = true
		InputState.ACTIVE_SELECT:
			$Notifications.clear()
			$LockBody/IndicatorPick.go_stow()
			$HandMain/Hand.hide_hand()
			$PreviousButton.disable = true
			reset_countdown()
			$CountdownMain.button_disable = true
			$DiscardMain.show_icon = true
			$DiscardMain.listening_for_mouse = true
		InputState.ACTIVE_DRAG:
			$Notifications.clear()
			$LockBody/IndicatorPick.go_stow()
			$HandMain/Hand.hide_hand()
			$PreviousButton.disable = true
			reset_countdown()
			$CountdownMain.button_disable = true
			$DiscardMain.show_icon = true
			$DiscardMain.listening_for_drag = true
		InputState.VIEW_ALL:
			$Notifications.clear()
			$LockBody/CylinderMain.global_position = Vector2(
				$LockBody/CylinderMain.global_position.x, 16
			)
			$HandMain/Hand.hide_hand()
			$HandMain/Hand.disable_all()
			$PreviousButton.show_see_prev = false
			$LastHint.visible = true
			$CountdownMain.button_disable = true

func reset_countdown():
	$CountdownMain.suggest = $HandMain.count() + $DeckMain.count() == 0 

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

func pick_superdragged():
	$LockBody/CylinderMain/Cylinders.force_update()

func pin_hovered(pin_index):
	if current_state == InputState.ACTIVE_DRAG:
		$LockBody/IndicatorPick.go_index(pin_index)

func pin_unhovered():
	if current_state == InputState.ACTIVE_DRAG:
		$LockBody/IndicatorPick.go_stow()

func pick_dropped(_card_area: Area2D, card: CardSpec) -> void:
	var target: int = $LockBody/CylinderMain.get_current_drag_target()
	if target >= 0:
		do_pick(card, target)
	elif $DiscardMain.is_dragged_into():
		discard_pick()
	set_state(InputState.INACTIVE)

func pick_activated(space_index: int) -> void:
	if not current_state in [InputState.ACTIVE_SELECT, InputState.ACTIVE_DRAG]:
		return
	do_pick(active_card, space_index)

func discard_clicked() -> void:
	if current_state != InputState.ACTIVE_SELECT:
		return
	discard_pick()

func break_pick(card: CardSpec) -> void:
	$TrashMain.add_card(card)
	$Notifications.notify(Notifications.BREAK)
	if ($HandMain.count() + $DeckMain.count() + $DiscardMain.count()) == 0:
		$Notifications.notify(Notifications.FAILURE)
		game_fail.emit()

func view_all_pins() -> void:
	if current_state != InputState.INACTIVE:
		return
	set_state(InputState.VIEW_ALL)

func return_from_view_all() -> void:
	set_state(InputState.INACTIVE)

## the background is clicked so back out of whatever:
func bg_cancel() -> void:
	$Notifications.clear()
	set_state(InputState.REFRESH_PENDING)
	set_state(InputState.INACTIVE)

## Handle all steps from pick activation
func do_pick(card: CardSpec, cylinder: int) -> void:
	# main pick logic lives here:
	if DEBUG_MODE:
		print("Applying pick %s on cylinder %s" % [card.pick_name, cylinder])
	var result: ResultSpec = $LockBody/CylinderMain.execute(card, cylinder)
	
	$HandMain.deselect()
	$HandMain.remove_card(card)
	if result.pick_broke:
		break_pick(card)
	else:
		$DiscardMain.add_card(card)
	
	if result.last_hint:
		$LastHint.text = "Last hint: %s" % result.last_hint
	else:
		$LastHint.text = "No hints last turn"
	
	if result.lock_solved:
		game_win.emit()
		$Notifications.notify(Notifications.UNLOCK)
		set_state(InputState.INACTIVE)
		set_state(InputState.COMPLETE)
	else:
		draw_to_five()

func discard_pick() -> void:
	$HandMain.deselect()
	$HandMain.remove_card(active_card)
	$DiscardMain.add_card(active_card)
	draw_to_five()
	set_state(InputState.INACTIVE)

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
func end_turn(count_down: bool = true) -> void:
	$Notifications.clear()
	if count_down:
		$CountdownMain.count_down()
	$LockBody/CylinderMain.handle_fall()
	discard_hand()
	reload_deck()
	draw_new_hand()
	set_state(InputState.REFRESH_PENDING)
	set_state(InputState.INACTIVE)

## Loads the starter hand
func load_starter_deck() -> void:
	discard_hand()
	reload_deck()
	
	$DeckMain.clear_all()
	$DeckMain.add_cards(PickGenerator.get_standard_test_hand(DECK_COUNT))
	print("Loaded default %s cards." % DECK_COUNT)

func add_random_cards(count: int = 1) -> void:
	var cards := PickGenerator.get_many_base_cards(2)
	$DeckMain.add_cards(cards)
	for card in cards:
		print("Added new pick: %s." % card.pick_name)

func restart() -> void:
	$LockBody/CylinderMain.load_new_pins(
		PinGenerator.build_real_lock(CYLINDER_COUNT, DIFFICULTY_MOD)
	)
	$CountdownMain.set_count(COUNTDOWN_TIME)
	end_turn(false)
	$Notifications.clear()
	$LastHint.text = "No picks played yet."

func _ready() -> void:
	$CountdownMain.countdown_triggered.connect(end_turn)
	$HandMain.hand_selected.connect(pick_selected)
	$HandMain.hand_untapped.connect(pick_deselected)
	$HandMain.hand_dragged.connect(pick_dragged)
	$HandMain.hand_super_dragged.connect(pick_superdragged)
	$HandMain.hand_dropped.connect(pick_dropped)
	$PreviousButton.show_previous.connect(view_all_pins)
	$PreviousButton.go_back.connect(return_from_view_all)
	$DiscardMain.discard_pressed.connect(discard_clicked)
	$BackgroundClick.pressed.connect(bg_cancel)
	
	$LockBody/CylinderMain/Cylinders.new_pin_hovered.connect(pin_hovered)
	$LockBody/CylinderMain/Cylinders.pin_no_longer_hovered.connect(pin_unhovered)
	$LockBody/CylinderMain/Cylinders.new_pin_cursored.connect(pin_cursored)
	$LockBody/CylinderMain/Cylinders.pin_no_longer_cursored.connect(pin_uncursored)
	$LockBody/CylinderMain/Cylinders.pin_activated.connect(pick_activated)

	# if name == "__main__:
	if get_tree().current_scene == self:
		print("Running in debug mode.")
		DEBUG_MODE = true
		$DeckMain.add_cards(PickGenerator.get_standard_test_hand(DECK_COUNT))
		restart()
