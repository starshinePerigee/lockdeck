extends Control

const CYLINDER_COUNT = 4

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

# global scope this for maximum scuff
var pending_effects: Dictionary[int, Array]

func execute_pick(card_index: int, card_spec: CardSpec):
	pending_effects = {}
	for k in card_spec.effects.keys():
		var pin_index = card_index + k
		if pin_index not in pending_effects:
			pending_effects[pin_index] = []
		for e in card_spec.effects[k]:
			pending_effects[pin_index].append(e)
	var pick_broke = false
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
		pick_broke = evaluate_pin(k, next_effect) or pick_broke
	
	print("evaluated pick after %s iterations" % iterations)
	execute_bounces()
	refresh_objects()

func evaluate_pin(pin_index: int, effect: EffectSpec) -> bool:
	if pin_index not in cyl_pins:
		print("out of bounds pin index %s (this is probably fine)" % pin_index)
		return false
	match effect.flavor:
		EffectData.EffectFlavors.FORCE:
			if effect.value + cyl_pins[pin_index].pin_position < Pin.DEPTH_SIZE:
				cyl_pins[pin_index].pin_position += effect.value
				return false
			else:
				cyl_pins[pin_index].pin_position = 8
				return true
		_:
			push_warning("Undefined effect flavor effect: %s" % effect.flavor)
			return false

func execute_bounces():
	for k in cyl_pins.keys():
		if cyl_pins[k].current_depth() == DepthData.DepthFlavors.BOUNCE:
			print("Bounce %s" % k)
			cyl_pins[k].pin_position = 0

func refresh_objects():
	$LockBody/Cylinders.pins = cyl_pins
	$LockBody/Keyway.cards = keyway_cards

func _ready() -> void:
	$LockBody/Cylinders.cylinder_count = CYLINDER_COUNT
	$LockBody/Keyway.space_count = CYLINDER_COUNT
	
	$LockBody/Keyway.card_activated.connect(execute_pick)
	
	for i in range(CYLINDER_COUNT):
		cyl_pins[i] = PinGenerator.get_random_base_pin()
		keyway_cards[i] = PickGenerator.get_random_base_card()
	
	refresh_objects()
