extends Control
#
#signal game_fail
#signal game_win

#region game state variables
@export var CYLINDER_COUNT := 4
@export var DECK_COUNT := 10
@export var REVEAL_ALL := false

var card_is_active := false
## Holds the most recent active card (even if a card isn't active)
var active_card: CardSpec
#endregion

## Player requests end of turn by clicking the discard pile
func request_end_turn() -> void:
	pass
	#	_reset_globals()
	#	discard_cards.shuffle()
	#	var trashed_pick = discard_cards.pop_front()
	#	trash_cards.append(trashed_pick)
	#	draw_cards.append_array(discard_cards)
	#	discard_cards.clear()
	#	$Notifications.notify(NotificationData.NotificationFlavors.RELOAD)
	#	fill_cards()
	#	refresh_objects()

## perform the end of turn step once the player clicks the discard (if it's valid)
func end_turn() -> void:
	$LockBody/CylinderMain.handle_fall()

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


func _ready() -> void:
	$Notifications.clear()
	$LockBody/CylinderMain.load_new_pins(PinGenerator.build_test_lock(CYLINDER_COUNT))
	$LockBody/Keyway.space_count = CYLINDER_COUNT
	
	for i in range(5):
		$HandMain.add_card(PickGenerator.get_random_base_card())

#	$LockBody/Keyway.card_activated.connect(execute_pick)
#	$DiscardPile.pile_pressed.connect(reload)
#	$Hand.card_discarded.connect(discard_from_hand)
#	$Hand.card_rearranged.connect(rearrange_hand)
#	
#	for i in range(DECK_COUNT):
#		draw_cards.append(PickGenerator.get_random_base_card())
#	
#	fill_cards()
#	refresh_objects()
