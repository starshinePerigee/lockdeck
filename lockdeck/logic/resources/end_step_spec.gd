extends Resource
## This is a very simple dataclass to pass the result of a pin execution
class_name EndStepSpec

@export var pick_broke := false
@export var lock_solved := false
@export var turn_number := -1
@export var last_hint := ""

## Holds all effects as a Dictionary[pin position, Array[EffectSpec))
@export var effects: Dictionary[int, Array]

## Holds all the effects that were activated as a Dictionary[pin position, Array[bool))
@export var activations: Dictionary[int, Array]

func _init() -> void:
	effects = {}
	activations = {}