extends Resource
## Defines depth templates used for building locks
class_name DepthTemplates

## Core depth - will be placed lower on the pin than the minor depth
var depth: Depths
## Minor depth - will be placed higher on the pin, if a depth is placed
var minor_depth: Depths
## How many pins (out of five) should get this depth.
## This scales; ie - if 2/5 pins get this depth, then for 3 pins, 2/5*4=1.6=2
## Will always be at least 1
var depths_per_five: int
# dp5 reference:
#		pins
# dp5	1	2	3	4	5
#	1	1	1	1	1	1
#	2	1	1	1	2	2
#	3	1	1	2	2	3
#	4	1	2	2	3	4
#	5	1	2	3	4	5

## overrides the above and will always place this many depths. 0 to disregard (default)
var absolute_limit: int

enum Difficulty {
	ESSENTIAL = 3,
	CRITICAL = 2,
	ANNOYING = 1,
	EMPTY = 0,
	HELPFUL = -1
}

var difficulty: Difficulty
## How frequently to include this depth for early (1-3 pin) locks
var early_weight
## How frequently to include this depth for midgame (4 and early 5 pin) locks
var mid_weight
## How frequently to include this depth in extended endgame locks
var late_weight

func _init(
	depth_: Depths,
	difficulty_: Difficulty,
	weights: Array[int],
	per_five: int = 5,
	minor: Depths = null
):
	depth = depth_
	minor_depth = minor
	difficulty = difficulty_
	absolute_limit = 0
	depths_per_five = per_five
	early_weight = weights[0]
	mid_weight = weights[1]
	late_weight = weights[2]

## Returns how many pins to apply this depth to.
func pin_count(pins: int) -> int:
	return max(roundi((depths_per_five + 0.00001) / 5.0 * pins), 1)

func depths_per_pin() -> int:
	if minor_depth == null:
		return 1
	else:
		return 2

## returns how many depths this will require to fully place at the given number of pins.
func total_depths_placed(pins: int) -> int:
	return pin_count(pins) * depths_per_pin()

## Prints the template
func as_str() -> String:
	var return_str := depth.depth_name
	if minor_depth != null:
		return_str += " / %s" % minor_depth.depth_name
	return return_str

## Break is automatically placed on every pin
static var BREAK := DepthTemplates.new(
	Depths.BREAK,
	Difficulty.ESSENTIAL,
	[1, 1, 1],
	5,
	Depths.WARN
)

#region friendly
## Intentionally place empties
static var EMPTY := DepthTemplates.new(
	Depths.EMPTY,
	Difficulty.HELPFUL,
	[0, 1, 3],
	3,
)

static var UNLOCK := DepthTemplates.new(
	Depths.LUCKY,
	Difficulty.HELPFUL,
	[0, 2, 1],
	2
)

static var BREATH := DepthTemplates.new(
	Depths.BREATH,
	Difficulty.HELPFUL,
	[1, 1, 3],
	2
)

static var HINT := DepthTemplates.new(
	Depths.HINT,
	Difficulty.HELPFUL,
	[2, 2, 2],
	4,
)

#endregion

#region interesting

static var PUSH := DepthTemplates.new(
	Depths.PUSH,
	Difficulty.ANNOYING,
	[4, 3, 3],
	4
)

static var JAM := DepthTemplates.new(
	Depths.JAM,
	Difficulty.ANNOYING,
	[2, 3, 4],
	3,
)

static var BOUNCE := DepthTemplates.new(
	Depths.BOUNCE,
	Difficulty.ANNOYING,
	[3, 2, 2],
	3
)

static var FUMBLE := DepthTemplates.new(
	Depths.FUMBLE,
	Difficulty.ANNOYING,
	[1, 2, 2],
	2
)

static var TWIST := DepthTemplates.new(
	Depths.TWIST,
	Difficulty.ANNOYING,
	[0, 0, 3],
	2
)

static var SLIP_2 := DepthTemplates.new(
	Depths.SLIP,
	Difficulty.ANNOYING,
	[0, 1, 1],
	1,
	Depths.SLIP
)

static var SLIP_1 := DepthTemplates.new(
	Depths.SLIP,
	Difficulty.ANNOYING,
	[0, 1, 1],
	3,
)

#endregion

#region breaks

static var SPIKE := DepthTemplates.new(
	Depths.SPIKE,
	Difficulty.CRITICAL,
	[2, 2, 2],
	4
)

static var TRAP := DepthTemplates.new(
	Depths.TRAP,
	Difficulty.CRITICAL,
	[1, 2, 2],
	3
)

static var LABYRINTH := DepthTemplates.new(
	Depths.LABYRINTH,
	Difficulty.CRITICAL,
	[0, 1, 2],
	2
)

static var GATE := DepthTemplates.new(
	Depths.GATE_LOCKED,
	Difficulty.CRITICAL,
	[1, 1, 1],
	3,
	Depths.GATE_KEY
)

static var CATCH := DepthTemplates.new(
	Depths.CATCH,
	Difficulty.CRITICAL,
	[0, 1, 3],
	3
)

static var SURPRISE := DepthTemplates.new(
	Depths.SURPRISE,
	Difficulty.CRITICAL,
	[0, 1, 2],
	1
)

static var BOMB := DepthTemplates.new(
	Depths.BOMB,
	Difficulty.CRITICAL,
	[1, 2, 3],
	2
)

#endregion

static var ALL_TEMPLATES: Array[DepthTemplates] = [
	BREAK,

	EMPTY,
	UNLOCK,
	BREATH,
	HINT,
	
	PUSH,
	JAM,
	BOUNCE,
	FUMBLE,
	TWIST,
	SLIP_1,
	SLIP_2,
	
	SPIKE,
	TRAP,
	LABYRINTH,
	GATE,
	CATCH,
	SURPRISE,
	BOMB
]

static var template_catalog: Dictionary[Difficulty, Array]

static func _static_init() -> void:
	for d in Difficulty.values():
		template_catalog[d] = []
	
	for dt in ALL_TEMPLATES:
		template_catalog[dt.difficulty].append(dt)
