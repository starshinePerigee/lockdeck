extends Resource
## EffectSpec is the dataclass that defines a single effect as part of a card or depth.
## Note that effects also have a value - so 4 "forces" is a single Force flavored EffectSpec
## with value 4
class_name EffectSpec

## Flavor of effect, defined in EffectData
@export var flavor: Effects

## Value of effect. Can be 0.
@export var value: int

## used for pin execution logic. carries the value of the pin the effect is applied to.
var realized_pin: int = -1

func _init(flavor_: Effects, value_: int = 0):
	flavor = flavor_
	value = value_
