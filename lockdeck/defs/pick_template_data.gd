@tool
class_name PickTemplateData
extends Object

#region base class
class PickTemplateDef:
	static func _get_texture(name: String) -> Resource:
		var res_str = "res://assets/picks/pick_%s.png" % [name]
		if FileAccess.file_exists(res_str):
			return load(res_str)
		else:
			return load("res://assets/effects/pick_debug.png")
	
	var pick_name: String
	var description: String
	var effects: Dictionary[int, Array]
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
enum PickTemplateFlavors {DEBUG, DIAMOND, HOOK, BALL, RAKE, SNAKE}

static var ValidPicks = [
	PickTemplateFlavors.DIAMOND,
	PickTemplateFlavors.HOOK,
	PickTemplateFlavors.BALL,
	PickTemplateFlavors.RAKE,
	PickTemplateFlavors.SNAKE
]

static var _defs: Array[PickTemplateDef] = []

static func _get_def() -> Array[PickTemplateDef]:
	if _defs.is_empty():
		_defs = [
			PickTemplateDef.new(
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
			PickTemplateDef.new(
				"diamond",
				"[i]The standard.[/i]",
				{
					-1: [EffectSpec.new("force", 1)],
					0: [EffectSpec.new("force", 3)],
					1: [EffectSpec.new("force", 1)]
				}
			),
			PickTemplateDef.new(
				"hook",
				"[i]Feel things out.[/i]",
				{
					0: [EffectSpec.new("jump", 2), EffectSpec.new("force", 1)]
				}
			),
			PickTemplateDef.new(
				"ball",
				"[i]Jammed.[/i]",
				{
					-1: [EffectSpec.new("jam", 1)],
					0: [EffectSpec.new("jam", 2)]
				}
			),
			PickTemplateDef.new(
				"rake",
				"[i]Shake things up.[/i]",
				{
					-2: [EffectSpec.new("force", 1)],
					-1: [EffectSpec.new("force", 1)],
					0: [EffectSpec.new("force", 1)],
					1: [EffectSpec.new("force", 1)]
				}
			),
			PickTemplateDef.new(
				"snake",
				"[i]Fast and loose.[/i]",
				{
					-1: [EffectSpec.new("force", 1), EffectSpec.new("test", 2)],
					0: [EffectSpec.new("force", 1), EffectSpec.new("test", 2)]
				}
			)
		]
		assert(len(_defs) == len(PickTemplateFlavors), "Hey dipshit update the enum")
		print("Loaded %s pick templates" % len(_defs))
	return _defs

static func get_def(pick_template: PickTemplateFlavors) -> PickTemplateDef:
	return _get_def()[pick_template]
#endregion
