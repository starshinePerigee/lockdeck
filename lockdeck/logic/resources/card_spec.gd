extends Resource
## CardSpec is the dataclass that describes a single pick card.
## It includes a dictionary of EffectSpecs, as well as textures and copy.
class_name CardSpec

## The card effects. This is a Dictionary[int, Array[EffectSpec]]
## where int is the column offset for the array of effects (ie: the target cylinder
## is index 0.) EffectSpecs are listed in activation order, from first (top) to last (bottom)
@export var effects: Dictionary[int, Array]
## Human readable name in lowercase
@export var pick_name: String
## Text description - currently flavor. Should be vestigial but I am a sucker
@export var description: String
# you haven't earned flavortext yet
## The pick art resource for this card.
@export var texture: Resource

## Unique ID used for tracking specific cards
var unique_id: int

static var last_id := 100

static func from_template(template: PickTemplates = PickTemplates.DEBUG) -> CardSpec:
	return CardSpec.new(
		template.pick_name,
		template.description,
		template.texture,
		template.effects
	)

func unrealize_effects() -> void:
	for effect_array in effects.values():
		for effect in effect_array:
			effect.realized_pin = -1
			effect.realized_positions.clear()

func _init(
	pick_name_: String,
	description_: String,
	texture_: Resource,
	effects_: Dictionary[int, Array]
):
	unique_id = last_id
	last_id += 1
	
	pick_name = pick_name_
	description = description_
	texture = texture_
	effects.assign(effects_)
