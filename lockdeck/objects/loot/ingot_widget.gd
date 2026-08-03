extends HBoxContainer
## This handles giving the choice of a pick
class_name IngotWidget

signal close_popup
signal add_pick(CardSpec)
signal add_coins(int)

var _loots: Loots

# write-only variable
func set_loots(loots: Loots) -> void:
	_loots = loots

static var BAR_VALUES: Dictionary[Loots, int] = {
	Loots.BAR_1: 1,
	Loots.BAR_2: 2,
	Loots.BAR_3: 3,
	Loots.BAR_4: 4,
	Loots.BAR_5: 5,
}

const SELF_SCENE := preload("res://objects/loot/ingot_widget.tscn")
const SELL_THING := preload("res://objects/loot/sell_thing.tscn")

static func unpack(bar: Loots) -> IngotWidget:
	var widget := SELF_SCENE.instantiate()
	widget.set_loots(bar)
	return widget

func _ready() -> void:
	if _loots == null:
		push_error("You must assign a Loots via set_loots()!")
	
	for __ in BAR_VALUES[_loots]:
		var spec := PickGenerator.get_random_base_card()
		var card := CardButton.build_from_spec(spec)
		card.pressed.connect(add_pick.emit.bind(spec))
		card.pressed.connect(close_popup.emit)
		add_child(card)
	
	var sell_thing := SELL_THING.instantiate()
	sell_thing.sell_clicked.connect(add_coins.emit.bind(5))
	sell_thing.sell_clicked.connect(close_popup.emit)
	add_child(sell_thing)
