extends Resource
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
## Pick effect dictionary. Type is dict[int, Array[EffectSpec]]
var effects: Dictionary[int, Array]
## Card art texture
var texture: Resource
## Pick description or flavortext (vestigial)
var description: String = ""
	
func _init(
	pick_name_: String,
	effects_: Dictionary[int, Array] = {},
	description_: String = "",
):
	pick_name = pick_name_
	description = description_
	effects = effects_
	texture = _get_texture(pick_name_)


static var DEBUG := PickTemplates.new(
	"debug", 
	{
		-1: [EffectSpec.new(Effects.TEST, 3)],
		0: [
			EffectSpec.new(Effects.FORCE, 6), 
			EffectSpec.new(Effects.JUMP, 3),
			EffectSpec.new(Effects.TEST, 1)
		],
		2: [EffectSpec.new(Effects.DEBUG, 11)],
		3: [
			EffectSpec.new(Effects.JAM, 3),
			EffectSpec.new(Effects.DEBUG, 0)
		]
	},
	"DEBUG DEBUG DEBUG DEBUG\n
	DEBUGDEBUGDEBUGDEBUGDEBUGDEBUG\n
	DEBUG\n
	DEBUG",
)

static var DIAMOND := PickTemplates.new(
	"diamond",
	{
		-1: [EffectSpec.new(Effects.FORCE, 1)],
		0: [EffectSpec.new(Effects.FORCE, 3)]
	}
)

static var HOOK := PickTemplates.new(
	"hook",
	{
		0: [
			EffectSpec.new(Effects.JUMP, 2),
			EffectSpec.new(Effects.FORCE, 1)
		]
	}
)

static var BALL := PickTemplates.new(
	"ball",
	{
		-1: [EffectSpec.new(Effects.JAM, 1)],
		0: [EffectSpec.new(Effects.JAM, 2)]
	}
)

static var RAKE := PickTemplates.new(
	"rake",
	{
		-2: [EffectSpec.new(Effects.FORCE, 1)],
		-1: [EffectSpec.new(Effects.FORCE, 1)],
		0: [EffectSpec.new(Effects.FORCE, 1)],
		1: [EffectSpec.new(Effects.FORCE, 1)]
	}
)

static var SNAKE := PickTemplates.new(
	"snake",
	{
		-1: [
			EffectSpec.new(Effects.FORCE, 1), 
			EffectSpec.new(Effects.TEST, 2)
		],
		0: [
			EffectSpec.new(Effects.FORCE, 1), 
			EffectSpec.new(Effects.TEST, 2)
		]
	}
)

static var FORK := PickTemplates.new(
	"fork",
	{
		-1: [EffectSpec.new(Effects.FORCE, 2)],
		0: [EffectSpec.new(Effects.JAM, 1)],
		1: [EffectSpec.new(Effects.FORCE, 2)]
	}
)