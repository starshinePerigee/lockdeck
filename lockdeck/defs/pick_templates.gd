extends RefCounted
## Contains the defined data collections for predefined pick cards
class_name PickTemplates

static func _get_texture(n: String) -> Resource:
	var res_str := "res://assets/picks/pick_%s.png" % [n]
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
	pick_name_: String,
	description_: String = "",
	effects_: Dictionary[int, Array] = {}
):
	pick_name = pick_name_
	description = description_
	effects = effects_
	texture = _get_texture(pick_name_)


static var DEBUG := PickTemplates.new(
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
)

static var DIAMOND := PickTemplates.new(
	"diamond",
	"",
	{
		-1: [EffectSpec.new("force", 1)],
		0: [EffectSpec.new("force", 3)]
	}
)

static var HOOK := PickTemplates.new(
	"hook",
	"",
	{
		0: [EffectSpec.new("jump", 2), EffectSpec.new("force", 1)]
	}
)

static var BALL := PickTemplates.new(
	"ball",
	"",
	{
		-1: [EffectSpec.new("jam", 1)],
		0: [EffectSpec.new("jam", 2)]
	}
)

static var RAKE := PickTemplates.new(
	"rake",
	"",
	{
		-2: [EffectSpec.new("force", 1)],
		-1: [EffectSpec.new("force", 1)],
		0: [EffectSpec.new("force", 1)],
		1: [EffectSpec.new("force", 1)]
	}
)

static var SNAKE := PickTemplates.new(
	"snake",
	"",
	{
		-1: [EffectSpec.new("force", 1), EffectSpec.new("test", 2)],
		0: [EffectSpec.new("force", 1), EffectSpec.new("test", 2)]
	}
)

static var FORK := PickTemplates.new(
	"fork",
	"",
	{
		-1: [EffectSpec.new("force", 2)],
		0: [EffectSpec.new("jam", 1)],
		1: [EffectSpec.new("force", 2)]
	}
)