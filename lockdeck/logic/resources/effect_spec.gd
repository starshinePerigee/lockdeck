extends Resource
## EffectSpec is the dataclass that defines a single effect as part of a card or depth.
## Note that effects also have a value - so 4 "forces" is a single Force flavored EffectSpec
## with value 4
class_name EffectSpec

## Flavor of effect, defined in EffectData
@export var flavor: EffectData.EffectFlavors

## Value of effect. Can be 0.
@export var value: int

func _init(p_flavor: Variant = 0, p_value: int = 0):
	match type_string(typeof(p_flavor)):
		"int":
			# enums show as ints
			flavor = p_flavor
		"String":
			flavor = EffectData.EffectFlavors.get(p_flavor.to_upper())
		_:
			push_error(
				"Invalid type for effect spec: %s" % [type_string(typeof(flavor))]
			)
	value = p_value
