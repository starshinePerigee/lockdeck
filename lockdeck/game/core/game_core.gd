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

## Holds the most recent active card (even if a card isn't active)
var active_card: CardSpec

func pick_selected(spec: CardSpec) -> void:
	active_card = spec

@onready var _NULL_PICK := CardSpec.from_template(PickTemplates.NULL)
#endregion

#region input handling

## disable all meaningful input (cards and candle)
var _lock_input := false

enum InputState {
	REFRESH_PENDING,  # used to refresh a state
	INACTIVE,
	ACTIVE_SELECT,
	ACTIVE_DRAG,
	VIEW_ALL,
	CARD_DISPLAY,
}
var current_state := InputState.INACTIVE

## This holds the current hover target.
## This can be a card, a pin, or a discardmain
var _current_hover: Control

## If you're clicking, this holds the CardSpace of the selected pick
var _current_space: CardSpace

## this is used to allow de-selecting the current pick
var _previous_space: CardSpace

## If you're dragging, this holds the Area2D of the dragged pick
var _current_area: Area2D

## This holds the current target - either a Pin or DiscardMain
var _current_target: Control

## Returns a list of all valid pick drop targets
## Targets must implement the following:
## get_drop_area, get_mouse_rect, core_highlight, core_unhighlight, core_hover, core_unhover
func valid_targets() -> Array[Control]:
	var targets: Array[Control] = []
	targets.assign($LockBody/CylinderMain/Cylinders.get_valid_refs())
	targets.append($DiscardMain)
	return targets

## returns a list of all mouse hover objects
## Objects must implement the following:
## get_mouse_rect, core_hover, core_unhover
func valid_hovers() -> Array[Control]:
	var hovers: Array[Control] = []
	hovers.append_array($HandMain/Hand.get_spaces())
	hovers.append_array(valid_targets())
	return hovers

func pick_dragged(space: CardSpace) -> void:
	set_state(InputState.ACTIVE_DRAG)
	$Notifications.clear()
	_current_area = space.get_card_area()

func pick_dropped(space: CardSpace) -> void:
	if not _current_area:
		push_error("Pick dropped without being dragged?")
		return
	_current_area = null
	
	if _current_target:
		space.cancel_snapback()
		_do_target()
	
	_current_target = null
	set_state(InputState.INACTIVE)

func pick_clicked(space: CardSpace) -> void:
	if _current_hover is CardSpace:
		space = _current_hover
	else:
		push_warning("Pick clicked without hover?") 
	
	if _previous_space == space:
		_previous_space = null
		return
	
	_current_space = space
	space.set_selected()
	set_state(InputState.ACTIVE_SELECT)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and not event.pressed:
		$Notifications.clear()
		var click: Vector2 = event.global_position
		
		# Handle countdown highlight here while we're here
		if not $LockBody/CountdownMain.get_mouse_rect().has_point(click):
			reset_countdown()
		
		if current_state == InputState.ACTIVE_SELECT:
			for target in valid_targets():
				if target.get_mouse_rect().has_point(click):
					_current_target = target
					_do_target()
			
			if _current_space.get_mouse_rect().has_point(click):
				_previous_space = _current_space
			else:
				_previous_space = null
			
			_current_space.clear_selected()
			_current_space = null
			set_state(InputState.INACTIVE)

func _do_target() -> void:
	unhighlight_target(_current_target)
	if _current_target == $DiscardMain:
		discard_pick()
	elif _current_target is Pin:
		do_pick(
			active_card,
			$LockBody/CylinderMain/Cylinders.get_index_of_ref(_current_target)
		)

func _process(_delta: float) -> void:
	if current_state == InputState.ACTIVE_DRAG:
		if not _current_area:
			push_error("In drag state without active area?")
		elif (
			_current_target
			and _current_area.overlaps_area(_current_target.get_drop_area())
		):
			pass
		else:
			_process_target(true)
	if current_state == InputState.ACTIVE_SELECT:
		if (
			_current_target
			and _current_target.get_mouse_rect().has_point(get_global_mouse_position())
		):
			pass
		else:
			_process_target(false)
	if current_state == InputState.INACTIVE:
		if (
			_current_hover
			and _current_hover.get_mouse_rect().has_point(get_global_mouse_position())
		):
			pass
		else:
			_process_hover()

func _process_target(is_drag: bool) -> void:
	if _current_target:
		unhighlight_target(_current_target)
		_current_target = null
	
	for target in valid_targets():
		if (
			is_drag and _current_area.overlaps_area(target.get_drop_area())
			or target.get_mouse_rect().has_point(get_global_mouse_position())
		):
			_current_target = target
			highlight_target(target)
			return

func _process_hover() -> void:
	if _current_hover:
		unhover_target(_current_hover)
		_current_hover = null
		if $HoverRect.visible:
			$HoverRect.position = Vector2()
			$HoverRect.size = Vector2()
	var global_mouse := get_global_mouse_position()
	for hover in valid_hovers():
		if hover.get_mouse_rect().has_point(global_mouse):
			if $HoverRect.visible:
				$HoverRect.position = hover.get_mouse_rect().position
				$HoverRect.size = hover.get_mouse_rect().size
			_current_hover = hover
			hover_target(hover)
			return

func unhighlight_target(target: Control) -> void:
	target.core_unhighlight()
	if target is Pin:
		$LockBody/IndicatorPick.go_stow()
		$LockBody/CylinderMain.cancel_preview()

func highlight_target(target: Control) -> void:
	target.core_highlight()
	if target is Pin:
		var pin_index: int = $LockBody/CylinderMain/Cylinders.get_index_of_ref(target)
		$LockBody/IndicatorPick.go_index(pin_index)
		$LockBody/CylinderMain.preview(active_card, pin_index)

func unhighlight_all() -> void:
	if _current_target:
		push_warning("nulling current target from unhighlight_all")
		_current_target = null
	if _current_space:
		push_warning("nulling current space from unhighlight_all")
		_current_space.clear_selected()
		_current_space = null
	_current_hover = null
	if $HoverRect.visible:
		$HoverRect.position = Vector2()
		$HoverRect.size = Vector2()
	for space in $HandMain/Hand.get_spaces():
		space.highlighted = false
	for target in valid_targets():
		target.core_unhighlight()
	for hover in valid_hovers():
		hover.core_unhover()

func hover_target(target: Control) -> void:
	target.core_hover()

func unhover_target(target) -> void:
	target.core_unhover()

## used for moving the lock body
@onready var LOCK_BODY_HOME: Vector2 = $LockBody.position 

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
			unhighlight_all()
			$LockBody/IndicatorPick.go_hide()
			$HandMain/Hand.unhide_hand()
			$LockBody.position = LOCK_BODY_HOME
			$PreviousButton.disable = false
			$PreviousButton.show_see_prev = true
			$DiscardMain.show_icon = false
			$LockBody/CylinderMain.cancel_preview()
			reset_countdown()
			dis_en_able_buttons(false)
			$DiscardMain.show_icon = false
		InputState.ACTIVE_SELECT:
			$LockBody/IndicatorPick.go_stow()
			$HandMain/Hand.hide_hand()
			reset_countdown()
			$DiscardMain.show_icon = true
		InputState.ACTIVE_DRAG:
			$LockBody/IndicatorPick.go_stow()
			$HandMain/Hand.hide_hand()
			reset_countdown()
			$DiscardMain.show_icon = true
		InputState.VIEW_ALL:
			$LockBody.global_position = Vector2(
				# 146 is a full pin worth of depths, putting the base at the top
				LOCK_BODY_HOME.x, LOCK_BODY_HOME.y + 146 + 8
			)
			$HandMain/Hand.hide_hand()
			$LockBody/CylinderMain.show_preview(_result)
			$PreviousButton.show_see_prev = false
			dis_en_able_buttons()
		InputState.CARD_DISPLAY:
			$HandMain/Hand.hide_hand()
			dis_en_able_buttons()

# Used for card display and over pop over effects
func dis_en_able_buttons(state: bool = true) -> void:
		$LockBody/CountdownMain.button_disable = (
			state 
			or _lock_input
			or $LockBody/CountdownMain.count <= 0
		)
		$HandMain/Hand.disabled = state or _lock_input
		$TrashMain.disabled = state
		$DeckMain/DeckLabel.disabled = state
		$DiscardMain/DiscardLabel.disabled = state
		$DepthButton.disabled = state

# Used for when you want to continue interacting with the interface,
# such as after unlock
func lock_input(state: bool = true) -> void:
	_lock_input = state
	$LockBody/CountdownMain.button_disable = state
	$HandMain/Hand.disabled = state

func show_failure(state: bool = true) -> void:
	$FailureButton.visible = state
	if state:
		$FailureButton.mouse_filter = MOUSE_FILTER_STOP
	else:
		$FailureButton.mouse_filter = MOUSE_FILTER_IGNORE

# Used for settings
func toggle_active_row(show_row: bool) -> void:
	$LockBody/ActiveBox.visible = show_row
#endregion

#region game functions
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

func view_all_pins() -> void:
	if current_state != InputState.INACTIVE:
		return
	set_state(InputState.VIEW_ALL)

func return_from_view_all() -> void:
	set_state(InputState.INACTIVE)

func reset_countdown():
	$LockBody/CountdownMain.suggest = (
		$HandMain.count() + $DeckMain.count() == 0
		and $LockBody/CountdownMain.count > 0
	)

func update_status_widget() -> void:
	$GameStatus.picks = $DeckMain.count() + $DiscardMain.count() + $HandMain.count()

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

#endregion

#region basic game action building blocks
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

func break_pick(card: CardSpec, surprise := false) -> void:
	$TrashMain.add_card(card)
	if card in $DiscardMain.cards:
		$DiscardMain.remove_card(card)
	elif card in $HandMain.cards:
		$HandMain.remove_card(card)
	elif card in $DeckMain.cards:
		$DeckMain.remove_card(card)
	else:
		push_error(
			"Tried to break card %s [%s] but could not locate!"
			% [card.pick_name, card.unique_id]
		)
	
	if surprise:
		$Notifications.notify(Notifications.SURPRISE)
	else:
		$Notifications.notify(Notifications.BREAK)
	if ($HandMain.count() + $DeckMain.count() + $DiscardMain.count()) == 0:
		game_over()

## Breaks the rightmost card - used for debug
func break_from_hand() -> void:
	if $HandMain.count() == 0:
		return
		
	active_card = $HandMain.cards[-1]
	break_next = true
	discard_pick()

func discard_pick() -> void:
	$LastTest.visible = false
	do_pick(
		_NULL_PICK,
		0,
		active_card
	)
	
	if active_card in $HandMain.cards:
		move_cards_from_hand_to_discard([active_card])
	
	cleanup_step()

func discard_from_deck() -> void:
	if $DeckMain.count() > 0:
		$DiscardMain.add_cards($DeckMain.draw_cards(1))

func discard_hand() -> void:
	$DiscardMain.add_cards($HandMain.remove_all_cards())
#endregion

#region pick activation logic
@onready var _result := EndStepSpec.new()

## Handle all steps from pick activation
func do_pick(card: CardSpec, cylinder: int, break_instead: CardSpec = null) -> void:
	# main pick logic lives here:
	if DEBUG_MODE:
		print("Applying pick %s on cylinder %s" % [card.pick_name, cylinder])
	_result = $LockBody/CylinderMain.execute(card, cylinder)
	
	if card != _NULL_PICK:
		$HandMain.remove_card(card)
		$DiscardMain.add_card(card)
	
	if _result.pick_broke or break_next:
		if break_instead:
			break_pick(break_instead)
		else:
			break_pick(card)
	
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
#endregion

#region game flow
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

## perform the end of turn step once the player clicks the turn candle (if it's valid)
## Like discard, end turn also trips the null pick, although it'll break from deck instead
func end_turn(count_down: bool = true) -> void:
	$Notifications.clear()
	$LastTest.visible = false
	if count_down:
		var all_cards: Array[CardSpec]
		all_cards.append_array($DeckMain.cards)
		all_cards.append_array($DiscardMain.cards)
		all_cards.append_array($HandMain.cards)
		do_pick(
			_NULL_PICK,
			0,
			all_cards.pick_random()
		)
		$LockBody/CountdownMain.count_down()
	$LockBody/CylinderMain.handle_fall()
	discard_hand()
	reload_deck()
	set_state(InputState.REFRESH_PENDING)
	cleanup_step()
	set_state(InputState.INACTIVE)

func game_over() -> void:
	print("Game over.")
	$Notifications.notify(Notifications.FAILURE)
	$LockBody/CountdownMain.game_over()
	lock_input()
	show_failure()
	game_fail.emit()

func solve_lock() -> void:
	$LockBody/ContinueButton.visible = true	
	game_win.emit()
	$LockBody/AnimationPlayer.play("unlock")
	$Notifications.notify(Notifications.UNLOCK)
	lock_input(true)

#endregion

#region setup functions
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
	call_deferred("_set_indicator_box")

func _set_indicator_box() -> void:
	$LockBody/IndicatorPick.mouse_box = (
		$LockBody/CylinderMain/Cylinders.get_valid_global_rect()
	)

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
	$LockBody/ContinueButton.visible = false
	$LockBody/AnimationPlayer.play("RESET")
	$LockBody/CountdownMain.set_count(countdown_time)
	$LockBody/CountdownMain.reset_odds()
	turn_count = 0
	end_turn(false)
	$Notifications.clear()

func _ready() -> void:
	var settings := GameSettings.instance()
	toggle_active_row(settings.highlight_active_row)
	settings.highlight_active_row_changed.connect(toggle_active_row)
	
	$LockBody/ContinueButton.pressed.connect(continue_to_next.emit)
	$FailureButton.pressed.connect(continue_to_failure.emit)

	$HandMain/Hand.card_selected.connect(pick_selected)
	$HandMain/Hand.card_tapped.connect(pick_clicked)
	$HandMain/Hand.card_dragged.connect(pick_dragged)
	$HandMain/Hand.card_dropped.connect(pick_dropped)

	$LockBody/CountdownMain.countdown_triggered.connect(end_turn)
	$LockBody/CountdownMain.countdown_ended.connect(final_turn.emit)
	$PreviousButton.show_previous.connect(view_all_pins)
	$PreviousButton.go_back.connect(return_from_view_all)
	
	$DepthDisplay.closed.connect(set_state.bind(InputState.INACTIVE))
	$CardDisplay.closed.connect(set_state.bind(InputState.INACTIVE))
	$DepthButton.pressed.connect(display_depths)
	$TrashMain.display_cards.connect(display_cards.bind("Broken picks"))
	$DeckMain.display_cards.connect(display_cards.bind("Remaining deck"))
	$DiscardMain.display_cards.connect(display_cards.bind("Discard pile"))

	# if name == "__main__:
	if get_tree().current_scene == self:
		print("Running in debug mode.")
		DEBUG_MODE = true
		var game := GameSpec.get_in_progress_game()
		load_lock(LockGenerator.build_lock(game.next_lock_deck, 4))
		load_game(game)
		draw_cards(5)
