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

## Load a new set of pin specs for a new level.
func load_new_pins(new_pins: Array[PinSpec]) -> void:
	pins = new_pins
	$Cylinders.set_pin_specs(new_pins)
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
	func load_card(card: CardSpec, card_index: int) -> void:
		card.unrealize_effects()
		for k in card.effects.keys():
			var pin_index: int = card_index - k
			if pin_index >= 0 and pin_index < len(pending_effects):
				for e in card.effects[k]:
					add_effect(pin_index, e, false)
	
	## Gets the next effect, or EffectSpec.. Use has_next_effect to avoid that.
	## Effects are pulled from pins high to low (right to left), down the effect stack.
	## Each effect that is returned is popped from the pending effects dictionary.
	func get_next_effect() -> EffectSpec:
		for pin_index in range(len(self.pending_effects) - 1, -1, -1):
			if len(self.pending_effects[pin_index]) > 0:
				var effect: EffectSpec = self.pending_effects[pin_index].pop_front()
				effect.realized_pin = pin_index
				return effect
		return execution_sentinel
	
	## Adds effects to the top of the stack
	func add_effect(pin_index: int, effect: EffectSpec, front: bool = true):
		if front:
			pending_effects[pin_index].push_front(effect)
		else:
			pending_effects[pin_index].push_back(effect)

	## Save an effect if it has realized positions
	func record_effect(effect: EffectSpec) -> void:
		if len(effect.realized_positions) > 0:
			executed_effects[effect.realized_pin].append(effect)

## Moves pin_index pin forward by advance_by.
## Note that this only trips jam once, skips intermediate depths, etc.
func advance_pin(pin_index: int, advance_by: int, ex: Execution) -> void:
	var pin := pins[pin_index]
	if pin.is_jammed():
		if pin.jam_count >= advance_by:
			pin.add_jam(-advance_by)
			return
		else:
			advance_by -= pin.jam_count
			pin.add_jam(-pin.jam_count) 
	
	if pin.advance_pin(advance_by):
		ex.add_effect(pin_index, EffectSpec.new(Effects.OUT_OF_BOUNDS))
	else:
		var depth := pin.activate_and_get_depth()
		ex.add_effect(pin_index, EffectSpec.new(depth.effect, depth.value))
		pin.reveal_position()

func test_pin(pin_index: int, test_ahead: int) -> void:
	if pins[pin_index].is_jammed():
		return
	for i in range(1, 1+test_ahead):
		var offset := i + pins[pin_index].pin_position
		if offset < PinSpec.PIN_DEPTH_COUNT:
			pins[pin_index].set_checked(offset)

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
	
	$Cylinders.set_pin_specs(pins)
	
	return result

## Evaluates a single effect, updating the execution context and emitting signals.
func evaluate_pin(
	effect: EffectSpec, 
	ex: Execution,
	result: EndStepSpec
) -> void:
	if effect.realized_pin >= len(pins) or effect.realized_pin < 0:
		push_error("Invalid realized pin: %s" % effect.realized_pin)
		return
	
	if len(ex.executed_effects[effect.realized_pin]) == 0:
		var empty_effect := EffectSpec.new(Effects.EMPTY)
		empty_effect.realized_pin = effect.realized_pin
		empty_effect.add_positions([_effect_pos(empty_effect)])
		ex.record_effect(empty_effect)
	
	match effect.flavor:
		# ALL OF THE GAME LOGIC GOES HERE: 
		# (BALATRO REFERENCE LMAO)
		Effects.EMPTY:
			pass
		Effects.PUSH:
			execute_push(effect, ex)
		Effects.TEST:
			execute_test(effect, ex)
		Effects.REVEAL:
			execute_reveal(effect, ex)
		Effects.JAM:
			execute_jam(effect, ex)
		Effects.CRUSH:
			execute_crush(effect, ex)
		Effects.BOUNCE:
			execute_bounce(effect, ex)
		Effects.OUT_OF_BOUNDS:
			execute_break(effect, ex, result)
		Effects.BREAK:
			execute_break(effect, ex, result)
		Effects.UNLOCK:
			execute_unlock(effect, ex, result)
		Effects.DEBUG:
			push_error("DEBUG effect flavor called! Pin index %s" % effect.realized_pin)
		_:
			push_warning("Undefined effect flavor effect: %s" % effect.flavor)

## Helper function to get the current pin position for an effect
func _effect_pos(effect: EffectSpec) -> int:
	return pins[effect.realized_pin].pin_position

## Creates a new jam effect when an effect's effects are totally jammed
func _unjam_effect(effect: EffectSpec) -> EffectSpec:
	var new_effect := EffectSpec.new(Effects.UNJAM, 1)
	new_effect.realized_pin = effect.realized_pin
	new_effect.add_positions([_effect_pos(new_effect)])
	return new_effect

func execute_push(effect: EffectSpec, ex: Execution) -> void:
	test_pin(effect.realized_pin, effect.value)
	var start_depth := _effect_pos(effect)
	advance_pin(effect.realized_pin, effect.value, ex)
	var end_depth := _effect_pos(effect)
	if start_depth == end_depth:
		ex.record_effect(_unjam_effect(effect))
	else:
		effect.add_positions(range(start_depth + 1, _effect_pos(effect) + 1, 1))
		ex.record_effect(effect)

func execute_test(effect: EffectSpec, ex: Execution) -> void:
	test_pin(effect.realized_pin, effect.value)
	if pins[effect.realized_pin].is_jammed():
		ex.record_effect(_unjam_effect(effect))
	else:
		var start_depth := _effect_pos(effect) + 1
		effect.add_positions(range(start_depth, start_depth + effect.value))
		ex.record_effect(effect)

func execute_reveal(effect: EffectSpec, ex: Execution) -> void:
	if pins[effect.realized_pin].is_jammed():
		ex.record_effect(_unjam_effect(effect))
		return
	for i in range(effect.value):
		pins[effect.realized_pin].reveal_pin(i + 1)
	var start_depth := _effect_pos(effect) + 1
	effect.add_positions(range(start_depth, start_depth + effect.value))
	ex.record_effect(effect)

func execute_jam(effect: EffectSpec, ex: Execution) -> void:
	pins[effect.realized_pin].add_jam(effect.value)
	effect.add_positions([_effect_pos(effect)])
	ex.record_effect(effect)

func execute_crush(effect: EffectSpec, ex: Execution) -> void:
	var pin := pins[effect.realized_pin]
	
	var depth_offset := 0
	var is_final := false
	
	var effect_depths: Array = [_effect_pos(effect)]
	for i in range(effect.value):
		var target := pin.pin_position + depth_offset
		if target >= PinSpec.PIN_DEPTH_COUNT:
			is_final = true
			break
		
		var next_depth := pin.depths[target]
		if next_depth == Depths.FINAL:
			is_final = true
			break
		elif next_depth == Depths.BASE:
			# this can happen if you jam and then crush immediately
			pass
		else:
			pin.reveal_position(target)
			pin.depths[target] = Depths.EMPTY
		
		if pin.is_jammed():
			pin.add_jam(-1)
		else:
			effect_depths.append(target)
			depth_offset += 1
	
	print(effect_depths)
	effect.add_positions(effect_depths)
	if len(effect_depths) == 1:
		ex.record_effect(_unjam_effect(effect))
	else:
		ex.record_effect(effect)
	
	if is_final:
		ex.add_effect(effect.realized_pin, EffectSpec.new(Effects.BREAK))
		pin.advance_pin(0, PinSpec.PIN_DEPTH_COUNT - 1)
	else:
		advance_pin(effect.realized_pin, depth_offset, ex)

func execute_bounce(effect: EffectSpec, ex: Execution) -> void:
	var pin := pins[effect.realized_pin]
	var start_depth := _effect_pos(effect)
	var target_depth: int = max(0, pin.pin_position - effect.value)
	var oob := pin.advance_pin(0, target_depth)
	if oob:
		push_error("OOB'ed on bounce? Pin: %s, target: %s" % [effect.realized_pin, target_depth])
		return
	effect.add_positions(range(_effect_pos(effect), start_depth + 1, 1))
	print(effect.realized_positions)
	var depth := pin.activate_and_get_depth()
	ex.add_effect(effect.realized_pin, EffectSpec.new(depth.effect, depth.value))
	ex.record_effect(effect)

func execute_unlock(effect: EffectSpec, ex: Execution, result: EndStepSpec) -> void:
	effect.add_positions([_effect_pos(effect)])
	ex.record_effect(effect)
	for pin in pins:
		if not pin.is_solved():
			return
	result.lock_solved = true

func execute_break(effect: EffectSpec, ex: Execution, result: EndStepSpec) -> void:
	result.pick_broke = true
	effect.add_positions([_effect_pos(effect)])
	ex.record_effect(effect)

func update_visibility() -> String:
	var new_level := PinSpec.RevealLevel.REVEALED
	for pin in pins:
		for i in range(PinSpec.PIN_DEPTH_COUNT):
			if pin.get_checked(i):
				var depth := pin.depths[i]
				if depth in Depths.DANGEROUS_DEPTHS:
					new_level = max(new_level, PinSpec.RevealLevel.DANGEROUS)
				elif depth in Depths.INTERESTING_DEPTHS:
					new_level = max(new_level, PinSpec.RevealLevel.INTERESTING)
				elif depth in Depths.CLEAR_DEPTHS:
					new_level = max(new_level, PinSpec.RevealLevel.CLEAR)
				else:
					push_warning("Unusual depth during update visibility: %s" % depth.depth_name)
	if new_level == PinSpec.RevealLevel.REVEALED:
		# we didn't hint anything
		return ""
	increment_hint()
	for pin in pins:
		for i in range(PinSpec.PIN_DEPTH_COUNT):
			if pin.checked[i]:
				pin.update_visible(i, new_level, String.chr(_hint_id))
	return String.chr(_hint_id)

## Calculates the preview given a pin index and a channel from a card specs effects
func calculate_preview(pin_index: int, effects: Array[EffectSpec]) -> ResultSpec:
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
			pin.add_jam(-pin.jam_count) 
		else:
			pin.advance_pin(0, 0)
		pin.end_step()
	$Cylinders.set_pin_specs(pins)
