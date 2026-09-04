extends Button
## A fully drawn pick card view object
class_name PickCard

const FRAME_NORMAL: Texture2D = preload("res://assets/card/frame_normal.png")
const FRAME_HOVERED: Texture2D = preload("res://assets/card/frame_hover.png")
const FRAME_PRESSED: Texture2D = preload("res://assets/card/frame_pressed.png")
const FRAME_DISABLED: Texture2D = preload("res://assets/card/frame_disabled.png")

var _mouse_over: bool = false

func _do_hover() -> void:
	_mouse_over = true
	if force_normal:
		return
	if not disabled:
		$Art.position = Vector2(0, -4)
		$Art/Frame.texture = FRAME_HOVERED
	else:
		$Art/Frame.texture = FRAME_DISABLED

func _end_hover() -> void:
	if force_normal:
		return
	_mouse_over = false
	$Art.position = Vector2(0, 0)
	$Art/Frame.texture = FRAME_NORMAL

func _do_press() -> void:
	if force_normal or disabled:
		return
	$Art.position = Vector2(0, -2)
	$Art/Frame.texture = FRAME_PRESSED

func _end_press() -> void:
	if _mouse_over:
		_do_hover()
	else:
		_end_hover()

var force_normal := false:
	set(v):
		force_normal = v
		if force_normal:
			$Art.position = Vector2(0, 0)
			$Art/Frame.texture = FRAME_NORMAL

@export var hide_pick := false:
	set(v):
		hide_pick = v
		$Art/PickArt.visible = not hide_pick

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

## Updates the column size to make cards fit
func _squash_columns() -> void:
	var available_size: int
	if $Art/TextBox.visible:
		available_size = 78
	else:
		available_size = 120
	
	var icon_count := $Art/EffectBar.get_child(3).get_child_count()
	var separation: int
	if icon_count > 0:
		@warning_ignore("integer_division")
		separation = (available_size / icon_count) - 24
	else:
		separation = available_size
	if separation < EffectStack.ICON_SEPARATION:
		for stack in $Art/EffectBar.get_children():
			stack.add_theme_constant_override("separation", separation)

static var material_dictionary: Dictionary[PickTemplates.Rarities, ShaderMaterial] = {}

## Redraws when a new card is loaded
func _redraw() -> void:
	if not is_node_ready():
		return
	if card_spec == null or card_spec.template == null or card_spec.template.texture == null:
		card_spec = CardSpec.DEBUG
	
	$Art/EffectBar.effect_stacks = card_spec.effects
	$Art/EffectBar.redraw()
	$Art/PickArt.texture = card_spec.template.texture
	$Art/PickArt.material = material_dictionary[card_spec.template.rarity]
	$Art/PickArt.visible = not hide_pick
	$Art/PickShadow.texture = card_spec.template.bg_texture
	$Art/TitleBox/Title.text = card_spec.pick_name.capitalize()
	$Art/TextBox/Text.text = card_spec.ability.description
	$Art/TextBox.visible = card_spec.ability != Abilities.NONE
	$Art/Tallies.frame = min(card_spec.repair_count, 11)
	_squash_columns()

const TOOLTIP := preload("res://objects/displays/card_tooltip.tscn")

func request_tooltip() -> void:
	if not tooltippable or not card_spec:
		return
	var tooltip: Control = TOOLTIP.instantiate()
	tooltip.add_effects(card_spec.get_unique_list())
	TooltipManager.request_widget_tooltip(get_global_rect, tooltip)
	

func _ready() -> void:
	if not material_dictionary:
		for rarity in PickTemplates.Rarities.values():
			var color: Color = PickTemplates.RARITY_COLORS[rarity]
			var new_material: ShaderMaterial = $Art/PickArt.material.duplicate()
			new_material.set_shader_parameter("new", color)
			material_dictionary[rarity] = new_material
	
	_redraw()
	mouse_entered.connect(request_tooltip)
	mouse_entered.connect(_do_hover)
	mouse_exited.connect(_end_hover)
	button_down.connect(_do_press)
	button_up.connect(_end_press)


const SELF_PACKED := preload("res://objects/card/pick_card.tscn")

static func build_from_template(flavor: PickTemplates) -> PickCard:
	var n := SELF_PACKED.instantiate() as PickCard
	n.card_spec = CardSpec.from_template(flavor)
	return n

static func build_from_spec(spec: CardSpec = null) -> PickCard:
	var n := SELF_PACKED.instantiate() as PickCard
	if spec == null:
		n.card_spec = CardSpec.DEBUG
	else:
		n.card_spec = spec
	return n
