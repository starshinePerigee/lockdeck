extends Control

signal game_fail
signal game_win
signal continue_to_next
signal continue_to_failure
signal final_turn

#region game state variables
@export var cylinder_count := 4
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
	CARD_DISPLAY,
	COMPLETE,
	FAILURE
}
var current_state := InputState.INACTIVE

## disable all meaningful input (cards and candle)
var _lock_input := false

## Holds the most recent active card (even if a card isn't active)
var active_card: CardSpec

@onready var _NULL_PICK := CardSpec.from_template(PickTemplates.NULL)
#endregion

## used for moving the lock body
static var LOCK_BODY_HOME := Vector2(216, -143) 

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
			$HandMain.deselect()
			$LockBody.position = LOCK_BODY_HOME
			$PreviousButton.disable = false
			$PreviousButton.show_see_prev = true
			$LockBody/CylinderMain.cancel_preview()
			reset_countdown()
			dis_en_able_buttons(false)
			$DiscardMain.show_icon = false
			$DiscardMain.listening_for_mouse = false
			if not _lock_input:
				$HandMain/Hand.enable_all()
		InputState.COMPLETE:
			lock_input(true)
		InputState.ACTIVE_SELECT:
			$Notifications.clear()
			$LockBody/IndicatorPick.go_stow()
			$HandMain/Hand.hide_hand()
			$PreviousButton.disable = true
			reset_countdown()
			$DiscardMain.show_icon = true
			$DiscardMain.listening_for_mouse = true
		InputState.ACTIVE_DRAG:
			$Notifications.clear()
			$LockBody/IndicatorPick.go_stow()
			$HandMain/Hand.hide_hand()
			$PreviousButton.disable = true
			reset_countdown()
			$DiscardMain.show_icon = true
			$DiscardMain.listening_for_drag = true
		InputState.VIEW_ALL:
			$Notifications.clear()
			$LockBody.global_position = Vector2(
				# 146 is a full pin worth of depths, putting the base at the top
				LOCK_BODY_HOME.x, LOCK_BODY_HOME.y + 146 + 8
			)
			$HandMain/Hand.hide_hand()
			$HandMain/Hand.disable_all()
			$LockBody/CylinderMain.show_preview(_result)
			$PreviousButton.show_see_prev = false
			dis_en_able_buttons()
		InputState.CARD_DISPLAY:
			$Notifications.clear()
			$HandMain/Hand.disable_all()
			$HandMain/Hand.hide_hand()
			$HandMain/Hand.disable_all()
			dis_en_able_buttons()

# Used for card display and over pop over effects
func dis_en_able_buttons(state: bool = true) -> void:
		$LockBody/CountdownMain.button_disable = (
			state 
			or _lock_input
			or $LockBody/CountdownMain.count <= 0
		)
		$TrashMain.disabled = state
		$DeckMain/DeckLabel.disabled = state
		$DiscardMain/DiscardLabel.disabled = state
		$DepthButton.disabled = state

# Used for when you want to continue interacting with the interface,
# such as after unlock
func lock_input(state: bool = true) -> void:
	_lock_input = state
	$LockBody/CountdownMain.button_disable = state
	if state:
		$HandMain/Hand.disable_all()
	else:
		$HandMain/Hand.enable_all()

func show_failure(state: bool = true) -> void:
	$FailureButton.visible = state
	if state:
		$FailureButton.mouse_filter = MOUSE_FILTER_STOP
	else:
		$FailureButton.mouse_filter = MOUSE_FILTER_IGNORE

func game_over() -> void:
	print("Game over.")
	$Notifications.notify(Notifications.FAILURE)
	$LockBody/CountdownMain.game_over()
	lock_input()
	show_failure()
	game_fail.emit()

func display_depths() -> void:
	$DepthDisplay.show_display()
	set_state(InputState.INACTIVE)
	set_state(InputState.CARD_DISPLAY)

func display_cards(cards: Array, header: String) -> void:
	var cards_typed: Array[CardSpec] = []
	cards_typed.assign(cards)
	$CardDisplay.header = header
	$CardDisplay.cards = cards
	$CardDisplay.cards_2 = _already_broken
	$CardDisplay.has_sections = "broken" in header.to_lower()
	
	$CardDisplay.redraw()
	$CardDisplay.show_display()
	set_state(InputState.INACTIVE)
	set_state(InputState.CARD_DISPLAY)

func reset_countdown():
	$LockBody/CountdownMain.suggest = (
		$HandMain.count() + $DeckMain.count() == 0
		and $LockBody/CountdownMain.count > 0
	)

func pick_selected(card: CardSpec) -> void:
	if (
		current_state in [InputState.INACTIVE, InputState.ACTIVE_SELECT] 
		and not _lock_input
	):
		set_state(InputState.ACTIVE_SELECT)
		active_card = card

func pin_cursored(pin_index) -> void:
	if current_state == InputState.ACTIVE_SELECT and not _lock_input:
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
	if current_state == InputState.ACTIVE_DRAG and not _lock_input:
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

func break_pick(card: CardSpec, surprise := false) -> void:
	$TrashMain.add_card(card)
	if card in $HandMain.cards:
		$HandMain.remove_card(card)
	if surprise:
		$Notifications.notify(Notifications.SURPRISE)
	else:
		$Notifications.notify(Notifications.BREAK)
	if ($HandMain.count() + $DeckMain.count() + $DiscardMain.count()) == 0:
		game_over()

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

@onready var _result := EndStepSpec.new()

## Handle all steps from pick activation
func do_pick(card: CardSpec, cylinder: int, break_instead: CardSpec = null) -> void:
	# main pick logic lives here:
	if DEBUG_MODE:
		print("Applying pick %s on cylinder %s" % [card.pick_name, cylinder])
	_result = $LockBody/CylinderMain.execute(card, cylinder)
	
	$HandMain.deselect()
	if card != _NULL_PICK:
		$HandMain.remove_card(card)
	
	if _result.pick_broke or break_next:
		if break_instead:
			break_pick(break_instead)
		else:
			break_pick(card)
	else:
		if card != _NULL_PICK:
			$DiscardMain.add_card(card)
	
	if Effects.TEST in card.get_unique_list():
		$LastTest.update(_result.last_reveal, _result.last_hint)
	else:
		$LastTest.update()
		$LastTest.visible = false
	
	if _result.lock_solved:
		solve_lock()
	else:
		post_pick()
		cleanup_step()

## Perform all the local actions for pick effects
func post_pick() -> void:
	if _result.hand_fumbled:
		$Notifications.notify(Notifications.FUMBLE)
		move_cards_from_hand_to_discard($HandMain.cards.duplicate())
	
	var breaths := _result.breaths_taken
	if breaths > 0:
		# replace the card you just played
		var discard_count: int = min(breaths, $DiscardMain.count())			
		draw_from_discard(discard_count)
		draw_cards(breaths - discard_count + 1)
	
	var deck_breaks := _result.decks_broken
	if deck_breaks > 0:
		var broken_cards = $DeckMain.draw_cards(deck_breaks)
		for card in broken_cards:
			break_pick(card, true)
	
	for __ in _result.picks_twisted:
		$Notifications.notify(Notifications.TWIST)
		discard_from_deck()

func solve_lock() -> void:
	$ContinueButton.visible = true	
	game_win.emit()
	$LockBody/AnimationPlayer.play("unlock")
	$Notifications.notify(Notifications.UNLOCK)
	set_state(InputState.INACTIVE)
	set_state(InputState.COMPLETE)

func reveal_lock() -> void:
	for pin in $LockBody/CylinderMain.pins:
		pin.reveals.fill(PinSpec.RevealLevel.REVEALED)
	$LockBody/CylinderMain.redraw_pins()

func move_cards_from_hand_to_discard(cards: Array[CardSpec]) -> void:
	for card in cards:
		$HandMain.remove_card(card)
		$DiscardMain.add_card(card)

func preview_discard() -> void:
	var preview_step: EndStepSpec = $LockBody/CylinderMain.preview(_NULL_PICK, 0)
	if preview_step.pick_broke or preview_step.decks_broken > 0:
		$TrashMain.bump_label()
	else:
		$DiscardMain.bump_label()
	# I am not handling any other effects here. by god.

func unpreview_discard() -> void:
	$LockBody/CylinderMain.cancel_preview()
	$DiscardMain.update_label()
	$TrashMain.update_label()

func discard_pick() -> void:
	$HandMain.deselect()
	$LastTest.visible = false
	do_pick(
		_NULL_PICK,
		0,
		active_card
	)
	
	if active_card in $HandMain.cards:
		move_cards_from_hand_to_discard([active_card])
	
	cleanup_step()
	set_state(InputState.INACTIVE)

func discard_from_deck() -> void:
	if $DeckMain.count() > 0:
		$DiscardMain.add_cards($DeckMain.draw_cards(1))

## Handle game actions
func cleanup_step() -> void:
	draw_to_five()
	if len($HandMain.cards) == 0 and $LockBody/CountdownMain.count <= 0:
		# You are out of extra time
		game_over()
	else:
		break_next = $LockBody/CountdownMain.end_turn()
	tick_turn_count()
	update_status_widget()

func discard_hand() -> void:
	$DiscardMain.add_cards($HandMain.remove_all_cards())
	

func draw_from_discard(count: int) -> void:
	var discard_count: int = min(count, $DiscardMain.count())
	var discard_shuffled: Array[CardSpec] = $DiscardMain.cards.duplicate()
	discard_shuffled.shuffle()
	var dis_cards: Array[CardSpec] = discard_shuffled.slice(0, discard_count)
	$DiscardMain.remove_cards(dis_cards)
	$HandMain.add_cards(dis_cards)

func draw_cards(count: int) -> void:
	var cards: Array[CardSpec] = $DeckMain.draw_cards(count)
	$HandMain.add_cards(cards)

func draw_to_five() -> void:
	var cards_to_draw: int = hand_size - $HandMain.count()
	if cards_to_draw <= 0:
		return
	draw_cards(cards_to_draw)

## Discards the current hand and draws up to five cards
func draw_new_hand() -> void:
	move_cards_from_hand_to_discard($HandMain.cards)
	draw_cards(hand_size)

## Move discard back into deck
func reload_deck() -> void:
	if $DiscardMain.count() > 0:
		$DeckMain.add_cards($DiscardMain.empty_deck())
		$Notifications.notify(Notifications.RELOAD)

## perform the end of turn step once the player clicks the turn candle (if it's valid)
func end_turn(count_down: bool = true) -> void:
	$Notifications.clear()
	$LastTest.visible = false
	if count_down:
		$LockBody/CountdownMain.count_down()
	$LockBody/CylinderMain.handle_fall()
	discard_hand()
	reload_deck()
	set_state(InputState.REFRESH_PENDING)
	cleanup_step()
	set_state(InputState.INACTIVE)

## Loads the starter hand
func load_deck(deck: Array[CardSpec]) -> void:
	discard_hand()
	reload_deck()
	$DeckMain.clear_all()
	$DeckMain.add_cards(deck)
	update_status_widget()

## loads a lock
func load_lock(lock: LockSpec) -> void:
	cylinder_count = len(lock.pins)
	$LockBody/CylinderMain.load_new_lock(lock)

var _already_broken: Array[CardSpec]

## Loads non-lock parameters from the game spec and restarting the game.
func load_game(game: GameSpec) -> void:
	$GameStatus.coins = game.coins
	$GameStatus.stage = game.lock_number
	$DepthDisplay.update(game.lockset_deck.get_unique_depths())
	load_deck(game.current_deck.duplicate())
	_already_broken = game.broken_picks
	$TrashMain.reset()
	restart()

func restart() -> void:
	lock_input(false)
	show_failure(false)
	$LastTest.visible = false
	$ContinueButton.visible = false
	$LockBody/AnimationPlayer.play("RESET")
	$LockBody/CountdownMain.set_count(countdown_time)
	$LockBody/CountdownMain.reset_odds()
	turn_count = 0
	end_turn(false)
	$Notifications.clear()

func break_from_hand() -> void:
	if $HandMain.count() == 0:
		return
		
	active_card = $HandMain.cards[-1]
	break_next = true
	discard_pick()

func toggle_active_row(show_row: bool) -> void:
	$LockBody/ActiveBox.visible = show_row

func _ready() -> void:
	var settings := GameSettings.instance()
	toggle_active_row(settings.highlight_active_row)
	settings.highlight_active_row_changed.connect(toggle_active_row)
	
	$ContinueButton.pressed.connect(continue_to_next.emit)
	$FailureButton.pressed.connect(continue_to_failure.emit)

	$LockBody/CountdownMain.countdown_triggered.connect(end_turn)
	$LockBody/CountdownMain.countdown_ended.connect(final_turn.emit)
	$HandMain.hand_selected.connect(pick_selected)
	$HandMain.hand_untapped.connect(pick_deselected)
	$HandMain.hand_dragged.connect(pick_dragged)
	$HandMain.hand_super_dragged.connect(pick_superdragged)
	$HandMain.hand_dropped.connect(pick_dropped)
	$PreviousButton.show_previous.connect(view_all_pins)
	$PreviousButton.go_back.connect(return_from_view_all)
	$DiscardMain.discard_hovered.connect(preview_discard)
	$DiscardMain.discard_unhovered.connect(unpreview_discard)
	$BackgroundClick.pressed.connect(bg_cancel)
	
	$DepthDisplay.closed.connect(set_state.bind(InputState.INACTIVE))
	$CardDisplay.closed.connect(set_state.bind(InputState.INACTIVE))
	$DepthButton.pressed.connect(display_depths)
	$TrashMain.display_cards.connect(display_cards.bind("Broken picks"))
	$DeckMain.display_cards.connect(display_cards.bind("Remaining deck"))
	$DiscardMain.display_cards.connect(display_cards.bind("Discard pile"))
	
	$LockBody/CylinderMain/Cylinders.new_pin_hovered.connect(pin_hovered)
	$LockBody/CylinderMain/Cylinders.pin_no_longer_hovered.connect(pin_unhovered)
	$LockBody/CylinderMain/Cylinders.new_pin_cursored.connect(pin_cursored)
	$LockBody/CylinderMain/Cylinders.pin_no_longer_cursored.connect(pin_uncursored)
	$LockBody/CylinderMain/Cylinders.pin_activated.connect(pick_activated)

	# if name == "__main__:
	if get_tree().current_scene == self:
		print("Running in debug mode.")
		DEBUG_MODE = true
		var game := GameSpec.get_in_progress_game()
		load_lock(LockGenerator.build_lock(game.next_lock_deck, 4))
		load_game(game)
