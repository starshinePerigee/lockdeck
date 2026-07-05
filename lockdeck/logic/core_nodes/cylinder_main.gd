extends Control
## Manages the pins (cylinders) for the lock.

## The one true reference for the current state of all pins.
## Length is the length of active pins - inactive pins are present as hidden objects
## but are not present in the pins array.
@export var pins: Array[PinSpec]

## Resets all pins to their initial position
func reset_all_pins() -> void:
	for pin in pins:
		pin.reset_pin()
	$Cylinders.set_pin_specs(pins)

## Load a new set of pin specs for a new level.
func load_new_pins(new_pins: Array[PinSpec]) -> void:
	pins = new_pins
	$Cylinders.set_pin_specs(new_pins)

## Tells cylinder_main to draw a preview. Should not have game effects.
func preview(card: CardSpec, index: int) -> void:
	pass

## Removes the current preview.
func cancel_preview() -> void:
	pass

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
	
	static var execution_sentinel := EffectSpec.new(Effects.END_EXECUTION)
		
	func _init(pin_count: int) -> void:
		pending_effects = []
		for i in pin_count:
			pending_effects.append([])
	
	## Loads a card into the pending effects dictionary
	func load_card(card: CardSpec, card_index: int) -> void:
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
		var depth := pin.current_depth()
		ex.add_effect(pin_index, EffectSpec.new(depth.effect, depth.value))
		pin.reveal_position()

func test_pin(pin_index: int, test_ahead: int) -> void:
	for i in range(1, 1+test_ahead):
		var offset := i + pins[pin_index].pin_position
		if offset < PinSpec.PIN_DEPTH_COUNT:
			pins[pin_index].set_checked(offset)

## Applies the cardspec at the specified index.
## Raises hella signals.
func execute(card: CardSpec, card_index: int) -> ResultSpec:
	for pin in pins:
		pin.reset_checked()
	var ex := Execution.new(len(pins))
	ex.load_card(card, card_index)
	var result := ResultSpec.new()
	
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
	
	update_visibility()
	
	$Cylinders.set_pin_specs(pins)
	
	return result

## Evaluates a single effect, updating the execution context and emitting signals.
func evaluate_pin(
	effect: EffectSpec, 
	ex: Execution,
	result: ResultSpec
) -> void:
	if effect.realized_pin >= len(pins) or effect.realized_pin < 0:
		push_error("Invalid realized pin: %s" % effect.realized_pin)
		return
	
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
			execute_reveal(effect)
		Effects.JAM:
			execute_jam(effect)
		Effects.CRUSH:
			execute_crush(effect, ex)
		Effects.BOUNCE:
			execute_bounce(effect, ex)
		Effects.OUT_OF_BOUNDS:
			execute_break(result)
		Effects.BREAK:
			execute_break(result)
		Effects.KEY:
			execute_key(result)
		Effects.DEBUG:
			push_error("DEBUG effect flavor called! Pin index %s" % effect.realized_pin)
		_:
			push_warning("Undefined effect flavor effect: %s" % effect.flavor)

func execute_push(effect: EffectSpec, ex: Execution) -> void:
	test_pin(effect.realized_pin, effect.value)
	advance_pin(effect.realized_pin, effect.value, ex)

func execute_test(effect: EffectSpec, ex: Execution) -> void:
	test_pin(effect.realized_pin, effect.value)

func execute_reveal(effect: EffectSpec) -> void:
	for i in range(effect.value):
		pins[effect.realized_pin].reveal_pin(i + 1)

func execute_jam(effect: EffectSpec) -> void:
	pins[effect.realized_pin].add_jam(effect.value)

func execute_crush(effect: EffectSpec, ex: Execution) -> void:
	for i in range(effect.value):
		var pin := pins[effect.realized_pin]
		var oob := pin.advance_pin(1)
		pin.reveal_position()
		
		if oob or pin.current_depth() == Depths.FINAL:
			ex.add_effect(effect.realized_pin, EffectSpec.new(Effects.BREAK))
			return
		else:
			pin.depths[pin.pin_position] = Depths.EMPTY

func execute_bounce(effect: EffectSpec, ex: Execution) -> void:
	var pin := pins[effect.realized_pin]
	var target_depth: int = max(0, pin.pin_position - effect.value)
	var oob := pin.advance_pin(0, target_depth)
	if oob:
		push_error("OOB'ed on bounce? Pin: %s, target: %s" % [effect.realized_pin, target_depth])
		return
	var depth := pin.current_depth()
	ex.add_effect(effect.realized_pin, EffectSpec.new(depth.effect, depth.value))

func execute_key(result: ResultSpec) -> void:
	for pin in pins:
		if not pin.is_solved():
			return
	result.lock_solved = true
	return

func execute_break(result: ResultSpec) -> void:
	result.pick_broke = true

func update_visibility() -> void:
	var new_level := PinSpec.RevealLevel.CLEAR
	for pin in pins:
		for i in range(PinSpec.PIN_DEPTH_COUNT):
			if pin.checked[i]:
				var depth := pin.depths[i]
				if depth in Depths.DANGEROUS_DEPTHS:
					new_level = max(new_level, PinSpec.RevealLevel.DANGEROUS)
				elif depth in Depths.INTERESTING_DEPTHS:
					new_level = max(new_level, PinSpec.RevealLevel.INTERESTING)
				elif depth in Depths.CLEAR_DEPTHS:
					pass
				else:
					push_warning("Unusual depth during update visibility: %s" % depth.depth_name)
	print("Hint level: %s" % new_level)
	for pin in pins:
		for i in range(PinSpec.PIN_DEPTH_COUNT):
			if pin.checked[i]:
				pin.update_visible(i, new_level)
				

#endregion

## Redraws the pins by reloading the pin specs.
## Useful if you're monkeying with .pins directly
func redraw_pins() -> void:
	$Cylinders.set_pin_specs(pins)

## Perform the end of hand/round/turn fall step, resetting non-bound pins
## to their default state or whatever mechanic I wind up deciding.
func handle_fall() -> void:
	for pin in pins:
		pin.advance_pin(0, 0)
	$Cylinders.set_pin_specs(pins)
