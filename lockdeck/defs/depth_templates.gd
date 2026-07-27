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
# pp5	1	2	3	4	5
#	1	0	0	1	1	1
#	2	0	1	1	2	2
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
var end_weight

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
	end_weight = weights[2]

## Returns how many pins to apply this depth to.
func pin_count(pins: int) -> int:
	return max(roundi((depths_per_five + 0.00001) / 5.0 * pins), 1)

## returns how many depths this will require to fully place at the given number of pins.
func total_depths_placed(pins: int) -> int:
	# TODO: handle minor?
	return pin_count(pins)
