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

## used in tracking execution logic
var realized_start: int = -1

func add_positions(positions: Array) -> void:
	for position in positions:
		realized_positions[position] = true

func _init(flavor_: Effects = Effects.DEBUG, value_: int = 0):
	flavor = flavor_
	value = value_
	realized_positions = {}
