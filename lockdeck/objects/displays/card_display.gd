extends Control

signal closed()

@export var header: String = "CARD_DISPLAY_HEADER":
	set(v):
		header = v
		
		if not is_node_ready():
			await ready
		
		%TitleLabel.text = header

@export var cards: Array[CardSpec] = []

@export var has_sections := false

@export var cards_2: Array[CardSpec] = []

func show_display() -> void:
	global_position = Vector2(0, 0)
	visible = true
	z_index = 120

func hide_display() -> void:
	visible = false
	closed.emit()

func redraw() -> void:
	if not is_node_ready():
		await ready
	
	for child in %GridContainer.get_children():
		%GridContainer.remove_child(child)
		child.queue_free()
		
	for child in %GridContainer2.get_children():
		%GridContainer2.remove_child(child)
		child.queue_free()
	
	for card in cards:
		%GridContainer.add_child(PickCard.build_from_spec(card))
	
	for card in cards_2:
		%GridContainer2.add_child(PickCard.build_from_spec(card))
	
	%EmptyLabel.visible = len(cards) == 0
	
	%HSeparator.visible = has_sections
	%Title2.visible = has_sections
	%GridContainer2.visible = has_sections
	
	%EmptyLabel2.visible = len(cards_2) == 0 and has_sections

func _handle_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			hide_display()

func _ready() -> void:
	gui_input.connect(_handle_input)
	redraw()
	visible = false

	if get_parent() == get_tree().root:
		var test_cards: Array[CardSpec]
		for i in 14:
			test_cards.append(CardSpec.from_template())
		cards = test_cards
		redraw()
		visible = true