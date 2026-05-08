@tool
extends TextureButton

@export var card_spec: CardSpec:
	set(v):
		card_spec = v
		
		if not is_node_ready():
			await ready
		
		$EffectBar.effect_stacks = card_spec.effects
		$PickArt.texture = card_spec.texture
		$TitleBox/Title.text = card_spec.pick_name.capitalize()
		$TextBox/Text.text = card_spec.description

func load_template(flavor: PickTemplateData.PickTemplateFlavors):
	var new_spec = CardSpec.new(flavor)
	card_spec = new_spec

func _ready() -> void:
	if not is_node_ready():
		await ready
	
	if card_spec == null:
		card_spec = CardSpec.new(PickTemplateData.PickTemplateFlavors.DEBUG)
