extends Control
## Manages the pins (cylinders) for the lock.

## The one true reference for the current state of all pins.
## Length is the length of active pins - inactive pins are present as hidden objects
## but are not present in the pins array.
@export var pins: Array[PinSpec]

## Used for simulation purposes
var _shadow_pins: Array[PinSpec]

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
	_shadow_pins = []
	for i in len(pins):
		_shadow_pins.append(PinSpec.new())
		pins[i].shadow_clone(_shadow_pins[i])
	$Cylinders.set_pin_specs(new_lock.pins)
	turn_number = 0
	_hint_id = -1

## Tells cylinder_main to draw a preview. Should not have game effects.
func preview(card: CardSpec, index: int) -> EndStepSpec:
	for i in len(pins):
		pins[i].reset_shadow(_shadow_pins[i])
	
	var end_step := execute(card, index, true)
	
	show_preview(end_step)
	return end_step

## Loads a preview
func show_preview(end_step: EndStepSpec) -> void:
	$Cylinders.set_results(end_step.results)

## Removes the current preview.
func cancel_preview() -> void:
	$Cylinders.clear_results()

## Gets the currently hovered pin during a drag
func get_current_drag_target() -> int:
	return $Cylinders.current_active_pin()

#region pick execution logic
## Applies the cardspec at the specified index.
func execute(card: CardSpec, card_position: int, shadow := false) -> EndStepSpec:
	# setup
	var target_pins := _shadow_pins
	if not shadow:
		target_pins = pins
	
	for pin in target_pins:
		pin.end_step()
	
	var result := EndStepSpec.new()
	
	# execute the card's effects
	for pin_index in range(len(target_pins) - 1, -1, -1):
		var pin := target_pins[pin_index]
		var card_index = card_position - pin_index
		var effects: Array[EffectSpec] = []
		
		if card_index in card.effects.keys():
			for e in card.effects[card_index]:
				var new_e := EffectSpec.new(e.flavor, e.value)
				effects.append(new_e)
		
#		print(
#			"Executing pin %s with %s effects (shadow: %s)" 
#			% [pin_index, len(effects), shadow]
#		)
		effects.append_array(pin.execute(effects))

		for effect in effects:
			result.record_effect(effect, pin_index)
	
	# activate every pin
	for pin_index in len(target_pins):
		var effect := target_pins[pin_index].activate()
		result.record_effect(effect, pin_index)
	
	# clean up and record
	for pin in target_pins:
		result.results.append(pin.get_result_spec())
		result.picks_twisted += pin.twist_count
	
	result.lock_solved = lock_solved()
	if not shadow:
		update_visibility(result)
		$Cylinders.animate_pins(pins, result.results)
		for i in len(pins):
			pins[i].shadow_clone(_shadow_pins[i])
	return result

func lock_solved() -> bool:
	for pin in pins:
		if not pin.is_solved():
			return false
	return true

func update_visibility(result: EndStepSpec):
	var new_level := PinSpec.RevealLevel.REVEALED
	for pin in pins:
		new_level = max(new_level, pin.get_reveal_level())
	if new_level == PinSpec.RevealLevel.REVEALED:
		# we didn't hint anything, leave endstepspec as the defaults
		return
	increment_hint()
	for pin in pins:
		pin.update_pin_visible(new_level, String.chr(_hint_id))
	
	result.last_reveal = new_level
	result.last_hint = String.chr(_hint_id)

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
		pin.end_turn_and_fall()
	$Cylinders.set_pin_specs(pins)
