extends Resource
## Result spec is a dataclass that holds a single pin's preview or previous turn
class_name ResultSpec

## Results in a depth: result dictionary
@export var results: Dictionary[int, Results]

## The depth to show the jam icon at
@export var jam_depth: int

func _init():
	jam_depth = -1
	results = {}
