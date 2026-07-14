extends Resource
## Result spec is a dataclass that holds a single pin's preview or previous turn
class_name ResultSpec

## Results in a depth: result dictionary
@export var results: Dictionary[int, Results]

## The depth to show the jam icon at
@export var jam_depth: int

func update(depth: int, result: Results) -> void:
	if depth in results:
		results[depth] = Results.compare(results[depth], result)
	else:
		results[depth] = result

var _pin: PinSpec
var _position: int
var _jam_count: int

## Advance the pin, returning true if it advanced
func advance(by: int) -> bool:
	while _jam_count > 0 and by > 0:
		by -= 1
		_jam_count -= 1
	if _jam_count == 0:
		jam_depth = -1
	_position += by
	return by > 0

## Updates the results for this effect by a single effect.
func apply_effect(effect: EffectSpec) -> void:
	if _pin == null:
		push_error("Failed to initailize pin spec!")
		return

	match effect.flavor:
		Effects.PUSH:
			update(_position, Results.NONE)
			var hinted := advance(1)
			for i in (effect.value - 1):
				if hinted:
					update(_position, Results.HINT)
				hinted = advance(1)
			update(_position, Results.ACTIVATE)
		Effects.TEST:
			update(_position, Results.NONE)
			if _jam_count > 0:
				return
			for i in effect.value:
				update(_position + i + 1, Results.HINT)
		Effects.REVEAL:
			update(_position, Results.NONE)
			if _jam_count > 0:
				return
			for i in effect.value:
				update(_position + i + 1, Results.REVEAL)
		Effects.CRUSH:
			update(_position, Results.CRUSH)
			advance(1)
			for i in (effect.value - 1):
				update(_position, Results.CRUSH)
				advance(1)
			update(_position, Results.ACTIVATE)
		Effects.JAM:
			jam_depth = _position
			_jam_count = effect.value
		_:
			push_warning(
				"Invalid effect when calculating preview: %s"
				% effect.flavor.effect_name
			)

## Perform final updates to handle pin specific behaviors
func finalize() -> void:
	if _pin == null:
		push_error("Failed to initailize pin spec!")
		return
	
	for i in results.keys():
		if i >= PinSpec.PIN_DEPTH_COUNT:
			continue
		
		match results[i]:
			Results.ACTIVATE:
				# Handle special visible depths:
				if _pin.get_revealed(i):
					if _pin.depths[i] == Depths.BREAK:
						results[i] = Results.BREAK
					elif _pin.depths[i] in Depths.SOLVE_DEPTHS:
						results[i] = Results.UNLOCK
			Results.CRUSH:
				# Handle crushing invincible depths:
				if _pin.depths[i] == Depths.FINAL:
					results[i] = Results.BREAK
			Results.HINT, Results.REVEAL:
				# Handle hits on already visible depths
				if _pin.get_revealed(i):
					results[i] = Results.NONE
	
	## Check for oob
	for i in results.keys():
		if (
			i >= PinSpec.PIN_DEPTH_COUNT
			and results[i] in [Results.CRUSH, Results.ACTIVATE] 
		):
			update(PinSpec.PIN_DEPTH_COUNT, Results.BREAK)
			break

func _init(pin: PinSpec = null):
	if pin != null:
		_pin = pin
		_position = pin.pin_position
		_jam_count = pin.jam_count

	results = {}
	jam_depth = -1