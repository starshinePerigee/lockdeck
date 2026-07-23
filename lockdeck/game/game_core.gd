extends Control

signal game_fail
signal game_win

#region game state variables
@export var cylinder_count := 4
@export var difficulty_mod := 1
@export var deck_count := 10
@export var hand_size := 3
@export var countdown_time := 2

var DEBUG_MODE := false

var turn_count := -1

func tick_turn_count() -> void:
	if turn_count < 0:
		push_warning("Turn count never initialized!")
		turn_count = 0
	turn_count += 1
	if DEBUG_MODE:
		print("-- turn %s --" % turn_count)

## Holds if the countdown mechanics are calling for a break next turn
var break_next: bool

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

## used for moving the lock body
var lock_body_start_pos: Vector2

func set_state(state: InputState) -> void:
	if current_state == state:
		if DEBUG_MODE:
			print("Already in state %s" % InputState.find_key(state))
		return
	
	if DEBUG_MODE:
		print("Entering state %s" % InputState.find_key(state))
	current_state = state
	
	match state:
		InputState.REFRESH_PENDING:
			pass
		InputState.INACTIVE:
			$LockBody/IndicatorPick.go_hide()
			$HandMain/Hand.unhide_hand()
			$HandMain/Hand.enable_all()
			$HandMain.deselect()
			$LockBody.position = lock_body_start_pos
			$PreviousButton.disable = false
			$PreviousButton.show_see_prev = true
			$PreviousButton/LastHint.visible = false
			$LockBody/CylinderMain.cancel_preview()
			$LockBody/CylinderMain/Cylinders.set_previouses_visibility(false)
			reset_countdown()
			$LockBody/CountdownMain.button_disable = false
			$DiscardMain.show_icon = false
			$DiscardMain.listening_for_mouse = false
		InputState.COMPLETE:
			$HandMain/Hand.disable_all()
			$LockBody/CountdownMain.button_disable = true
		InputState.ACTIVE_SELECT:
			$Notifications.clear()
			$LockBody/IndicatorPick.go_stow()
			$HandMain/Hand.hide_hand()
			$PreviousButton.disable = true
			reset_countdown()
			$LockBody/CountdownMain.button_disable = true
			$DiscardMain.show_icon = true
			$DiscardMain.listening_for_mouse = true
		InputState.ACTIVE_DRAG:
			$Notifications.clear()
			$LockBody/IndicatorPick.go_stow()
			$HandMain/Hand.hide_hand()
			$PreviousButton.disable = true
			reset_countdown()
			$LockBody/CountdownMain.button_disable = true
			$DiscardMain.show_icon = true
			$DiscardMain.listening_for_drag = true
		InputState.VIEW_ALL:
			$Notifications.clear()
			$LockBody.global_position = Vector2(
				# 146 is a full pin worth of depths, putting the base at the top
				lock_body_start_pos.x, lock_body_start_pos.y + 146 + 8
			)
			$HandMain/Hand.hide_hand()
			$HandMain/Hand.disable_all()
			$PreviousButton.show_see_prev = false
			$PreviousButton/LastHint.visible = true
			$LockBody/CylinderMain/Cylinders.set_previouses_visibility(true)
			$LockBody/CountdownMain.button_disable = true

func reset_countdown():
	$LockBody/CountdownMain.suggest = $HandMain.count() + $DeckMain.count() == 0 

func pick_selected(card: CardSpec) -> void:
	if current_state == InputState.INACTIVE:
		set_state(InputState.ACTIVE_SELECT)
		active_card = card

func pin_cursored(pin_index) -> void:
	if current_state == InputState.ACTIVE_SELECT:
		$LockBody/IndicatorPick.go_index(pin_index)
		$LockBody/CylinderMain.preview(active_card, pin_index)
		
func pin_uncursored() -> void:
	if current_state == InputState.ACTIVE_SELECT:
		$LockBody/IndicatorPick.go_stow()
		$LockBody/CylinderMain.cancel_preview()

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
		$LockBody/CylinderMain.preview(active_card, pin_index)

func pin_unhovered():
	if current_state == InputState.ACTIVE_DRAG:
		$LockBody/IndicatorPick.go_stow()
		$LockBody/CylinderMain.cancel_preview()

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
	set_state(InputState.INACTIVE)

func discard_clicked() -> void:
	if current_state != InputState.ACTIVE_SELECT:
		return
	discard_pick()

func break_pick(card: CardSpec) -> void:
	$TrashMain.add_card(card)
	$Notifications.notify(Notifications.BREAK)
	if ($HandMain.count() + $DeckMain.count() + $DiscardMain.count()) == 0:
		$Notifications.notify(Notifications.FAILURE)
		set_state(InputState.COMPLETE)
		game_fail.emit()

func view_all_pins() -> void:
	if current_state != InputState.INACTIVE:
		return
	set_state(InputState.VIEW_ALL)

func return_from_view_all() -> void:
	set_state(InputState.INACTIVE)

func update_status_widget() -> void:
	$GameStatus.picks = $DeckMain.count() + $DiscardMain.count() + $HandMain.count()

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
	var result: EndStepSpec = $LockBody/CylinderMain.execute(card, cylinder)
	
	$HandMain.deselect()
	$HandMain.remove_card(card)
	if result.pick_broke or break_next:
		break_pick(card)
	else:
		$DiscardMain.add_card(card)
	
	$LockBody/CylinderMain/Cylinders.load_previouses(result)
	if result.last_hint:
		$PreviousButton/LastHint.text = "Last hint: %s" % result.last_hint
	else:
		$PreviousButton/LastHint.text = "No hints last turn"
	
	if result.lock_solved:
		game_win.emit()
		$LockBody/AnimationPlayer.play("unlock")
		$Notifications.notify(Notifications.UNLOCK)
		set_state(InputState.INACTIVE)
		set_state(InputState.COMPLETE)
	else:
		cleanup_step()

func discard_pick() -> void:
	$HandMain.deselect()
	$HandMain.remove_card(active_card)
	if break_next:
		break_pick(active_card)
	else:
		$DiscardMain.add_card(active_card)
	cleanup_step()
	set_state(InputState.INACTIVE)

func cleanup_step() -> void:
	draw_to_five()
	break_next = $LockBody/CountdownMain.end_turn()
	tick_turn_count()
	update_status_widget()

func discard_hand() -> void:
	$DiscardMain.add_cards($HandMain.load_new_hand())

func draw_to_five() -> void:
	var cards_to_draw: int = hand_size - $HandMain.count()
	if cards_to_draw <= 0:
		return
	$HandMain.add_cards($DeckMain.draw_cards(cards_to_draw))

## Discards the current hand and draws up to five cards
func draw_new_hand() -> void:
	var extra_cards: Array[CardSpec] = $HandMain.load_new_hand(
		$DeckMain.draw_cards(hand_size)
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
		$LockBody/CountdownMain.count_down()
	$LockBody/CylinderMain.handle_fall()
	discard_hand()
	reload_deck()
	set_state(InputState.REFRESH_PENDING)
	cleanup_step()
	set_state(InputState.INACTIVE)

## Loads the starter hand
func load_starter_deck() -> void:
	discard_hand()
	reload_deck()
	
	$DeckMain.clear_all()
	$DeckMain.add_cards(PickGenerator.get_standard_test_hand(deck_count))
	print("Loaded default %s cards." % deck_count)
	update_status_widget()

func add_random_cards(count: int = 1) -> void:
	var cards := PickGenerator.get_many_base_cards(count)
	$DeckMain.add_cards(cards)
	for card in cards:
		print("Added new pick: %s." % card.pick_name)
	update_status_widget()

func restart() -> void:
	$LockBody/AnimationPlayer.play("RESET")
	$LockBody/CylinderMain.load_new_pins(
		PinGenerator.build_real_lock(cylinder_count, difficulty_mod)
	)
	$LockBody/CountdownMain.set_count(countdown_time)
	$LockBody/CountdownMain.reset_odds()
	turn_count = 0
	end_turn(false)
	$Notifications.clear()
	$PreviousButton/LastHint.text = "No picks yet"

func _ready() -> void:
	$LockBody/CountdownMain.countdown_triggered.connect(end_turn)
	$HandMain.hand_selected.connect(pick_selected)
	$HandMain.hand_untapped.connect(pick_deselected)
	$HandMain.hand_dragged.connect(pick_dragged)
	$HandMain.hand_super_dragged.connect(pick_superdragged)
	$HandMain.hand_dropped.connect(pick_dropped)
	$PreviousButton.show_previous.connect(view_all_pins)
	$PreviousButton.go_back.connect(return_from_view_all)
	lock_body_start_pos = $LockBody.global_position
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
		$DeckMain.add_cards(PickGenerator.get_standard_test_hand(deck_count))
		restart()
