@tool
extends Resource
class_name EffectSpec

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
