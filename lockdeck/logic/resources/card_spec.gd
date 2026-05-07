extends Resource
class_name CardSpec

@export var effects: Dictionary[int, Array]
# dictionary of int position to Array[EffectSpec]
@export var pick_name: String
@export var description: String
@export var texture: Resource

func _init(template_flavor: PickTemplateData.PickTemplateFlavors):
	var template = PickTemplateData.get_def(template_flavor)
	pick_name = template.name
	texture = template.texture
	effects = {0: []}
