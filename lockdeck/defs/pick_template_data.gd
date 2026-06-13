@tool
class_name PickTemplateData
## Contains the defined data collections for predefined pick cards
extends Object

#region base class
class PickTemplateDef:
	static func _get_texture(name: String) -> Resource:
		var res_str = "res://assets/picks/pick_%s.png" % [name]
		if ResourceLoader.exists(res_str):
			return load(res_str)
		else:
			return load("res://assets/effects/pick_debug.png")
	
	## Human readable pick name, lowercase
	var pick_name: String
	## Pick description or flavortext (vestigial)
	var description: String
	## Pick effect dictionary. Type is dict[int, Array[EffectSpec]]
	var effects: Dictionary[int, Array]
	## Card art texture
	var texture: Resource
	
	func _init(
		p_name: String,
		p_description: String = "",
		p_effects: Dictionary[int, Array] = {}
	):
		self.pick_name = p_name
		self.effects = p_effects
		self.texture = _get_texture(p_name)
		self.description = p_description
#endregion

#region global instances
# the order must match the order of the declaration, below
enum PickTemplateFlavors {
	DEBUG,
	DIAMOND,
	HOOK,
	BALL,
	RAKE,
	SNAKE,
	FORK
}

## valid pick template flavors used for generation
static var ValidPicks := [
	PickTemplateFlavors.DIAMOND,
	PickTemplateFlavors.HOOK,
	PickTemplateFlavors.BALL,
	PickTemplateFlavors.RAKE,
	PickTemplateFlavors.SNAKE,
	PickTemplateFlavors.FORK
]

static var defs := {
	PickTemplateFlavors.DEBUG: PickTemplateDef.new(
		"debug", 
		"DEBUG DEBUG DEBUG DEBUG\n
		DEBUGDEBUGDEBUGDEBUGDEBUGDEBUG\n
		DEBUG\n
		DEBUG",
		{
			-1: [EffectSpec.new("test", 3)],
			0: [EffectSpec.new("force", 6), EffectSpec.new("jump", 3), EffectSpec.new("test", 1)],
			2: [EffectSpec.new("debug", 11)],
			3: [EffectSpec.new("jam", 3), EffectSpec.new("debug", 0)]
		}
	),
	PickTemplateFlavors.DIAMOND: PickTemplateDef.new(
		"diamond",
		"[i]The standard.[/i]",
		{
			-1: [EffectSpec.new("force", 1)],
			0: [EffectSpec.new("force", 3)]
		}
	),
	PickTemplateFlavors.HOOK: PickTemplateDef.new(
		"hook",
		"[i]Feel things out.[/i]",
		{
			0: [EffectSpec.new("jump", 2), EffectSpec.new("force", 1)]
		}
	),
	PickTemplateFlavors.BALL: PickTemplateDef.new(
		"ball",
		"[i]Jammed.[/i]",
		{
			-1: [EffectSpec.new("jam", 1)],
			0: [EffectSpec.new("jam", 2)]
		}
	),
	PickTemplateFlavors.RAKE: PickTemplateDef.new(
		"rake",
		"[i]Shake things up.[/i]",
		{
			-2: [EffectSpec.new("force", 1)],
			-1: [EffectSpec.new("force", 1)],
			0: [EffectSpec.new("force", 1)],
			1: [EffectSpec.new("force", 1)]
		}
	),
	PickTemplateFlavors.SNAKE: PickTemplateDef.new(
		"snake",
		"[i]Fast and loose.[/i]",
		{
			-1: [EffectSpec.new("force", 1), EffectSpec.new("test", 2)],
			0: [EffectSpec.new("force", 1), EffectSpec.new("test", 2)]
		}
	),
	PickTemplateFlavors.FORK: PickTemplateDef.new(
		"fork",
		"[i]They're done.[/i]",
		{
			-1: [EffectSpec.new("force", 2)],
			0: [EffectSpec.new("jam", 1)],
			1: [EffectSpec.new("force", 2)]
		}
	)
}

## Gets a live pick template defition from a PickTemplateFlavors enum
static func get_def(pick_template: PickTemplateFlavors) -> PickTemplateDef:
	return defs[pick_template]
#endregion
