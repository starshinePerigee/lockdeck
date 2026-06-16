extends Node2D

static var CYL_COUNT := 4


func get_pick(selected: String) -> CardSpec:
	for t in PickTemplates.valid_templates:
		if t.pick_name == selected:
			return CardSpec.from_template(t)
	push_error("Could not find pick from selector!")
	return CardSpec.from_template(PickTemplates.DEBUG)

func apply_card(dropdown_index: int, card_index: int) -> void:
	$BreakLabel.visible = false
	var selected: String = $CardHBox.get_child(card_index).get_item_text(dropdown_index)
	var card := get_pick(selected)
	print("Applying pick %s on cylinder %s" % [card.pick_name, card_index])
	$CylinderMain.execute(card, card_index)

func break_pick() -> void:
	print("Pick break!")
	$BreakLabel.visible = true

func _ready() -> void:
	$CylinderMain.load_new_pins(PinGenerator.build_test_lock(CYL_COUNT))

	for i in range(PinSpec.CYLINDER_COUNT_MAX):
		var selector: OptionButton = $CardHBox.get_child(i)
		for t in PickTemplates.valid_templates:
			selector.add_item(t.pick_name)
		# let you repeat diamonds
		selector.add_item("diamond")
		selector.item_selected.connect(apply_card.bind(i))

	for i in range(CYL_COUNT, PinSpec.CYLINDER_COUNT_MAX):
		$CardHBox.get_child(i).disabled = true
		
	$ResetButton.pressed.connect($CylinderMain.reset_all_pins)
	$FallButton.pressed.connect($CylinderMain.handle_fall)
	$CylinderMain.pick_break.connect(break_pick)
