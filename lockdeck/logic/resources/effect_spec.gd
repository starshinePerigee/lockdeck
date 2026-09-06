extends Resource
## EffectSpec is the dataclass that defines a single effect as part of a card or depth.
## Note that effects also have a value - so 4 "pushes" are a single push flavored EffectSpec
## with value 4
class_name EffectSpec

## Flavor of effect, defined in EffectData
@export var flavor: Effects

## Value of effect. Can be 0.
@export var value: int

## used for pin execution logic. carries the value of the pin the effect is applied to.
var realized_pin: int = -1

## used to track the originating depth
var realized_origin: int = -1:
	set(v):
		realized_origin = v
	get():
		if realized_origin < 0:
			push_warning("Reading unrealized origin")
		return realized_origin

## used for displaying previous results. Dictionary as a set
var realized_positions: Dictionary[int, bool]

## track if this effect broke the pick, including as part of oob
var broke_pick: bool = false

func real() -> int:
	if (len(realized_positions) > 0) != (realized_origin >= 0):
		push_error(
			"Effect only partially realized! %s %s %s" 
			% [flavor.effect_name, realized_positions, realized_origin]
		) 
	return len(realized_positions) > 0

func last() -> int:
	if realized_positions:
		return realized_positions.keys().max()
	else:
		return -1

func first() -> int:
	if realized_positions:
		return realized_positions.keys().min()
	else:
		return -1

## Marks a position as touched by this effect. Can be called with the same value multiple times.
func add_position(position: int) -> void:
	realized_positions[position] = true

## Add given positions to this effect spec for tracking purposes
func add_positions(positions: Array) -> void:
	for position in positions:
		realized_positions[position] = true

## sets this effect as jammed
func set_jammed(position: int) -> void:
	add_position(position)
	flavor = Effects.UNJAM

func reify() -> void:
	flavor = Effects.static_registry[flavor.effect_name]

func _init(flavor_: Effects = Effects.DEBUG, value_: int = 0):
	flavor = flavor_
	value = value_
	realized_positions = {}
