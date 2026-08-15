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

static var BAR_VALUE: Dictionary[Loots, int] = {
	Loots.BAR_1: 1,
	Loots.BAR_2: 2,
	Loots.BAR_3: 3,
	Loots.BAR_4: 4,
	Loots.BAR_5: 5,
}

const BAR_PER_BAR := 1.7

const SELF_SCENE := preload("res://objects/loot/ingot_widget.tscn")
const SELL_THING := preload("res://objects/loot/sell_thing.tscn")

static func unpack(bar: Loots) -> IngotWidget:
	var widget := SELF_SCENE.instantiate()
	widget.set_loots(bar)
	return widget

func _ready() -> void:
	if _loots == null:
		push_warning("You must assign a Loots via set_loots()!")
		_loots = Loots.BAR_3
	
	var template_value := int(BAR_VALUE[_loots] ** BAR_PER_BAR)
	for spec in PickGenerator.get_n_cards_with_template_value(
		BAR_VALUE[_loots],
		template_value
	):
		var card := CardButton.build_from_spec(spec)
		card.pressed.connect(add_pick.emit.bind(spec))
		card.pressed.connect(close_popup.emit)
		add_child(card)
	
	var sell_thing := SELL_THING.instantiate()
	sell_thing.sell_clicked.connect(add_coins.emit.bind(5))
	sell_thing.sell_clicked.connect(close_popup.emit)
	add_child(sell_thing)

	if get_tree().current_scene == self:
		var count_dir := {0: 0, 1: 0, 2: 0, 3:0, 4: 0}
		var has_dir := {0: 0, 1: 0, 2: 0, 3:0, 4: 0}
		var sum := 0
		var iterations := 1000
		for i in iterations:
			var rs := PickGenerator.get_rarity_set_with_template_value(
				BAR_VALUE[_loots],
				template_value
			)
			for r in rs:
				sum += r
				count_dir[r] += 1
			for k in has_dir.keys():
				if k in rs:
					has_dir[k] += 1
		
		print("************")
		print("Percent of sets that have: ")
		for k in has_dir.keys():
			print("%s: %.0f%%" % [k, 100.0 * has_dir[k] / iterations])
		print("Average count of: ")
		for k in count_dir.keys():
			print("%s: %0.2f" % [k, 1.0 * count_dir[k] / iterations])
		print("Average value: %s" % (1.0 * sum / iterations))
