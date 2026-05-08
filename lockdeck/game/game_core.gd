extends Control

const CYLINDER_COUNT = 4
const REVEAL_ALL := true

var keyway_cards: Dictionary[int, CardSpec] = {}
var cyl_pins: Dictionary[int, PinSpec] = {}

static func check_array_dict(d: Dictionary[int, Array]) -> int:
	var keys = d.keys()
	keys.sort()
	keys.reverse()
	for k in keys:
		if not d[k].is_empty():
			return k
		else:
			d.erase(k)
	return -383  # if you hit this the hard way I am gonna be so tilted

# global scope these for maximum scuff
# i degaf it's games james
var pending_effects: Dictionary[int, Array]
var pick_broke: bool

func _reset_globals():
	$Notifications.clear()
	pending_effects = {}
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
	while true:
		iterations += 1
		var k = check_array_dict(pending_effects)
		if k == -383:
			break
		var next_effect = pending_effects[k].pop_front()
		if next_effect == null:
			push_error("Popped a null evaluating %s?" % card_spec.pick_name)
			break
		evaluate_pin(k, next_effect)
	
	check_solve()
	#print("evaluated pick after %s iterations" % iterations)
	refresh_objects()

func evaluate_pin(pin_index: int, effect: EffectSpec) -> void:
	if pin_index not in cyl_pins:
		#print("out of bounds pin index %s (this is probably fine)" % pin_index)
		return
	
	# when inserting depths, they insert starting at index 0 but
	# go in ascending order
	match effect.flavor:
		# ALL OF THE GAME LOGIC GOES HERE: 
		# (BALATRO REFERENCE LMAO)
		EffectData.EffectFlavors.FORCE:
			execute_force(pin_index, effect)
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

func execute_force(pin_index: int, effect: EffectSpec):
	cyl_pins[pin_index].pin_set = false
	for i in range(effect.value):
		var depth_index = i + cyl_pins[pin_index].pin_position + 1
		if depth_index >= 0 and depth_index < Pin.DEPTH_SIZE:
			var depth_effect = DepthData.get_def(cyl_pins[pin_index].depths[depth_index]).effect
			#print("Added %s from index %s to %s" % [EffectData.EffectFlavors.find_key(depth_effect), depth_index, i])
			pending_effects[pin_index].insert(i, EffectSpec.new(depth_effect, 1))
		else:
			pending_effects[pin_index].insert(
				i, EffectSpec.new(EffectData.EffectFlavors.OUT_OF_BOUNDS, 1)
			)
						
	if effect.value + cyl_pins[pin_index].pin_position < Pin.DEPTH_SIZE:
		cyl_pins[pin_index].pin_position += effect.value
	else:
		cyl_pins[pin_index].pin_position = 8

func execute_bounce(pin_index: int):
	cyl_pins[pin_index].pin_set = false
	cyl_pins[pin_index].pin_position = 0

func execute_key(pin_index: int):
	cyl_pins[pin_index].pin_set = true
	
func execute_break():
	if not pick_broke:
		$Notifications.notify(NotificationData.NotificationFlavors.BREAK)
		pick_broke = true

func check_solve() -> bool:
	for i in range(len(cyl_pins)):
		if not cyl_pins[i].pin_set:
			return false
	$Notifications.notify(NotificationData.NotificationFlavors.UNLOCK)
	return true

func refresh_objects():
	if REVEAL_ALL:
		for i in cyl_pins:
			for j in range(Pin.DEPTH_SIZE):
				cyl_pins[i].reveals[j] = true
		
	$LockBody/Cylinders.pins = cyl_pins
	$LockBody/Keyway.cards = keyway_cards

func _ready() -> void:
	$Notifications.clear()
	$LockBody/Cylinders.cylinder_count = CYLINDER_COUNT
	$LockBody/Keyway.space_count = CYLINDER_COUNT
	
	$LockBody/Keyway.card_activated.connect(execute_pick)
	
	for i in range(CYLINDER_COUNT):
		cyl_pins[i] = PinGenerator.get_random_base_pin()
		keyway_cards[i] = PickGenerator.get_random_base_card()
	
	refresh_objects()
