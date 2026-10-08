extends Control
class_name GameCore

signal game_fail
signal game_win
signal continue_to_next
signal continue_to_failure
signal final_turn
signal pick_broke
signal turn_ended
signal new_state(state_spec: StateSpec)
signal animation_complete

#region game state variables
var hand_size := 3
var starting_countdown_time := 2

@onready var DEBUG_MODE := OS.is_debug_build()

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
	INACTIVE,
	ANIMATING,
	ACTIVE_SELECT,
	ACTIVE_DRAG,
	VIEW_ALL,
	CARD_DISPLAY,
}
var current_state := InputState.INACTIVE

## This holds the current hover target.
## This can be a card, a pin, or a discardmain
var _current_hover: Control

## this holds the CardSpace of the selected pick for clicking or dragging
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
	if not $DiscardMain.disable_discard: 
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

const FX_CARD_SELECT := preload("res://assets/fx/hand_select.ogg")
const FX_CARD_DESELECT := preload("res://assets/fx/hand_deselect.ogg")
const FX_CARD_DISCARD := preload("res://assets/fx/hand_discard.ogg")

func pick_dragged(space: CardSpace) -> void:
	set_state(InputState.ACTIVE_DRAG)
	$Notifications.clear()
	_current_area = space.get_card_area()
	$LockBody/IndicatorPick.current_pick = space.find_child("PickCard")
	GlobalEffects.request(FX_CARD_SELECT)

func pick_dropped(space: CardSpace) -> void:
	if not _current_area:
		push_error("Pick dropped without being dragged?")
		return
	_current_area = null
	
	if _current_target:
		set_state(InputState.ANIMATING)
		space.cancel_snapback()
		_current_space = space
		_do_target()
	else:
		_current_space = null
		GlobalEffects.request(FX_CARD_DESELECT)
		set_state(InputState.INACTIVE)
	
	$LockBody/IndicatorPick.current_pick = null
	_current_target = null

func pick_clicked(space: CardSpace) -> void:
	if _current_hover is CardSpace:
		space = _current_hover
	
	if _previous_space == space:
		_previous_space = null
		$LockBody/IndicatorPick.current_pick = null
		return
	
	_current_space = space
	$LockBody/IndicatorPick.current_pick = space.find_child("PickCard")
	GlobalEffects.request(FX_CARD_SELECT)
	space.set_selected()
	set_state(InputState.ACTIVE_SELECT)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and not event.pressed:
		$Notifications.clear()
		var click: Vector2 = event.global_position
		
		# Handle countdown highlight here while we're here
		if (
			not $LockBody/CountdownMain.get_mouse_rect().has_point(click)
			and not tutorial_mode
		):
			reset_countdown()
		
		if current_state == InputState.ACTIVE_SELECT:
			# check if you clicked a pin / discard
			for target in valid_targets():
				if target.get_mouse_rect().has_point(click):
					_current_target = target
					_do_target()
					return
			# note that if you clicked a pick card, this will execute before pick_clicked
			# so we only need to bring things back to default
			
			GlobalEffects.request(FX_CARD_DESELECT)
			# check if you clicked the same card again:
			if _current_space.get_mouse_rect().has_point(click):
				_previous_space = _current_space
			else:
				_previous_space = null
			
			_current_space.clear_selected()
			_current_space = null
			set_state(InputState.INACTIVE)

func _do_target() -> void:
	unhighlight_target(_current_target)
	if _current_target == $DiscardMain and not $DiscardMain.disable_discard:
		GlobalEffects.request(FX_CARD_DISCARD)
		discard_pick()
	elif _current_target is Pin:
		await do_pick(
			active_card,
			$LockBody/CylinderMain/Cylinders.get_index_of_ref(_current_target)
		)
		cleanup_step()
		end_animation()

var menu_shown := false
func set_menu_status(menu_shown_: bool) -> void:
	menu_shown = menu_shown_

func _process(_delta: float) -> void:
	if menu_shown:
		return
	
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
	elif target == $DiscardMain:
		unpreview_discard()

func highlight_target(target: Control) -> void:
	target.core_highlight()
	if target is Pin:
		var pin_index: int = $LockBody/CylinderMain/Cylinders.get_index_of_ref(target)
		$LockBody/IndicatorPick.go_index(pin_index)
		$LockBody/CylinderMain.preview(active_card, pin_index)
	elif target == $DiscardMain:
		preview_discard()

func unhighlight_all() -> void:
	if _current_target:
		_current_target = null
	if _current_space:
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

func preview_discard() -> void:
	var preview_step: EndStepSpec = $LockBody/CylinderMain.preview(_NULL_PICK, 0)
	if preview_step.pick_broke or preview_step.decks_broken > 0 or break_next:
		$TrashMain.bump_label()
	else:
		$DiscardMain.bump_label()
	# I am not handling any other effects here. by god.

func unpreview_discard() -> void:
	$LockBody/CylinderMain.cancel_preview()
	$DiscardMain.redraw()
	$TrashMain.update_label()

const FX_ROLL_IN := preload("res://assets/fx/menu_roll_in.ogg")
const FX_ROLL_OUT := preload("res://assets/fx/menu_roll_out.ogg")

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
		InputState.INACTIVE:
			unhighlight_all()
			$LockBody/IndicatorPick.go_hide()
			$HandMain/Hand.unhide_hand()
			if $LockBody.position != LOCK_BODY_HOME:
				create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT).tween_property(
					$LockBody,
					"position", 
					LOCK_BODY_HOME,
					0.23 * GameSettings.instance().animation_speed
				)
				GlobalEffects.request(FX_ROLL_OUT)
			$PreviousButton.disable = false
			$PreviousButton.show_see_prev = true
			$DiscardMain.show_icon = false
			$LockBody/CylinderMain.cancel_preview()
			reset_countdown()
			dis_en_able_buttons(false)
			$DiscardMain.show_icon = false
		InputState.ANIMATING:
			lock_input(true)
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
			create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT).tween_property(
				$LockBody,
				"global_position", 
				Vector2(
					# 146 is a full pin worth of depths, putting the base at the top
					LOCK_BODY_HOME.x, LOCK_BODY_HOME.y + 146 + 8
				),
				0.23 * GameSettings.instance().animation_speed
			)
			GlobalEffects.request(FX_ROLL_IN)
			$HandMain/Hand.hide_hand()
			$LockBody/CylinderMain.show_preview(_result)
			$PreviousButton.show_see_prev = false
			dis_en_able_buttons()
		InputState.CARD_DISPLAY:
			$HandMain/Hand.hide_hand()
			dis_en_able_buttons()

var lock_complete: bool

# Used for card display and over pop over effects
func dis_en_able_buttons(state: bool = true) -> void:
	lock_input(state)
	$TrashMain.disabled = state
	$DeckMain/DeckLabel.disabled = state
	$DiscardMain/DiscardLabel.disabled = state
	$DepthButton.disabled = state

var _tutorial_lock := false

## Used to lock input for tutorials. 
func tutorial_lock(state: bool) -> void:
	_tutorial_lock = state
	lock_input(state)

## Shows a reset button on break
var allow_reset := false

# Used for when you want to continue interacting with the interface,
# such as after unlock
func lock_input(state: bool = true) -> void:
	_lock_input = state
	$LockBody/CountdownMain.button_disable = (
		state
		or _countdown_lock
		or _tutorial_lock
		or lock_complete
		or $LockBody/CountdownMain.count <= 0
	)
	$HandMain/Hand.disabled = (
		state
		or _tutorial_lock
		or lock_complete
	)

func show_failure(state: bool = true) -> void:
	$FailureButton.visible = state and not tutorial_mode
	if state:
		$FailureButton.mouse_filter = MOUSE_FILTER_STOP
	else:
		$FailureButton.mouse_filter = MOUSE_FILTER_IGNORE

# Used for settings
func toggle_active_row(show_row: bool) -> void:
	$LockBody/ActiveBox.visible = show_row
#endregion

#region animation handling

func end_animation() -> void:
	lock_input(false)
	set_state(InputState.INACTIVE)

#endregion

#region game functions
func display_depths() -> void:
	$DepthDisplay.show_display()
	set_state(InputState.INACTIVE)
	set_state(InputState.CARD_DISPLAY)

func display_cards(cards: Array, header: String, left: bool) -> void:
	var cards_typed: Array[CardSpec] = []
	cards_typed.assign(cards)
	$CardDisplay.header = header
	$CardDisplay.cards = cards
	$CardDisplay.cards_2 = _already_broken
	$CardDisplay.has_sections = "broken" in header.to_lower()
	
	$CardDisplay.redraw()
	$CardDisplay.show_display(left)
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
		await $HandMain/Hand.animation_complete
		$DiscardMain.redraw()

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
func reload_deck(instant := false) -> void:
	if $DiscardMain.count() > 0:
		$Notifications.notify(Notifications.RELOAD)
	$DeckMain.add_cards($DiscardMain.empty_deck(), instant)

const PHYSICAL_PICK := preload("res://game/core/physical_pick.tscn")

func break_pick(card: CardSpec, surprise := false, bomb := false) -> void:
	$TrashMain.add_card(card)
	var physical := PHYSICAL_PICK.instantiate()
	physical.load_spec(card)
	if card in $DiscardMain.cards:
		physical.position = $DiscardMain.remove_card(card)
	elif card in $HandMain.cards:
		physical.position = $HandMain.remove_card(card)
	elif card in $DeckMain.cards:
		physical.position = $DeckMain.remove_card(card)
	else:
		push_error(
			"Tried to break card %s [%s] but could not locate!"
			% [card.pick_name, card.unique_id]
		)
		if DEBUG_MODE:
			assert(false)
		else:
			physical.queue_free()
	
	add_child(physical)
	if _current_space:
		_current_space.find_child("PickCard").hide_pick = true
	
	if surprise:
		$Notifications.notify(Notifications.SURPRISE)
	elif bomb:
		$Notifications.notify(Notifications.BOMB)
	else:
		$Notifications.notify(Notifications.BREAK)
	
	if ($HandMain.count() + $DeckMain.count() + $DiscardMain.count()) == 0:
		game_over()
	
	if allow_reset:
		$ResetButton.visible = true
	
	pick_broke.emit()

## Breaks the rightmost card - used for debug
func break_from_hand() -> void:
	if $HandMain.count() == 0:
		return
		
	active_card = $HandMain.cards[-1]
	break_next = true
	discard_pick()

func discard_pick() -> void:
	$LastTest.visible = false
	await do_pick(
		_NULL_PICK,
		0,
		active_card
	)
	
	if active_card in $HandMain.cards:
		move_cards_from_hand_to_discard([active_card])
	
	cleanup_step()
	end_animation()

func discard_from_deck() -> void:
	if $DeckMain.count() > 0:
		$DiscardMain.add_cards($DeckMain.draw_cards(1))

func discard_hand(instant := false) -> void:
	$DiscardMain.add_cards($HandMain.remove_all_cards(instant))
#endregion

#region pick activation logic
@onready var _result := EndStepSpec.new()

# BIG IMPORTANT FUNCTION FLAG
var RIDER_DOESNT_SHOW_EMOJIS_IN_COMMENTS := "🐳🐋🐳🐋"

## Handle all steps from pick activation
func do_pick(card: CardSpec, cylinder: int, break_instead: CardSpec = null) -> void:
	# main pick logic lives here:
	if DEBUG_MODE:
		print("Applying pick %s on cylinder %s" % [card.pick_name, cylinder])
	_result = $LockBody/CylinderMain.execute(card, cylinder)
	
	if card != _NULL_PICK:
		set_state(InputState.ANIMATING)
		$LockBody/IndicatorPick.do_push()
		$HandMain/Hand.activate_space(
			_current_space,
			$LockBody/CylinderMain/Cylinders.pin_refs[cylinder].global_position.x
		)
		await $LockBody/IndicatorPick.start_push
	
	$LockBody/CylinderMain/Cylinders.animate_pins(
		$LockBody/CylinderMain.pins, _result
	)
	if break_next:
		play_break($LockBody/CylinderMain/Cylinders.animation_complete)
	await $LockBody/CylinderMain/Cylinders.animation_complete
	
	if _result.pick_broke or break_next:
		if break_instead:
			break_pick(break_instead, false, _result.bomb_exploded)
		else:
			break_pick(card, false, _result.bomb_exploded)
	else:
		if card != _NULL_PICK:
			move_cards_from_hand_to_discard([card])
	
	if Effects.TEST in card.get_unique_list():
		$LastTest.update(_result.last_reveal)
	else:
		$LastTest.update()
		$LastTest.visible = false
	
	if _result.lock_solved:
		solve_lock()
	else:
		await post_pick()

const FX_BREAK_CANDLE := preload("res://assets/fx/break_ring.ogg")
## Async break sound
func play_break(sig: Signal) -> void:
	await sig
	GlobalEffects.request(FX_BREAK_CANDLE)

## Perform all the local actions for pick effects
func post_pick() -> void:
	if _result.hand_fumbled:
		$Notifications.notify(Notifications.FUMBLE)
		move_cards_from_hand_to_discard($HandMain.cards.duplicate())
		await $HandMain/Hand.animation_complete
	
	var breaths := _result.breaths_taken
	if breaths > 0:
		# replace the card you just played
		var discard_count: int = min(breaths, $DiscardMain.count())			
		draw_from_discard(discard_count)
		draw_cards(breaths - discard_count + 1)
	
	var deck_breaks := _result.decks_broken
	if deck_breaks > 0:
		var broken_cards = $DeckMain.get_random_pointers(deck_breaks)
		for card in broken_cards:
			break_pick(card, true)
	
	for __ in _result.picks_twisted:
		$Notifications.notify(Notifications.TWIST)
		discard_from_deck()
#endregion

#region game flow
func get_game_state() -> StateSpec:
	return StateSpec.new(
		AllCardsSpec.new(
			$DeckMain.cards,
			$HandMain.cards,
			$DiscardMain.cards,
			$TrashMain.cards
		),
		LockSpec.new(
			$LockBody/CylinderMain.pins,
			_lock_deck
		),
		$LockBody/CountdownMain.count,
		$LockBody/CountdownMain.break_bag,
		0,
		turn_count
	)

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
	new_state.emit(get_game_state())

## perform the end of turn step once the player clicks the turn candle (if it's valid)
## Like discard, end turn also trips the null pick, although it'll break from deck instead
func end_turn() -> void:
	$Notifications.clear()
	$LastTest.visible = false
	
	var all_cards: Array[CardSpec]
	all_cards.append_array($DeckMain.cards)
	all_cards.append_array($DiscardMain.cards)
	all_cards.append_array($HandMain.cards)
	await do_pick(
		_NULL_PICK,
		0,
		all_cards.pick_random()
	)
	
	$LockBody/CountdownMain.count_down()
	$LockBody/CylinderMain.handle_fall()
	set_state(InputState.ANIMATING)
	discard_hand()
	await $HandMain/Hand.animation_complete
	reload_deck()
	await $DeckMain.reload_finish
	cleanup_step()
	await $HandMain/Hand.animation_complete
	turn_ended.emit()
	set_state(InputState.INACTIVE)

func game_over() -> void:
	print("Game over.")
	$Notifications.notify(Notifications.FAILURE)
	$LockBody/CountdownMain.game_over()
	show_failure()
	game_fail.emit()
	lock_complete = true

const FX_UNLOCK_CLICKS := preload("res://assets/fx/lock_unlock_clicks.ogg")

func solve_lock() -> void:
	$LockBody/ContinueButton.visible = not tutorial_mode	
	game_win.emit()
	GlobalEffects.request(FX_UNLOCK_CLICKS)
	$LockBody/AnimationPlayer.play("unlock")
	$Notifications.notify(Notifications.UNLOCK)
	lock_complete = true
#endregion

#region setup functions
## Loads the starter hand
func load_deck(deck: Array[CardSpec]) -> void:
	discard_hand(true)
	reload_deck(true)
	$DeckMain.clear_all()
	$DeckMain.load_cards(deck)

## Holds the deck used to generate this lock - used for state updates
var _lock_deck: LockDeck

## loads a lock
func load_lock(lock: LockSpec) -> void:
	$LockBody/CylinderMain.load_new_lock(lock)
	if lock.lock_deck:
		_lock_deck = lock.lock_deck
	else:
		_lock_deck = LockDeck.new()
	$DepthDisplay.update(_lock_deck.get_unique_depths())
	call_deferred("_set_indicator_box")

func _set_indicator_box() -> void:
	$LockBody/IndicatorPick.mouse_box = (
		$LockBody/CylinderMain/Cylinders.get_valid_global_rect()
	)

var _already_broken: Array[CardSpec]

## Loads non-lock parameters from the game spec and restarts the game.
func load_game(game: GameSpec) -> void:
	$GameStatus.tutorial = game.tutorial_mode
	$GameStatus.stage = game.current_lock()
	load_deck(game.current_deck.duplicate())
	_already_broken = game.broken_picks
	$TrashMain.reset()
	restart()

func restart() -> void:
	lock_complete = false
	tutorial_mode = false
	tutorial_lock(false)
	lock_input(false)
	allow_reset = false
	$ResetButton.visible = false
	set_discard_disable(false)
	set_countdown_disable(false)
	show_failure(false)
	$LastTest.visible = false
	$LockBody/ContinueButton.visible = false
	$LockBody/AnimationPlayer.play("RESET")
	$LockBody/CountdownMain.set_count(starting_countdown_time)
	$LockBody/CountdownMain.reset_odds()
	turn_count = 0
	$Notifications.clear()
	$LastTest.visible = false
	tick_turn_count()
	update_status_widget()
	# note: you will need to draw cards outside of restart to sync with animation
	set_state(InputState.INACTIVE)

func setup_interface(setup: LevelSpec.InterfaceSetup = LevelSpec.InterfaceSetup.DEFAULT) -> void:
	match setup:
		LevelSpec.InterfaceSetup.DEFAULT:
			$AnimationPlayer.play("RESET")
		LevelSpec.InterfaceSetup.FULL_EMPTY:
			$AnimationPlayer.play("tutorial_start")
		LevelSpec.InterfaceSetup.HALF_SHOWN:
			$AnimationPlayer.play("half_visible")
		LevelSpec.InterfaceSetup.THREE_QUARTERS:
			$AnimationPlayer.play("three_quarters")

## Loads an in-progress game. Used instead of load_lock / load_game
func load_in_progress(game: GameSpec, state: StateSpec) -> void:
	load_lock(state.lock)
	load_game(game)
	$DeckMain.clear_all()
	$DeckMain.load_cards(state.all_cards.deck)
	$HandMain.remove_all_cards()
	$HandMain.add_cards(state.all_cards.hand)
	$DiscardMain.empty_deck()
	$DiscardMain.add_cards(state.all_cards.discard)
	$TrashMain.reset()
	$TrashMain.add_cards(state.all_cards.trash)
	$LockBody/CountdownMain.count = state.countdown
	$LockBody/CountdownMain.break_bag = state.break_bag
	turn_count = state.turn_count

func set_discard_disable(disable: bool) -> void:
	$DiscardMain.disable_discard = disable


var _countdown_lock := false

func set_countdown_disable(disable: bool) -> void:
	_countdown_lock = disable
	$LockBody/CountdownMain.button_disable = disable

var tutorial_mode := false

const FX_SUCCESS_CHIME := preload("res://assets/fx/complete_chime.ogg")
const FX_LOW_CHIME := preload("res://assets/fx/low_chime.ogg")

func _ready() -> void:
	var settings := GameSettings.instance()
	toggle_active_row(settings.highlight_active_row)
	settings.highlight_active_row_changed.connect(toggle_active_row)
	$HandMain/Hand.deck_pos = $DeckMain.position
	$HandMain/Hand.discard_pos = $DiscardMain.position
	$DeckMain.discard_pos = $DiscardMain.position - $DeckMain.position
	
	$LockBody/ContinueButton.pressed.connect(continue_to_next.emit)
	$LockBody/ContinueButton.pressed.connect(GlobalEffects.request.bind(FX_SUCCESS_CHIME))
	$FailureButton.pressed.connect(continue_to_failure.emit)
	$ResetButton.pressed.connect(continue_to_next.emit)
	$ResetButton.pressed.connect(GlobalEffects.request.bind(FX_LOW_CHIME))

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
	$TrashMain.display_cards.connect(display_cards.bind("Broken picks", false))
	$DeckMain.display_cards.connect(display_cards.bind("Remaining deck", true))
	$DiscardMain.display_cards.connect(display_cards.bind("Discard pile", false))
	
	$HandMain/Hand.animation_complete.connect(animation_complete.emit)
	$LockBody/CylinderMain/Cylinders.animation_complete.connect(animation_complete.emit)
	$DeckMain.reload_finish.connect(animation_complete.emit)
	
	$LockBody/IndicatorPick.reset.connect(end_animation)
	$DeckMain.reload_finish.connect(end_animation)
	$DeckMain.reload_progress.connect($DiscardMain.update_label)
	$DeckMain.reload_progress.connect($DiscardMain.update_pile)
	$DeckMain.reload_finish.connect($DiscardMain.redraw)

	# if name == "__main__:
	if get_tree().current_scene == self:
		print("Running in debug mode.")
		DEBUG_MODE = true
		var game := GameSpec.get_in_progress_game()
		load_lock(LockGenerator.build_lock(game.next_lock_deck, 4))
		load_game(game)
		draw_to_five()
#		draw_cards(5)
