class_name EffectData
## Contains the defined data collection effects - both pick card and depth effects
extends Object

#region base class
## A single defined set of data for a single Effect.
class EffectDef:
	static func _get_texture(name: String, small: bool) -> Resource:
		var suffix := "_small" if small else ""
		var res_str := "res://assets/effects/icon_%s%s.png" % [name, suffix]
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
	DEBUG,  ## Debug effect. should not be used.
	EMPTY,  ## do nothing. Depth / pick effect
	FORCE,  ## move the pin
	JAM,  ## apply jam
	TEST,  ## reveal the next depth but do not advance the pin
	JUMP,  ## Skip the next depth
	KEY,  ## Depth effect - unlock the current pin
	BREAK,  ## Depth effect - break the current pin 
	BOUNCE,  ## Depth effect - bounce the pin back to the top
	OUT_OF_BOUNDS,  ## Depth effect - pick out of bounds (typically breaks)
	END_EXECUTION,  ## stop evaluating current card. Used as a sentinel value in execution.
}

static var defs := {
	EffectFlavors.DEBUG: EffectDef.new("debug"),
	EffectFlavors.EMPTY: EffectDef.new("empty"),
	EffectFlavors.FORCE: EffectDef.new("force"),
	EffectFlavors.JAM: EffectDef.new("jam"),
	EffectFlavors.TEST: EffectDef.new("test"),
	EffectFlavors.JUMP: EffectDef.new("jump"),
	EffectFlavors.KEY: EffectDef.new("key"),
	EffectFlavors.BREAK: EffectDef.new("break"),
	EffectFlavors.BOUNCE: EffectDef.new("bounce"),
	EffectFlavors.OUT_OF_BOUNDS: EffectDef.new("out_of_bounds"),
}

## Gets a live EffectDef object given an EffectFlavors enum value.
static func get_def(effect: EffectFlavors) -> EffectDef:
	return defs[effect]
#endregion
