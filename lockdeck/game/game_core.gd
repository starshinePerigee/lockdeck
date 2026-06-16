extends Control
#
signal game_fail
signal game_win

#region game state variables
@export var CYLINDER_COUNT := 4
@export var DECK_COUNT := 10
@export var HAND_SIZE := 5
@export var REVEAL_ALL := false

var card_is_active := false
## Holds the most recent active card (even if a card isn't active)
var active_card: CardSpec
#endregion

func pick_selected(card: CardSpec) -> void:
	$Notifications.clear()
	card_is_active = true
	active_card = card

func pick_deselected() -> void:
	card_is_active = false

func pick_dragged(_card_area: Area2D, card: CardSpec) -> void:
	$Notifications.clear()
	card_is_active = true
	active_card = card

func pick_dropped(card_area: Area2D, card: CardSpec) -> void:
	$LockBody/Keyway.check_drop(card_area)
	card_is_active = false

func pick_activated(space_index: int) -> void:
	if not card_is_active:
		return
	
	do_pick(active_card, space_index)

func break_pick() -> void:
	pass
	# move pick to trash
	# check for game failure
	#$Notifications.notify(Notifications.FAILURE)
	#game_fail.emit()

## Handle all steps from pick activation
func do_pick(card: CardSpec, cylinder: int) -> void:
	print("doing pick %s to cyl %s" % [card.pick_name, cylinder])
	#func spend_pick(card_index: int):
	#	var spent_pick = keyway_cards[card_index]
	#	keyway_cards.erase(card_index)
	#	if pick_broke:
	#		trash_cards.append(spent_pick)
	#	else:
	#		discard_cards.append(spent_pick)
	#	fill_cards()
	# don't forget: check if hand empty and highlight end turn if so
	# also check game win
	$HandMain.deselect()

func discard_hand() -> void:
	$DiscardMain.add_cards($HandMain.load_new_hand())

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
	discard_hand()
	if $DeckMain.count() == 0:
		reload_deck()
		$CountdownMain.count_down()
	draw_new_hand()
	$LockBody/CylinderMain.handle_fall()

func _ready() -> void:
	$EndTurn.pressed.connect(end_turn)
	$HandMain.hand_selected.connect(pick_selected)
	$HandMain.hand_deselected.connect(pick_deselected)
	$HandMain.hand_dragged.connect(pick_dragged)
	$HandMain.hand_dropped.connect(pick_dropped)
	$LockBody/Keyway.space_activated.connect(pick_activated)

	$Notifications.clear()
	$LockBody/CylinderMain.load_new_pins(PinGenerator.build_test_lock(CYLINDER_COUNT))
	$LockBody/Keyway.space_count = CYLINDER_COUNT

	$DeckMain.add_cards(PickGenerator.get_many_base_cards(DECK_COUNT))
	draw_new_hand()
