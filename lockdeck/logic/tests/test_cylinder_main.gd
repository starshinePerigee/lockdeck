extends Node2D

static var CYL_COUNT := 4


func get_pick(selected: String) -> CardSpec:
	for t in PickTemplates.valid_templates:
		if t.pick_name == selected:
			return CardSpec.from_template(t)
	push_error("Could not find pick from selector!")
	return CardSpec.from_template(PickTemplates.DEBUG)

func apply_card(dropdown_index: int, card_index: int) -> void:
	var selected: String = $CardHBox.get_child(card_index).get_item_text(dropdown_index)
	var card := get_pick(selected)
	print("Applying pick %s on cylinder %s" % [card.pick_name, card_index])
	$CylinderMain.execute(card, card_index)


func _ready() -> void:
	var pin_specs: Array[PinSpec] = []
	for i in range(CYL_COUNT):
		pin_specs.append(PinSpec.new())
	$CylinderMain.load_new_pins(pin_specs)

	for i in range(PinSpec.CYLINDER_COUNT_MAX):
		var selector: OptionButton = $CardHBox.get_child(i)
		for t in PickTemplates.valid_templates:
			selector.add_item(t.pick_name)
			selector.item_selected.connect(apply_card.bind(i))

	for i in range(CYL_COUNT, PinSpec.CYLINDER_COUNT_MAX):
		$CardHBox.get_child(i).disabled = true
		
	$ResetButton.pressed.connect($CylinderMain.reset_all_pins)
