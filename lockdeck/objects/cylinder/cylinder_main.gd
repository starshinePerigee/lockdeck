extends Node
## Manages the pins (cylinders) for the lock.

## The one true reference for the current state of all pins.
## Length is the lenght of active pins - inactive pins are present as hidden objects
## but are not present in the pins array.
@export var pins: Array[PinSpec]

## Resets all pins to their initial position
func reset_all_pins() -> void:
	var template_spec := PinSpec.new()
	for i in len(pins):
		pins[i].reveals = template_spec.reveals.duplicate()
		pins[i].pin_position = template_spec.pin_position
		pins[i].pin_set = template_spec.pin_set
		pins[i].key_set = template_spec.key_set
		pins[i].jam_count = template_spec.jam_count
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

#region pick execution logic
class Execution:
	## All pending effects in a Dictionary[int, Array[EffectSpec]]
	## Note that int is the cylinder, not the cylinder offset.
	var pending_effects: Dictionary[int, Array]
	## When an effect executes, if a depth triggers additional effects these
	## go on the effect stack right above the current effect. This pointer tracks
	## that position
	var result_effect_pointer: int
	## If a pick breaks, we only want to emit that signal once.
	var pick_broke_emitted: bool
	
	func _init(pin_count: int) -> void:
		pending_effects = {}
		for i in len(pin_count):
			pending_effects[i] = []
		result_effect_pointer = 0
		pick_broke_emitted = false

## Applies the cardspec at the specified index.
## Raises hella signals.
func execute(card: CardSpec, index: int) -> void:
	var ex := Execution.new(len(pins))

#endregion

## Perform the end of hand/round/turn fall step, resetting non-bound pins
## to their default state or whatever mechanic you decide.
func handle_fall() -> void:
	pass