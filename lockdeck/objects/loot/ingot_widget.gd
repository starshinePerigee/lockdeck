extends HBoxContainer
## This handles giving the choice of a pick
class_name IngotWidget

static var BAR_VALUES: Dictionary[Loots, int] = {
	Loots.BAR_1: 1,
	Loots.BAR_2: 2,
	Loots.BAR_3: 3,
	Loots.BAR_4: 4,
	Loots.BAR_5: 5,
}

signal close_popup
signal add_pick(CardSpec)
signal add_coins(int)

const SELF_SCENE := preload("res://objects/loot/ingot_widget.tscn")

const SELL_THING := preload("res://objects/loot/sell_thing.tscn")

static func unpack(bar: Loots) -> IngotWidget:
	var widget := SELF_SCENE.instantiate()
	for __ in BAR_VALUES[bar]:
		var spec := PickGenerator.get_random_base_card()
		var card := PickCard.build_from_spec(spec)
		card.pressed.connect(widget.add_pick.emit.bind(spec))
		card.pressed.connect(widget.close_popup.emit)
		widget.add_child(card)
	var sell_thing := SELL_THING.instantiate()
	sell_thing.sell_clicked.connect(widget.add_coins.emit.bind(5))
	sell_thing.sell_clicked.connect(widget.close_popup.emit)
	widget.add_child(sell_thing)
	return widget