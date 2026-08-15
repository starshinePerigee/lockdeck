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

func _init() -> void:
	effects = {}
	results = []
