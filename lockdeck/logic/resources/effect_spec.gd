@tool
extends Resource
class_name EffectSpec

# TODO: wtf is this
# TODO: also needs docs
# TODO: when you get to the cards ig

# TODO: is this why cards take like 150 ms to draw

@export var flavor := EffectData.EffectFlavors.DEBUG:
	set(v):
		flavor = v
		emit_changed()
	
@export var value := 0:
	set(v):
		value = v
		emit_changed()

func _init(p_flavor: Variant = 0, p_value: int = 0):
	match type_string(typeof(p_flavor)):
		"int":
			# enums show as ints
			flavor = p_flavor
		"String":
			flavor = EffectData.EffectFlavors.get(p_flavor.to_upper())
		_:
			push_error("Invalid type for effect spec: %s" % [type_string(typeof(flavor))])
	value = p_value
