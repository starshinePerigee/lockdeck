extends TextureButton
## A fully drawn pick card view object
class_name PickCard

@export var card_spec: CardSpec:
	set(v):
		card_spec = v
		_redraw()

## Sets the background art
func set_art(texture: Texture2D) -> void:
	texture_normal = texture

## Updates the column size to make cards fit
func _squash_columns() -> void:
	var available_size: int
	if $TextBox.visible:
		available_size = 78
	else:
		available_size = 120
	
	var icon_count := $EffectBar.get_child(3).get_child_count()
	@warning_ignore("integer_division")
	var separation := (available_size / icon_count) - 24
	if separation < EffectStack.ICON_SEPARATION:
		print("Squashing! new sep: %s" % separation)
		for stack in $EffectBar.get_children():
			stack.add_theme_constant_override("separation", separation)

func _redraw() -> void:
	if not is_node_ready() or card_spec == null:
		return
	
	$EffectBar.effect_stacks = card_spec.effects
	$EffectBar.redraw()
	$PickArt.texture = card_spec.texture
	$TitleBox/Title.text = card_spec.pick_name.capitalize()
	$TextBox/Text.text = card_spec.ability.description
	$TextBox.visible = card_spec.ability != Abilities.NONE
	$Tallies.frame = min(card_spec.repair_count, 11)
	_squash_columns()

func _ready() -> void:
	_redraw()

const SELF_PACKED := preload("res://objects/card/pick_card.tscn")

static func build_from_template(flavor: PickTemplates) -> PickCard:
	var n := SELF_PACKED.instantiate() as PickCard
	n.card_spec = CardSpec.from_template(flavor)
	return n

static func build_from_spec(spec: CardSpec = null) -> PickCard:
	var n := SELF_PACKED.instantiate() as PickCard
	if spec == null:
		n.card_spec = CardSpec.from_template(PickTemplates.DEBUG)
	else:
		n.card_spec = spec
	return n
