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

## Net hazard - levels will be built to a certain hazard level
var net_hazard: int
## How frequently to include this depth for early (1-3 pin) locks
var early_weight
## How frequently to include this depth for midgame (4 and early 5 pin) locks
var mid_weight
## How frequently to include this depth in extended endgame locks
var late_weight

func _init(
	depth_: Depths,
	hazard: int,
	weights: Array[int],
	per_five: int = 5,
	minor: Depths = null
):
	depth = depth_
	minor_depth = minor
	net_hazard = hazard
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
	0,
	[-1, -1, -1],
	5,
	Depths.WARN
)

#region friendly
## Intentionally place empties
static var EMPTY := DepthTemplates.new(
	Depths.EMPTY,
	-1,
	[0, 1, 3],
	3,
)

static var UNLOCK := DepthTemplates.new(
	Depths.LUCKY,
	-3,
	[0, 2, 1],
	2
)

static var BREATH := DepthTemplates.new(
	Depths.BREATH,
	-1,
	[1, 1, 3],
	2
)

static var HINT := DepthTemplates.new(
	Depths.HINT,
	-2,
	[2, 2, 2],
	4,
)

#endregion

#region interesting

static var PUSH := DepthTemplates.new(
	Depths.PUSH,
	0,
	[4, 3, 3],
	4
)

static var JAM := DepthTemplates.new(
	Depths.JAM,
	1,
	[2, 3, 4],
	3,
)

static var BOUNCE := DepthTemplates.new(
	Depths.BOUNCE,
	2,
	[3, 2, 2],
	3
)

static var FUMBLE := DepthTemplates.new(
	Depths.FUMBLE,
	3,
	[1, 2, 2],
	3
)

static var TWIST := DepthTemplates.new(
	Depths.TWIST,
	2,
	[0, 0, 3],
	2
)

static var SLIP := DepthTemplates.new(
	Depths.SLIP,
	2,
	[0, 2, 2],
	1,
	Depths.SLIP
)

#endregion

#region breaks

static var SPIKE := DepthTemplates.new(
	Depths.SPIKE,
	2,
	[2, 2, 2],
	3
)

static var TRAP := DepthTemplates.new(
	Depths.TRAP,
	2,
	[1, 2, 2],
	2
)

static var GATE := DepthTemplates.new(
	Depths.GATE_LOCKED,
	5,
	[1, 1, 1],
	3,
	Depths.GATE_KEY
)

static var LABYRINTH := DepthTemplates.new(
	Depths.LABYRINTH,
	3,
	[0, 1, 2],
	2
)

static var SURPRISE := DepthTemplates.new(
	Depths.SURPRISE,
	4,
	[0, 1, 2],
	1
)

#endregion

static var ALL_TEMPLATES := [
	EMPTY,
	UNLOCK,
	BREATH,
	HINT,
	
	PUSH,
	JAM,
	BOUNCE,
	FUMBLE,
	TWIST,
	SLIP,
	
	SPIKE,
	LABYRINTH,
	TRAP,
	SURPRISE,
	GATE,
]
