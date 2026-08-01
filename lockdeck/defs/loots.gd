extends Resource
## Stores all the resource flavors as an enum
class_name Loots

## Name to display to the user
var readable_name: String

## The value of this loot, in coins. A pick repair is 10/15/20
var value: int

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
	value_: int,
	category_weight_: int,
	mass_: int = 10
):
	_load_assets(asset_name)
	readable_name = readable_name_
	value = value_
	category_weight = category_weight_
	mass = mass_


#region coins

static var COIN_1 := Loots.new(
	"coin_1",
	"small copper coin",
	1,
	6,
	4,
)

static var COIN_2 := Loots.new(
	"coin_6",
	"large copper coin",
	2,
	2,
	10,
)

static var COIN_3 := Loots.new(
	"coin_5",
	"small silver coin",
	3,
	3,
	6,
)

static var COIN_4 := Loots.new(
	"coin_2",
	"large silver coin",
	4,
	1,
	8,
)

static var COIN_5 := Loots.new(
	"coin_4",
	"small gold coin",
	5,
	2,
	3,
)

static var COIN_6 := Loots.new(
	"coin_3",
	"large gold coin",
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
	20,
	10,
	20,
)

static var BAR_2 := Loots.new(
	"bar_2",
	"dwarven metal ingot",
	25,
	9,
	20,
)

static var BAR_3 := Loots.new(
	"bar_3",
	"moonstone ingot",
	30,
	8,
	10,
)

static var BAR_4 := Loots.new(
	"bar_4",
	"malachite ingot",
	35,
	7,
	20,
)

static var BAR_5 := Loots.new(
	"bar_5",
	"ebony ingot",
	40,
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