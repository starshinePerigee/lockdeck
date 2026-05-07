@tool
extends TextureButton

func load_template(flavor: PickTemplateData.PickTemplateFlavors):
	var template = PickTemplateData.get_def(flavor)
	$EffectBar.effect_stacks = template.effects
	$PickArt.texture = template.texture
	$TitleBox/Title.text = template.pick_name.capitalize()
	$TextBox/Text.text = template.description

func _ready() -> void:
	load_template(PickTemplateData.PickTemplateFlavors.DEBUG)	
