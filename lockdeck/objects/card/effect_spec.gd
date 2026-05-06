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
