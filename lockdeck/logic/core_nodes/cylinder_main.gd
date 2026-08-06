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
	# TODO
	pass
#	var results: Array[ResultSpec] = []
#	for i in len(pins):
#		var effect_offset := index - i
#		if effect_offset in card.effects:
#			var effects: Array[EffectSpec] = []
#			effects.assign(card.effects[effect_offset])
#			results.append(calculate_preview(i, effects))
#		else:
#			results.append(ResultSpec.new())
#	$Cylinders.set_results(results)

## Removes the current preview.
func cancel_preview() -> void:
	$Cylinders.clear_results()

## Gets the currently hovered pin during a drag
func get_current_drag_target() -> int:
	return $Cylinders.current_active_pin()

#region pick execution logic
## Loads a CardSpec, turning it into a dictionary of live duplicated effects
## and loading them into the relevant pins
func load_card(card: CardSpec, card_index: int) -> void:
	for k in card.effects.keys():
		var pin_index: int = card_index - k
		if pin_index >= 0 and pin_index < len(pins):
			for e in card.effects[k]:
				var new_e := EffectSpec.new(e.flavor, e.value)
				pins[pin_index].pending_effects.append(new_e)

## Applies the cardspec at the specified index.
func execute(card: CardSpec, card_index: int) -> EndStepSpec:
	for pin in pins:
		pin.end_step()
	
	load_card(card, card_index)
	
	var result := EndStepSpec.new()
	
	for pin_index in range(len(pins) - 1, 0, -1):
		if len(pins[pin_index].pending_effects) > 0:
			var executed_effects := pins[pin_index].execute()
			for effect in executed_effects:
				effect.realized_pin = pin_index
				if effect.broke_pick:
					result.pick_broke = true
			result.effects[pin_index] = executed_effects
			result.activations[pin_index] = pins[pin_index].activated
	
	result.last_hint = update_visibility()
	result.lock_solved = lock_solved()
	$Cylinders.set_pin_specs(pins)
	
	return result

func lock_solved() -> bool:
	for pin in pins:
		if not pin.is_solved():
			return false
	return true

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
