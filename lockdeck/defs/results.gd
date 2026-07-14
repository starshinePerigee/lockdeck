extends Resource
## Stores all result flavors
class_name Results

static func _get_texture(n: String) -> Resource:
	var res_str := "res://assets/results/result_%s.png" % n
	if ResourceLoader.exists(res_str):
		return load(res_str)
	else:
		return load("res://assets/results/result_debug.png")

## Human readable name of result - try not to overlap with an effect
var result_name: String

## Texture
var texture: Resource

func _init(name: String):
	self.result_name = name
	self.texture = _get_texture(name)


## Debug result
static var DEBUG := Results.new("debug")

## Empty, used for spacing
static var EMPTY := Results.new("empty")

## No result - different than empty. Used for like, hinting an revealed space.
static var NONE := Results.new("none")

## Activated - typically by push or crush
static var ACTIVATE := Results.new("activate")

## Hinted - typically by test or multiple push
static var HINT := Results.new("hint")

## Revealed - by reveal depth
static var REVEAL := Results.new("reveal")

## Crush - by crush depth
static var CRUSH := Results.new("crush")

## out of bounds / pick break; subtype of activate (probably)
static var BREAK := Results.new("break")

## Unlock - subtype of activate (probably)
static var UNLOCK := Results.new("unlock")


## Relative priorities, low to high
static var PRIORITY: Array[Results] = [
	EMPTY,
	NONE,
	HINT,
	REVEAL,
	ACTIVATE,
	UNLOCK,
	CRUSH,
	BREAK,
	DEBUG,
]


## Compare two results, returning the highest priority one
static func compare(result_a: Results, result_b: Results) -> Results:
	var idx: int = max(PRIORITY.find(result_a), PRIORITY.find(result_b))
	
	if idx == -1:
		push_error(
			"Attempted to compare unlisted results: %s, %s"
			% [result_a.result_name, result_b.result_name]
		)
		return DEBUG
	
	return PRIORITY[idx]