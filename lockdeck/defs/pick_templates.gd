extends Resource
## Contains the defined data collections for predefined pick cards
class_name PickTemplates

static func _get_texture(n: String) -> Resource:
	var res_str := "res://assets/picks/pick_%s.png" % [n]
	if ResourceLoader.exists(res_str):
		return load(res_str)
	else:
		return load("res://assets/picks/pick_debug_card.png")
	
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
		0: [EffectSpec.new(Effects.REVEAL, 3)],
		1: [
			EffectSpec.new(Effects.PUSH, 4), 
			EffectSpec.new(Effects.TEST, 3),
			EffectSpec.new(Effects.REVEAL, 1)
		],
		3: [EffectSpec.new(Effects.DEBUG, 8)],
		4: [
			EffectSpec.new(Effects.JAM, 3),
			EffectSpec.new(Effects.DEBUG, 0)
		]
	},
	"If you see this, please tell starshine.",
)

static var DIAMOND := PickTemplates.new(
	"diamond",
	{
		2: [EffectSpec.new(Effects.TEST, 1)],
		1: [
			EffectSpec.new(Effects.PUSH, 1),
			EffectSpec.new(Effects.TEST, 1),
		],
		0: [
			EffectSpec.new(Effects.PUSH, 3),
			EffectSpec.new(Effects.TEST, 1),
		]
	}
)

static var PROBE := PickTemplates.new(
	"probe",
	{
		3: [EffectSpec.new(Effects.TEST, 1)],
		2: [EffectSpec.new(Effects.TEST, 2)],
		1: [EffectSpec.new(Effects.TEST, 2)],
		0: [
			EffectSpec.new(Effects.PUSH, 1),
			EffectSpec.new(Effects.TEST, 2)
		]
	}
)

static var HOOK := PickTemplates.new(
	"hook",
	{
		0: [
			EffectSpec.new(Effects.PUSH, 2),
			EffectSpec.new(Effects.TEST, 2)
		]
	}
)

static var BALL := PickTemplates.new(
	"ball",
	{
		1: [EffectSpec.new(Effects.JAM, 1)],
		0: [EffectSpec.new(Effects.JAM, 2)]
	}
)

static var RAKE := PickTemplates.new(
	"rake",
	{
		3: [
			EffectSpec.new(Effects.PUSH, 1),
			EffectSpec.new(Effects.TEST, 1)
		],
		2: [
			EffectSpec.new(Effects.PUSH, 1),
			EffectSpec.new(Effects.TEST, 1)
		],
		1: [
			EffectSpec.new(Effects.PUSH, 1),
			EffectSpec.new(Effects.TEST, 1)
		],
		0: [
			EffectSpec.new(Effects.PUSH, 1),
			EffectSpec.new(Effects.TEST, 1)
		]
	}
)

static var SNAKE := PickTemplates.new(
	"snake",
	{
		1: [
			EffectSpec.new(Effects.PUSH, 1), 
			EffectSpec.new(Effects.REVEAL, 2)
		],
		0: [
			EffectSpec.new(Effects.PUSH, 1), 
			EffectSpec.new(Effects.REVEAL, 2)
		]
	}
)

static var FORK := PickTemplates.new(
	"fork",
	{
		2: [
			EffectSpec.new(Effects.TEST, 2),
			EffectSpec.new(Effects.JAM, 2),
		],
		1: [EffectSpec.new(Effects.PUSH, 1)],
		0: [
			EffectSpec.new(Effects.TEST, 2),
			EffectSpec.new(Effects.JAM, 2),
		]
	}
)

static var LEVER := PickTemplates.new(
	"lever",
	{
		0: [
			EffectSpec.new(Effects.CRUSH, 1), 
			EffectSpec.new(Effects.PUSH, 3)
		]
	}
)


static var valid_templates: Array[PickTemplates] = [
	DIAMOND,
	HOOK,
	PROBE,
	BALL,
	RAKE,
	SNAKE,
	FORK,
	LEVER
]