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
## Text description
@export var description: String
## The original template used to create this pick
@export var template: PickTemplates
## How many times this pick has been repaired
@export var repair_count := 0
## Base shop value for this pick
@export var shop_value := 0
## Pick ability
@export var ability := Abilities.NONE

## Unique ID used for tracking specific cards
@export var unique_id: int

static var last_id := 100

func get_buy_cost() -> int:
	return shop_value

func get_repair_cost() -> int:
	return 20 + repair_count * 10

static func from_template(source: PickTemplates = PickTemplates.DEBUG) -> CardSpec:
	return CardSpec.new(
		source,
		source.pick_name,
		"",
		source.effects,
		source.rarity
	)

func get_unique_list() -> Array[Effects]:
	var list: Array[Effects] = []
	for key in effects.keys():
		for effect in effects[key]:
			if effect.flavor not in list:
				list.append(effect.flavor as Effects)
	return list

func reify() -> void:
	ability = Abilities.static_registry[ability.description]
	template = PickTemplates.static_registry[template.pick_name]
	for key in effects.keys():
		for spec in effects[key]:
			spec.reify()
	if unique_id > last_id:
		push_warning(
			"High unique ID when reifying card spec: unique %s vs last %s"
			% [unique_id, last_id]
		)

func color() -> Color:
	if template.rarity in PickTemplates.RARITY_COLORS:
		return PickTemplates.RARITY_COLORS[template.rarity]
	return Color()

func _init(
	template_: PickTemplates = null,
	pick_name_: String = "NULL",
	description_: String = "",
	effects_: Dictionary[int, Array] = {},
	rarity: int = -2
):
	unique_id = last_id
	last_id += 1
	
	template = template_
	pick_name = pick_name_
	description = description_
	effects.assign(effects_)
	shop_value = 15 + 5 * rarity

static var DEBUG: CardSpec

static func _static_init() -> void:
	DEBUG = CardSpec.from_template(PickTemplates.DEBUG)