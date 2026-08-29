extends TextureButton
## A fully drawn pick card view object
class_name PickCard

## If this is allowed to show a tooltip
@export var tooltippable := true:
	set(v):
		tooltippable = v
		if not tooltippable:
			TooltipManager.request_tooltip_close()

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
	var separation: int
	if icon_count > 0:
		@warning_ignore("integer_division")
		separation = (available_size / icon_count) - 24
	else:
		separation = available_size
	if separation < EffectStack.ICON_SEPARATION:
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

const TOOLTIP := preload("res://objects/displays/card_tooltip.tscn")

func request_tooltip() -> void:
	if not tooltippable:
		return
	var tooltip: Control = TOOLTIP.instantiate()
	tooltip.add_effects(card_spec.get_unique_list())
	TooltipManager.request_widget_tooltip(get_global_rect(), tooltip)
	

func _ready() -> void:
	_redraw()
	mouse_entered.connect(request_tooltip)

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
