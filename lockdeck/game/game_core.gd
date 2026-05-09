extends Control

const CYLINDER_COUNT = 4
const DECK_COUNT = 10
const REVEAL_ALL := false

var draw_cards: Array[CardSpec] = []
var discard_cards: Array[CardSpec] = []
var trash_cards: Array[CardSpec] = []
var hand_cards: Dictionary[int, CardSpec] = {}
var keyway_cards: Dictionary[int, CardSpec] = {}
var cyl_pins: Dictionary[int, PinSpec] = {}

static func sort_reverse_dict_keys(d: Dictionary) -> Array:
	var keys = d.keys()
	keys.sort()
	keys.reverse()
	return keys

static func check_array_dict(d: Dictionary[int, Array]) -> int:
	for k in sort_reverse_dict_keys(d):
		if not d[k].is_empty():
			return k
		else:
			d.erase(k)
	return -383  # if you hit this the hard way I am gonna be so tilted

# global scope these for maximum scuff
# i degaf it's games james
var pending_effects: Dictionary[int, Array]
var result_effect_pointer: int = 0
var pins_modified: Dictionary[int, bool]
var pick_broke: bool

func _reset_globals():
	$Notifications.clear()
	pending_effects = {}
	result_effect_pointer = 0
	for k in cyl_pins.keys():
		pins_modified[k] = false
	pick_broke = false

func execute_pick(card_index: int, card_spec: CardSpec):
	_reset_globals()
	for k in card_spec.effects.keys():
		var pin_index = card_index + k
		if pin_index not in pending_effects:
			pending_effects[pin_index] = []
		for e in card_spec.effects[k]:
			pending_effects[pin_index].append(e)
			
	var iterations = 0
	while iterations < 1000:
		iterations += 1
		var k = check_array_dict(pending_effects)
		if k == -383:
			break
		var next_effect = pending_effects[k].pop_front()
		if next_effect == null:
			push_error("Popped a null evaluating %s?" % card_spec.pick_name)
			break
		evaluate_pin(k, next_effect)
	if iterations == 1000:
		push_error("Execution loop overflow!")
	
	check_solve()
	handle_falling()
	spend_pick(card_index)
	#print("evaluated pick after %s iterations" % iterations)
	refresh_objects()

func evaluate_pin(pin_index: int, effect: EffectSpec) -> void:
	if pin_index not in cyl_pins:
		#print("out of bounds pin index %s (this is probably fine)" % pin_index)
		return
	
	result_effect_pointer = 0
	pins_modified[pin_index] = true
	
	# when inserting depths, they insert starting at index 0 but
	# go in ascending order
	match effect.flavor:
		# ALL OF THE GAME LOGIC GOES HERE: 
		# (BALATRO REFERENCE LMAO)
		EffectData.EffectFlavors.EMPTY:
			pass
		EffectData.EffectFlavors.FORCE:
			execute_force(pin_index, effect)
		EffectData.EffectFlavors.JUMP:
			execute_jump(pin_index, effect)
		EffectData.EffectFlavors.JAM:
			execute_jam(pin_index, effect)
		EffectData.EffectFlavors.TEST:
			execute_test(pin_index, effect)
		EffectData.EffectFlavors.BOUNCE:
			execute_bounce(pin_index)
		EffectData.EffectFlavors.OUT_OF_BOUNDS:
			execute_bounce(pin_index)
			execute_break()
		EffectData.EffectFlavors.KEY:
			execute_key(pin_index)
		EffectData.EffectFlavors.BREAK:
			execute_break()
		EffectData.EffectFlavors.DEBUG:
			push_error("DEBUG effect flavor called! Pin index %s" % pin_index)
		_:
			push_warning("Undefined effect flavor effect: %s" % effect.flavor)

func add_effect(pin_index: int, effect: EffectSpec):
	"""
	Adds an effect to the correct location
	(at the top of the stack but behind anything else added
	during this effect evaluation)
	"""
	pending_effects[pin_index].insert(result_effect_pointer, effect)
	result_effect_pointer += 1

func advance_pin(pin_index: int, advance_by: int) -> bool:
	"""
	Moves pin_index pin forward by advance_by.
	Returns true if this oobed, and false otherwise
	"""
	var p: PinSpec = cyl_pins[pin_index]
	
	if p.jam_count > 0:
		p.jam_count -= 1
		if p.jam_count == 0:
			p.pin_set = false
		return false
	
	p.pin_set = false
	p.key_set = false
	var depth_index = p.pin_position + advance_by

	if depth_index < 0 or depth_index >= Pin.DEPTH_SIZE:
		add_effect(pin_index, EffectSpec.new(EffectData.EffectFlavors.OUT_OF_BOUNDS, 1))
		p.pin_position = clamp(depth_index, 0, Pin.DEPTH_SIZE-1)
		return true
	
	p.pin_position = depth_index
	add_effect(
		pin_index,
		EffectSpec.new(DepthData.get_def(p.depths[depth_index]).effect, 1)
	)
	p.reveals[p.pin_position] = true
	return false

func execute_force(pin_index: int, effect: EffectSpec):
	for i in range(effect.value):
		if advance_pin(pin_index, 1):
			break

func execute_jump(pin_index: int, effect: EffectSpec):
	advance_pin(pin_index, effect.value)

func execute_jam(pin_index: int, effect: EffectSpec):
	cyl_pins[pin_index].jam_count += effect.value
	cyl_pins[pin_index].pin_set = true

func execute_test(pin_index: int, effect: EffectSpec):
	for i in range(effect.value):
		var test_depth = cyl_pins[pin_index].pin_position + i
		if test_depth > 0 and test_depth < Pin.DEPTH_SIZE:
			cyl_pins[pin_index].reveals[test_depth] = true

func execute_bounce(pin_index: int):
	cyl_pins[pin_index].pin_set = false
	cyl_pins[pin_index].pin_position = 0

func execute_key(pin_index: int):
	cyl_pins[pin_index].key_set = true
	cyl_pins[pin_index].pin_set = true
	
func execute_break():
	if not pick_broke:
		$Notifications.notify(NotificationData.NotificationFlavors.BREAK)
		pick_broke = true

func check_solve() -> bool:
	for k in cyl_pins.keys():
		if not cyl_pins[k].key_set:
			return false
	$Notifications.notify(NotificationData.NotificationFlavors.UNLOCK)
	return true

func handle_falling():
	for k in cyl_pins.keys():
		if (
			not pins_modified[k]
			and not cyl_pins[k].pin_set 
			and cyl_pins[k].pin_position > 0
		):
			cyl_pins[k].pin_position -= 1
			

func spend_pick(card_index: int):
	var spent_pick = keyway_cards[card_index]
	keyway_cards.erase(card_index)
	if pick_broke:
		trash_cards.append(spent_pick)
	else:
		discard_cards.append(spent_pick)
	fill_cards()

func reload():
	if len(discard_cards) == 0:
		return
	
	_reset_globals()
	discard_cards.shuffle()
	var trashed_pick = discard_cards.pop_front()
	trash_cards.append(trashed_pick)
	draw_cards.append_array(discard_cards)
	discard_cards.clear()
	$Notifications.notify(NotificationData.NotificationFlavors.RELOAD)
	fill_cards()
	refresh_objects()

func check_unlock() -> bool:
	for i in range(len(cyl_pins)):
		if not cyl_pins[i].key_set:
			return false
	$Notifications.notify(NotificationData.NotificationFlavors.UNLOCK)
	return true

func rearrange_hand(card_index: int, new_position: int) -> void:
	# this is scuffed but my brain is melted
	var card_array: Array[CardSpec]
	# if you change the hand size death will come
	for i in range(3):
		card_array.append(hand_cards[i])
	card_array.insert(new_position, hand_cards[card_index])
	if new_position < card_index:
		card_array.pop_at(card_index + 1)
	else:
		card_array.pop_at(card_index)
	for i in range(3):
		hand_cards[i] = card_array[i]
	refresh_objects()

func discard_from_hand(card_index: int) -> void:
	var discarded_pick = hand_cards[card_index]
	hand_cards.erase(card_index)
	discard_cards.append(discarded_pick)
	
	_reset_globals()
	handle_falling()
	fill_cards()
	refresh_objects()

func fill_cards():
	var played_cards: Array[CardSpec] = []
	for k in sort_reverse_dict_keys(keyway_cards):
		played_cards.append(keyway_cards[k])
	for k in sort_reverse_dict_keys(hand_cards):
		played_cards.append(hand_cards[k])
	draw_cards.shuffle()
	played_cards.append_array(draw_cards)
	
	if len(played_cards) == 0 and len(discard_cards) == 0:
		$Notifications.notify(NotificationData.NotificationFlavors.FAILURE)
		return
	
	for i in range(CYLINDER_COUNT + 3):
		if i < CYLINDER_COUNT:
			var cyl_index = CYLINDER_COUNT - i - 1
			if played_cards.is_empty():
				keyway_cards.erase(cyl_index)
			else:
				# THIS HAS A BUG
				keyway_cards[cyl_index] = played_cards.pop_front()
		elif i >= CYLINDER_COUNT and i < CYLINDER_COUNT + 3:
			if played_cards.is_empty():
				hand_cards.erase(i - CYLINDER_COUNT)
			else:
				hand_cards[i - CYLINDER_COUNT] = played_cards.pop_front()
		else:
			break
	draw_cards = played_cards

func refresh_objects():
	if REVEAL_ALL:
		for i in cyl_pins:
			for j in range(Pin.DEPTH_SIZE):
				cyl_pins[i].reveals[j] = true
	
	$Hand.card_specs = hand_cards
	$DrawPile.count = len(draw_cards)
	$DiscardPile.count = len(discard_cards)
	$TrashPile.count = len(trash_cards)
	$LockBody/Cylinders.pins = cyl_pins
	$LockBody/Keyway.cards = keyway_cards

func _ready() -> void:
	$Notifications.clear()
	$LockBody/Cylinders.cylinder_count = CYLINDER_COUNT
	$LockBody/Keyway.space_count = CYLINDER_COUNT
	
	$LockBody/Keyway.card_activated.connect(execute_pick)
	$DiscardPile.pile_pressed.connect(reload)
	$Hand.card_discarded.connect(discard_from_hand)
	$Hand.card_rearranged.connect(rearrange_hand)
	
	for i in range(CYLINDER_COUNT):
		cyl_pins[i] = PinGenerator.get_random_base_pin()
	
	for i in range(DECK_COUNT):
		draw_cards.append(PickGenerator.get_random_base_card())
	
	fill_cards()
	refresh_objects()
