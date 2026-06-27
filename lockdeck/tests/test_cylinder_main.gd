extends Node2D

static var CYL_COUNT := 5

func set_testpos() -> void:
	var pins: Array[PinSpec] = $CylinderMain.pins
	pins[0].pin_position = 0
	pins[1].pin_position = 1
	pins[1].jam_count = 2
	pins[1].jam_visible = true
	pins[1].pin_set = true
	pins[1].key_set = true
	pins[2].pin_position = 2
	pins[2].key_set = true
	pins[3].pin_position = 4
	pins[4].pin_position = PinSpec.PIN_DEPTH_COUNT - 1
	$CylinderMain.load_new_pins(pins)


func get_pick(selected: String) -> CardSpec:
	for t in PickTemplates.valid_templates:
		if t.pick_name == selected:
			return CardSpec.from_template(t)
	push_error("Could not find pick from selector!")
	return CardSpec.from_template(PickTemplates.DEBUG)

func update_card(dropdown_index: int):
	var selected: String = $CardSelectionOption.get_item_text(dropdown_index)
	var card := get_pick(selected)
	$CardSpace.card_spec = card

func do_click(pin_index: int) -> void:
	apply_card($CardSpace.card_spec, pin_index)

func apply_card(card: CardSpec, card_index: int) -> void:
	$BreakLabel.visible = false
	print("Applying pick %s on cylinder %s" % [card.pick_name, card_index])
	var result: ResultSpec = $CylinderMain.execute(card, card_index)
	if result.pick_broke:
		break_pick()

func break_pick() -> void:
	print("Pick break!")
	$BreakLabel.visible = true

func end_drag() -> void:
	var target: int = $CylinderMain.get_current_drag_target()
	if target >= 0:
		apply_card($CardSpace.card_spec, target)

func do_highlight(pin_index: int) -> void:
	$HighlightPos.text = str(pin_index)
	$Anchor/Dot.position = Vector2((96 + 32) * (pin_index + 1), 0)

func clear_highlight() -> void:
	$HighlightPos.text = "-1"
	$Anchor/Dot.position = Vector2()

func do_cursor(pin_index: int) -> void:
	$CursorPos.text = str(pin_index)
	$AnchorCursor/Dot.position = Vector2((96+32) * (pin_index + 1), 0)

func clear_cursor() -> void:
	$CursorPos.text = "-1"
	$AnchorCursor/Dot.position = Vector2()

func _ready() -> void:
	$CylinderMain/Cylinders.new_pin_hovered.connect(do_highlight)
	$CylinderMain/Cylinders.pin_no_longer_hovered.connect(clear_highlight)
	$CylinderMain/Cylinders.new_pin_cursored.connect(do_cursor)
	$CylinderMain/Cylinders.pin_no_longer_cursored.connect(clear_cursor)
	$CylinderMain/Cylinders.pin_activated.connect(do_click)
	
	$CylinderMain.load_new_pins(PinGenerator.build_test_lock(CYL_COUNT))
	for t in PickTemplates.valid_templates:
		$CardSelectionOption.add_item(t.pick_name)
	$CardSelectionOption.item_selected.connect(update_card)
	
	$CardSpace.card_dropped.connect(end_drag.unbind(1))
	$CardSpace.card_spec = CardSpec.from_template(PickTemplates.DIAMOND)

	for i in range(CYL_COUNT, PinSpec.CYLINDER_COUNT_MAX):
		$CardHBox.get_child(i).disabled = true
	
	$ResetButton.pressed.connect($CylinderMain.reset_all_pins)
	$FallButton.pressed.connect($CylinderMain.handle_fall)
	$DemoButton.pressed.connect(set_testpos)
