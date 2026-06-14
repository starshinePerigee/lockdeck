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

func _init(
	template: PickTemplates = PickTemplates.DEBUG,
):
	pick_name = template.pick_name
	description = template.description
	texture = template.texture
	effects = template.effects
