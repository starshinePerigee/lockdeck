extends Resource
## Result spec is a dataclass that holds a single pin's preview or previous turn
class_name ResultSpec

## Results in a depth: result dictionary
@export var results: Dictionary[int, Results]

## test results in a depth: reveal dictionary
@export var test_results: Dictionary[int, PinSpec.RevealLevel]

## The depth to show the jam icon at
@export var jam_depth: int

@export var bomb_defused: bool

func _init():
	jam_depth = -1
	results = {}
	test_results = {}
	bomb_defused = false
