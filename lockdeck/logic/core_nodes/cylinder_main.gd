extends Control
## Manages the pins (cylinders) for the lock.

## The one true reference for the current state of all pins.
## Length is the length of active pins - inactive pins are present as hidden objects
## but are not present in the pins array.
@export var pins: Array[PinSpec]

## Holds the current turn number
static var turn_number := -1

## Holds the current hint id (integer corresponding to ascii)
var _hint_id := -1

## Bump hint_id to the next letter
func increment_hint() -> int:
	# pre-A (65)
	if _hint_id < 0:
		_hint_id = 65
	# A-Z (65-89)
	elif _hint_id >= 65 and _hint_id < 90:
		_hint_id += 1
	# Z (90) to 1 (97)
	elif _hint_id == 90:
		_hint_id = 49
	# 1-9 (49-57)
	elif _hint_id >= 49 and _hint_id < 57:
		_hint_id += 1
	# 9 (57) to a (97)
	elif _hint_id == 57:
		_hint_id = 97
	# a-z (97-121)
	elif _hint_id >= 97 and _hint_id < 122:
		_hint_id += 1
	# # (35)
	else:
		_hint_id = 35
	return _hint_id

## Resets all pins to their initial position
func reset_all_pins() -> void:
	for pin in pins:
		pin.reset_pin()
	$Cylinders.set_pin_specs(pins)

## Load a new lock for a new level.
func load_new_lock(new_lock: LockSpec) -> void:
	pins = new_lock.pins
	$Cylinders.set_pin_specs(new_lock.pins)
	turn_number = 0
	_hint_id = -1

## Tells cylinder_main to draw a preview. Should not have game effects.
func preview(card: CardSpec, index: int) -> void:
	var results: Array[ResultSpec] = []
	for i in len(pins):
		var effect_offset := index - i
		if effect_offset in card.effects:
			var effects: Array[EffectSpec] = []
			effects.assign(card.effects[effect_offset])
			results.append(calculate_preview(i, effects))
		else:
			results.append(ResultSpec.new())
	$Cylinders.set_results(results)

## Removes the current preview.
func cancel_preview() -> void:
	$Cylinders.clear_results()

## Gets the currently hovered pin during a drag
func get_current_drag_target() -> int:
	return $Cylinders.current_active_pin()

#region pick execution logic
## Represents a single activation of a card.
## Effects that affect game state are raised as signals, however.
class Execution:
	## All pending effects in a Array[Array[EffectSpec))
	## The top level array has an index per pin, 0 on the left and 4 on the right
	## identical to the cylinder_main.pins array.
	var pending_effects: Array[Array]
	
	## All effects which executed - loaded directly into EndStepSpec
	var executed_effects: Dictionary[int, Array]
	
	static var execution_sentinel := EffectSpec.new(Effects.END_EXECUTION)
		
	func _init(pin_count: int) -> void:
		pending_effects = []
		for i in pin_count:
			pending_effects.append([])
			executed_effects[i] = []
	
	## Loads a card into the pending effects dictionary
	# TODO: refactor
	func load_card(card: CardSpec, card_index: int) -> void:
		for k in card.effects.keys():
			var pin_index: int = card_index - k
			if pin_index >= 0 and pin_index < len(pending_effects):
				for e in card.effects[k]:
					var new_e := EffectSpec.new(e.flavor, e.value)
					add_effect(pin_index, new_e, false)
	
	## Gets the next effect, or EffectSpec.. Use has_next_effect to avoid that.
	## Effects are pulled from pins high to low (right to left), down the effect stack.
	## Each effect that is returned is popped from the pending effects dictionary.
	func get_next_effect() -> EffectSpec:
		# TODO
		for pin_index in range(len(self.pending_effects) - 1, -1, -1):
			if len(self.pending_effects[pin_index]) > 0:
				var effect: EffectSpec = self.pending_effects[pin_index].pop_front()
				effect.realized_pin = pin_index
				return effect
		return execution_sentinel
	
	## Adds effects to the top of the stack
	func add_effect(pin_index: int, effect: EffectSpec, front: bool = true):
		# TODO: REMOVE?
		if front:
			pending_effects[pin_index].push_front(effect)
		else:
			pending_effects[pin_index].push_back(effect)

## Applies the cardspec at the specified index.
## Raises hella signals.
func execute(card: CardSpec, card_index: int) -> EndStepSpec:
	for pin in pins:
		pin.end_step()
	var ex := Execution.new(len(pins))
	ex.load_card(card, card_index)
	var result := EndStepSpec.new()
	
	var iterations := 0
	while iterations < 1000:
		iterations += 1
		if iterations >= 1000:
			push_error("Execution loop overflow!")
			return
		
		var next_effect := ex.get_next_effect()
#		print("%s: Evaluating %s at %s" % [iterations, next_effect.flavor.effect_name, next_effect.realized_pin])
		if next_effect.flavor == Effects.END_EXECUTION:
#			print("Completed execution after %s iterations." % iterations)
			break
		evaluate_pin(next_effect, ex, result)
	
	result.last_hint = update_visibility()
	result.effects = ex.executed_effects
	for i in len(pins):
		result.activations[i] = pins[i].activated
	
	$Cylinders.set_pin_specs(pins)
	
	return result

## Evaluates a single effect, updating the execution context and emitting signals.
func evaluate_pin(
	effect: EffectSpec, 
	ex: Execution,
	result: EndStepSpec
) -> void:
	# todo
	# TODO
	pass
	
# TODO: check lock solved after each activation

func update_visibility() -> String:
	var new_level := PinSpec.RevealLevel.REVEALED
	for pin in pins:
		new_level = max(new_level, pin.get_reveal_level())
	if new_level == PinSpec.RevealLevel.REVEALED:
		# we didn't hint anything
		return ""
	increment_hint()
	for pin in pins:
		pin.update_pin_visible(new_level, String.chr(_hint_id))
	return String.chr(_hint_id)

## Calculates the preview given a pin index and a channel from a card specs effects
func calculate_preview(pin_index: int, effects: Array[EffectSpec]) -> ResultSpec:
	# TODO
	# TODO
	# TODO
	var result := ResultSpec.new(pins[pin_index])
	
	for effect in effects:
		result.apply_effect(effect)
	result.finalize()

	return result

func update_turn_number() -> int:
	if turn_number < 0:
		push_error("Failed to init turn number!")
		turn_number = 0
	turn_number += 1
	return turn_number

#endregion

## Redraws the pins by reloading the pin specs.
## Useful if you're monkeying with .pins directly
func redraw_pins() -> void:
	$Cylinders.set_pin_specs(pins)

## Perform the end of hand/round/turn fall step, resetting non-bound pins
## to their default state or whatever mechanic I wind up deciding.
func handle_fall() -> void:
	for pin in pins:
		if pin.is_jammed():
			pin.clear_jam() 
		else:
			pin.advance_pin(0, 0)
		pin.end_step()
	$Cylinders.set_pin_specs(pins)
