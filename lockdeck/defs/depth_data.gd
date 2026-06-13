class_name DepthData
## Contains the defined data collection for pin depths.
extends Object

#region base class
## A single defined set of data for a single Depth.
class DepthDef:
	static func _get_texture(n: String) -> Resource:
		var res_str := "res://assets/depths/depth_%s.png" % [n]
		if ResourceLoader.exists(res_str):
			return load(res_str)
		else:
			return load("res://assets/depths/depth_debug.png")
	
	## Human readable name of this depth, in lower case.
	var depth_name:String
	## Depth texture (as seen in a pin)
	var texture:Resource
	## Effect flavor
	var effect:EffectData.EffectFlavors
	
	func _init(name_: String, effect_: EffectData.EffectFlavors):
		self.depth_name = name_
		self.texture = _get_texture(name_)
		self.effect = effect_
#endregion

#region global instances
# the order must match the order of the declaration, below
enum DepthFlavors {
	DEBUG,  ## Debug depth. Should not be used
	HIDDEN,  ## "?" texture. Should not be used.
	EMPTY,  ## Blank depth wtih no effect.
	KEY,  ## Unlock depth, needed to win.
	BREAK,  ## Breaks the pick. Bad.
	BASE,  ## The neutral depth at the top of a pin. Has no effect.
	BOUNCE  ## Bounces the pin back to extended. Vestigial.
}

static var defs := {
	DepthFlavors.DEBUG: DepthDef.new("debug", EffectData.EffectFlavors.DEBUG),
	DepthFlavors.HIDDEN: DepthDef.new("hidden", EffectData.EffectFlavors.DEBUG),
	DepthFlavors.EMPTY: DepthDef.new("empty", EffectData.EffectFlavors.EMPTY),
	DepthFlavors.KEY: DepthDef.new("key", EffectData.EffectFlavors.KEY),
	DepthFlavors.BREAK: DepthDef.new("break", EffectData.EffectFlavors.BREAK),
	DepthFlavors.BASE: DepthDef.new("base", EffectData.EffectFlavors.EMPTY),
	DepthFlavors.BOUNCE: DepthDef.new("bounce", EffectData.EffectFlavors.BOUNCE),
}

## Gets a live DepthDef object given an DepthFlavors enum value.
static func get_def(depth: DepthFlavors) -> DepthDef:
	return defs[depth]
#endregion
