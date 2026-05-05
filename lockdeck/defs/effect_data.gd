@tool
class_name EffectData
extends Object

#region base class
class EffectDef:
	static func _get_texture(name: String, small: bool) -> Resource:
		var suffix = "_small" if small else ""
		var res_str = "res://assets/effects/icon_%s%s.png" % [name, suffix]
		if FileAccess.file_exists(res_str):
			return load(res_str)
		else:
			return load("res://assets/effects/icon_debug_small.png")
	
	var effect_name:String
	var texture:Resource
	var texture_small:Resource
	
	func _init(name: String):
		self.effect_name = name
		self.texture = _get_texture(name, false)
		self.texture_small = _get_texture(name, true)
#endregion

#region global instances
# the order must match the order of the declaration, below
enum EffectFlavors {DEBUG, FORCE, JAM, BUMP}

static var _defs: Array[EffectDef] = []

static func _get_def() -> Array[EffectDef]:
	if _defs.is_empty():
		_defs = [
			EffectDef.new("debug"),
			EffectDef.new("force"),
			EffectDef.new("jam"),
			EffectDef.new("bump")
		]
		assert(len(_defs) == len(EffectFlavors), "Hey dipshit update the enum")
		print("Loaded %s effects" % len(_defs))
	return _defs

static func get_def(effect: EffectFlavors) -> EffectDef:
	return _get_def()[effect]
#endregion
