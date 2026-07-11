extends Resource
## Result spec is a dataclass that holds a single pin's preview or previous turn
class_name ResultSpec

## Results in a depth: result dictionary
@export var results: Dictionary[int, Results]

func update(depth: int, result: Results) -> void:
	if depth in results:
		results[depth] = Results.compare(results[depth], result)
	else:
		results[depth] = result

func _init():
	results = {}