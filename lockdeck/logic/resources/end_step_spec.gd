extends Resource
## This is a very simple dataclass to pass the result of a pin execution
class_name EndStepSpec

@export var pick_broke := false
@export var lock_solved := false
@export var turn_number := -1
@export var last_hint := ""

## Holds all effects as a Dictionary[pin position, Array[EffectSpec))
@export var effects: Dictionary[int, Array]

## Holds all results
@export var results: Array[ResultSpec]

func record_effect(effect: EffectSpec, realized_pin: int) -> void:
	if effect.flavor in [Effects.EMPTY]:
		return
	if effect.broke_pick:
		pick_broke = true
	effect.realized_pin = realized_pin
	
	if realized_pin not in effects:
		effects[realized_pin] = [effect]
	else:
		effects[realized_pin].append(effect)

func print() -> void:
	var hint_str: String
	if last_hint:
		hint_str = "hint %s" % last_hint
	else:
		hint_str = "no hint"
	
	print(
		"Results for turn %s (%s)"
		% [turn_number, hint_str]
	)
	
	for k in effects.keys():
		var s := "    Pin %s: " % k
		for effect in effects[k]:
			s += "%s: " % effect.flavor.effect_name
			for pos in effect.realized_positions:
				s += "%s" % pos
			s += " "
		print(s)
	
	if pick_broke:
		print("Pick broke!")
	if lock_solved:
		print("Lock solved!")
	if not (pick_broke or lock_solved):
		print("No major effects.")

func _init() -> void:
	effects = {}
	results = []
