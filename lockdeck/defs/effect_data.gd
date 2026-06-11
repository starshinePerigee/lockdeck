@tool
class_name EffectData
## Contains the defined data collection effects - both pick card and depth effects
extends Object

#region base class
## A single defined set of data for a single Effect.
class EffectDef:
	static func _get_texture(name: String, small: bool) -> Resource:
		var suffix = "_small" if small else ""
		var res_str = "res://assets/effects/icon_%s%s.png" % [name, suffix]
		if ResourceLoader.exists(res_str):
			return load(res_str)
		else:
			return load("res://assets/effects/icon_debug_small.png")
		
	## Human readable name of this effect, in lower case.
	var effect_name:String
	## Large texture, such as used for indicators and help.
	var texture:Resource
	## Small texture, such as used on a pick card.
	var texture_small:Resource
	
	func _init(name: String):
		self.effect_name = name
		self.texture = _get_texture(name, false)
		self.texture_small = _get_texture(name, true)
#endregion

#region global instances
# the order must match the order of the declaration, below
enum EffectFlavors {
	DEBUG,  ## DEBUG
	EMPTY,  ## do nothing. Depth / pick effect
	FORCE,  ## move the pin
	JAM,  ## apply jam
	TEST,  ## reveal the next depth but do not advance the pin
	JUMP,  ## Skip the next depth
	KEY,  ## Depth effect - unlock the current pin
	BREAK,  ## Depth effect - break the current pin 
	BOUNCE,  ## Depth effect - bounce the pin back to the top
	OUT_OF_BOUNDS,  ## Depth effect - pick out of bounds (typically breaks)
}

static var _defs: Array[EffectDef] = []

static func _get_def() -> Array[EffectDef]:
	if _defs.is_empty():
		_defs = [
			EffectDef.new("debug"),
			EffectDef.new("empty"),
			EffectDef.new("force"),
			EffectDef.new("jam"),
			EffectDef.new("test"),
			EffectDef.new("jump"),
			EffectDef.new("key"),
			EffectDef.new("break"),
			EffectDef.new("bounce"),
			EffectDef.new("out_of_bounds"),
		]
		assert(len(_defs) == len(EffectFlavors), "Hey dipshit update the enum")
		print("Loaded %s effects" % len(_defs))
	return _defs

## Gets a live EffectDef object given an EffectFlavors enum value.
static func get_def(effect: EffectFlavors) -> EffectDef:
	return _get_def()[effect]
#endregion
