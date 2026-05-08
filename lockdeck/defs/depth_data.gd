class_name DepthData
extends Object

#region base class
class DepthDef:
	static func _get_texture(n: String) -> Resource:
		var res_str = "res://assets/depths/depth_%s.png" % [n]
		if FileAccess.file_exists(res_str):
			return load(res_str)
		else:
			return load("res://assets/depths/depth_debug.png")
	
	var depth_name:String
	var texture:Resource
	var effect:EffectData.EffectFlavors
	
	func _init(name_: String, effect_: EffectData.EffectFlavors):
		self.depth_name = name_
		self.texture = _get_texture(name_)
		self.effect = effect_
#endregion

#region global instances
# the order must match the order of the declaration, below
enum DepthFlavors {DEBUG, HIDDEN, EMPTY, KEY, BREAK, BASE, BOUNCE}

static var _defs: Array[DepthDef] = []

static func _get_def() -> Array[DepthDef]:
	if _defs.is_empty():
		_defs = [
			DepthDef.new("debug", EffectData.EffectFlavors.DEBUG),
			DepthDef.new("hidden", EffectData.EffectFlavors.DEBUG),
			DepthDef.new("empty", EffectData.EffectFlavors.EMPTY),
			DepthDef.new("key", EffectData.EffectFlavors.KEY),
			DepthDef.new("break", EffectData.EffectFlavors.BREAK),
			DepthDef.new("base", EffectData.EffectFlavors.EMPTY),
			DepthDef.new("bounce", EffectData.EffectFlavors.BOUNCE),
		]
		assert(len(_defs) == len(DepthFlavors), "Hey dipshit update the enum")
		print("Loaded %s depths" % len(_defs))
	return _defs

static func get_def(depth: DepthFlavors) -> DepthDef:
	return _get_def()[depth]
#endregion
