extends Resource
## Stores all the resource flavors as an enum
class_name Loots

enum LootsTypes {
	COIN,
	BAR
}

## Name to display to the user
var readable_name: String

## What to print at the top of the loot panel
var description: String

## The value of this loot, in coins. A pick repair is 10/15/20
var value: int

## The category this loot belongs to
var category: LootsTypes

## The weight of this loot within its category
var category_weight: int

## Display texture. This will be centered at 0, 0
var texture: Resource

## The collision scene, either a CollisionPolygon or CollisionShape
var collider: PackedScene

var mass: int

## Material - leave null to use metal
var material

func _load_assets(asset_name) -> void:
	var texture_str := "res://assets/loot/%s.png" % asset_name
	if ResourceLoader.exists(texture_str):
		texture = load(texture_str)
	else:
		texture = load("res://assets/loot/debug_coin.png")
	
	var collider_str := "res://assets/loot/colliders/shape_%s.tscn" % asset_name
	if ResourceLoader.exists(collider_str):
		collider = load(collider_str)
	else:
		collider = load("res://assets/loot/colliders/shape_debug_coin.tscn")

func _init(
	asset_name: String,
	readable_name_: String,
	description_: String,
	value_: int,
	category_weight_: int,
	mass_: int = 10
):
	_load_assets(asset_name)
	readable_name = readable_name_
	description = description_
	value = value_
	category_weight = category_weight_
	mass = mass_


#region coins

const COIN_DESCRIPTION := "$$ Cash money $$! +%s gold."

static var COIN_1 := Loots.new(
	"coin_1",
	"small copper coin",
	COIN_DESCRIPTION % 1,
	1,
	6,
	4,
)

static var COIN_2 := Loots.new(
	"coin_6",
	"large copper coin",
	COIN_DESCRIPTION % 2,
	2,
	2,
	10,
)

static var COIN_3 := Loots.new(
	"coin_5",
	"small silver coin",
	COIN_DESCRIPTION % 3,
	3,
	3,
	6,
)

static var COIN_4 := Loots.new(
	"coin_2",
	"large silver coin",
	COIN_DESCRIPTION % 4,
	4,
	1,
	8,
)

static var COIN_5 := Loots.new(
	"coin_4",
	"small gold coin",
	COIN_DESCRIPTION % 5,
	5,
	2,
	3,
)

static var COIN_6 := Loots.new(
	"coin_3",
	"large gold coin",
	COIN_DESCRIPTION % 10,
	10,
	1,
	20,
)

static var ALL_COINS: Array[Loots] = [
	COIN_1,
	COIN_2,
	COIN_3,
	COIN_4,
	COIN_5,
	COIN_6
]

#endregion

#region bars
static var BAR_1 := Loots.new(
	"bar_1",
	"orichalum ingot",
	"Add a random lockpick to your deck.",
	10,
	10,
	20,
)

static var BAR_2 := Loots.new(
	"bar_2",
	"dwarven metal ingot",
	"Choose one of two lockpicks to add to your deck.",
	15,
	9,
	20,
)

static var BAR_3 := Loots.new(
	"bar_3",
	"moonstone ingot",
	"Choose one of three lockpicks to add to your deck.",
	20,
	8,
	10,
)

static var BAR_4 := Loots.new(
	"bar_4",
	"malachite ingot",
	"Choose one of four lockpicks to add to your deck.",
	25,
	7,
	20,
)

static var BAR_5 := Loots.new(
	"bar_5",
	"ebony ingot",
	"Choose one of five lockpicks to add to your deck",
	30,
	6,
	30,
)

static var ALL_BARS: Array[Loots] = [
	BAR_1,
	BAR_2,
	BAR_3,
	BAR_4,
	BAR_5
]

## All of the loot, in a LootsTypes[Array[Loots)) dictionary.
static var TYPE_DICT: Dictionary[LootsTypes, Array] = {
	LootsTypes.COIN: ALL_COINS,
	LootsTypes.BAR: ALL_BARS
}

static func _static_init() -> void:
	for t in LootsTypes.values():
		for l in TYPE_DICT[t] as Array[Loots]:
			l.category = t
