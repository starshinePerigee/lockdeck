class_name DepthData
extends Object

#region base class
class DepthDef:
	static func _get_texture(n: String) -> Resource:
		var res_str = "res://assets/icons/depths/%s.png" % [n]
		if FileAccess.file_exists(res_str):
			return load(res_str)
		else:
			return load("res://assets/icons/depths/debug.png")
	
	var depth_name:String
	var mod_color:Color
	var texture:Resource
	
	func _init(name: String, mut: Color):
		self.depth_name = name
		self.mod_color = mut
		self.texture = _get_texture(name)
#endregion

#region global instances
# the order must match the order of the declaration, below
enum DepthFlavors {DEBUG, TEMPLATE}

static var _defs: Array[DepthDef] = []

static func _get_def() -> Array[DepthDef]:
	if _defs.is_empty():
		_defs = [
			DepthDef.new("debug", Color("d63384")),
			DepthDef.new("template", Color("dddddd"))
		]
		assert(len(_defs) == len(DepthFlavors), "Hey dipshit update the enum")
		print("Loaded %s depths" % len(_defs))
	return _defs

static func get_def(depth: DepthFlavors) -> DepthDef:
	return _get_def()[depth]
#endregion
