extends Node2D

@export var default_pick: String = "debug"

func set_testpos() -> void:
	var pins: Array[PinSpec] = $CylinderMain.pins
	pins[0].pin_position = 0
	pins[1].pin_position = 1
#	pins[1].jam_count = 2
	pins[2].pin_position = 2
	pins[3].pin_position = 4
	pins[4].pin_position = PinSpec.PIN_DEPTH_COUNT - 1
	$CylinderMain.load_new_lock(LockSpec.new(pins))

func get_pick(selected: String) -> CardSpec:
	if selected in PickTemplates.static_registry.keys():
		return CardSpec.from_template(
			PickTemplates.static_registry[selected]
		)
	
	push_error("Could not find pick %s from selector!" % selected)
	return CardSpec.DEBUG

func first_update():
	if default_pick:
		$CardSpace.card_spec = get_pick(default_pick)
		print("Loaded %s" % $CardSpace.card_spec.pick_name)

func update_card(dropdown_index: int):
	var selected: String = $CardSelectionOption.get_item_text(dropdown_index)
	var card := get_pick(selected)
	$CardSpace.card_spec = card

func do_click(pin_index: int) -> void:
	apply_card($CardSpace.card_spec, pin_index)

func print_previouses(result: EndStepSpec) -> void:
	result.print()

@onready var _last_result := EndStepSpec.new()

func apply_card(card: CardSpec, card_index: int) -> void:
	$BreakLabel.visible = false
	print("Applying pick %s on cylinder %s" % [card.pick_name, card_index])
	_last_result = $CylinderMain.execute(card, card_index)
	
	print_previouses(_last_result)
	
	$BreakLabel.visible = _last_result.pick_broke
		
	do_cursor(card_index)

func end_drag() -> void:
	var target: int = $CylinderMain.get_current_drag_target()
	if target >= 0:
		apply_card($CardSpace.card_spec, target)

func do_cursor(pin_index: int) -> void:
	$CylinderMain/AnchorCursor/CursorPos.text = str(pin_index)
	$CylinderMain/AnchorCursor/Dot.position = Vector2((80 + 32) * (pin_index + 1), 0)
	$CylinderMain.cancel_preview()
	$CylinderMain.preview($CardSpace.card_spec, pin_index)

func clear_cursor() -> void:
	$CylinderMain/AnchorCursor/CursorPos.text = "-1"
	$CylinderMain/AnchorCursor/Dot.position = Vector2()
	$CylinderMain.cancel_preview()
	$CylinderMain.show_preview(_last_result)

func reveal_all() -> void:
	if $RevealButton.button_pressed:
		print("The world unfolds before your eyes.")
		for pin in $CylinderMain.pins:
			pin.reveals.fill(PinSpec.RevealLevel.REVEALED)
		$CylinderMain.redraw_pins()


static func get_known_test_pin() -> PinSpec:
	var spec := PinSpec.new()
	for i in range(1, PinSpec.PIN_DEPTH_COUNT - 1):
		spec.depths[i] = Depths.EMPTY
	spec.depths[1] = Depths.TRAP
	spec.depths[2] = Depths.EMPTY
	spec.depths[3] = Depths.EMPTY
	spec.depths[4] = Depths.EMPTY
	spec.depths[5] = Depths.EMPTY
	spec.depths[6] = Depths.SPIKE
	spec.depths[7] = Depths.EMPTY
	spec.finalize()
	return spec

func gen_new_lock() -> void:
	var difficulty := int($Difficulty/Input.text)
	var lock := LockGenerator.get_next_level(
		difficulty,
		LockDeck.GameArcs.MID,
		5
	)
	
	if $Difficulty/DoTest.button_pressed:
		for i in 3:
			lock.pins[i] = get_known_test_pin()
	
	$CylinderMain.load_new_lock(lock)
	reveal_all()

var _cursoring: int = -1
func _process(_delta: float) -> void:
	var global_mouse := get_global_mouse_position()
	var pin_refs: Array[Pin] = $CylinderMain/Cylinders.get_valid_refs()
	for i in len(pin_refs):
		if pin_refs[i].get_mouse_rect().has_point(global_mouse):
			_cursoring = i
			do_cursor(i)
			return
	if _cursoring >= 0:
		clear_cursor()
		_cursoring = -1

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		if _cursoring >= 0:
			do_click(_cursoring)

func _ready() -> void:
	$Difficulty/Button.pressed.connect(gen_new_lock)
	
	gen_new_lock()
	first_update()

	for t in PickTemplates.valid_templates:
		$CardSelectionOption.add_item(t.pick_name)
	$CardSelectionOption.item_selected.connect(update_card)
	
	$CardSpace.card_dropped.connect(end_drag.unbind(1))
	
	$ResetButton.pressed.connect($CylinderMain.reset_all_pins)
	$FallButton.pressed.connect($CylinderMain.handle_fall)
	$DemoButton.pressed.connect(set_testpos)
	$RevealButton.pressed.connect(reveal_all)
