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

## used for displaying previous results. Dictionary as a set
var realized_positions: Dictionary[int, bool]

## track if this effect broke the pick for reasons other than oob
var broke_pick: bool = false

## track if this effect pushed pin out of bounds
var oobed: bool = false

## track if this effect unlocked the current pin
var unlock_pin: bool = false

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

func _init(flavor_: Effects = Effects.DEBUG, value_: int = 0):
	flavor = flavor_
	value = value_
	realized_positions = {}
