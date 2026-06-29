extends TextureButton
## A fully drawn pick card view object
class_name PickCard

@export var card_spec: CardSpec:
	set(v):
		card_spec = v
		
		if not is_node_ready():
			await ready
		
		$EffectBar.effect_stacks = card_spec.effects
		$EffectBar.redraw()
		$PickArt.texture = card_spec.texture
		$TitleBox/Title.text = card_spec.pick_name.capitalize()
#		$TextBox/Text.text = card_spec.description

const SELF_PACKED := preload("res://objects/card/pick_card.tscn")

func build_from_template(flavor: PickTemplates):
	var n := SELF_PACKED.instantiate()
	n.card_spec = CardSpec.from_template(flavor)

func _ready() -> void:
	if card_spec == null:
		card_spec = CardSpec.from_template(PickTemplates.DEBUG)
