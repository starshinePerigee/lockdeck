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

func break_pick() -> void:
	pass
	# move pick to trash
	# check for game failure
	#$Notifications.notify(Notifications.FAILURE)
	#game_fail.emit()

## Handle all steps from pick activation
func activate_pick() -> void:
	pass
	#func spend_pick(card_index: int):
	#	var spent_pick = keyway_cards[card_index]
	#	keyway_cards.erase(card_index)
	#	if pick_broke:
	#		trash_cards.append(spent_pick)
	#	else:
	#		discard_cards.append(spent_pick)
	#	fill_cards()
	# don't forget: check if hand empty and highlight end turn if so

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

	$Notifications.clear()
	$LockBody/CylinderMain.load_new_pins(PinGenerator.build_test_lock(CYLINDER_COUNT))
	$LockBody/Keyway.space_count = CYLINDER_COUNT

	$DeckMain.add_cards(PickGenerator.get_many_base_cards(DECK_COUNT))
	draw_new_hand()

#	$LockBody/Keyway.card_activated.connect(execute_pick)
#	$DiscardPile.pile_pressed.connect(reload)
#	$Hand.card_discarded.connect(discard_from_hand)
#	$Hand.card_rearranged.connect(rearrange_hand)
#
