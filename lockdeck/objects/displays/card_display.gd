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

const OFFSCREEN_LEFT := Vector2(-1440, 0)
const OFFSCREEN_RIGHT := Vector2(1440, 0)
const FX_WIPE := preload("res://assets/fx/menu_swipe.ogg")
const FX_WIPE_OUT := preload("res://assets/fx/menu_swipe_out.ogg")

var _tween: Tween
var _was_left: bool

func show_display(left := true) -> void:
	if _tween:
		_tween.kill()
	
	if left:
		global_position = OFFSCREEN_LEFT
	else:
		global_position = OFFSCREEN_RIGHT
	_was_left = left
	_tween = create_tween()
	_tween.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	_tween.tween_property(self, "global_position", Vector2.ZERO, 0.15)
	GlobalEffects.request(FX_WIPE)
	visible = true
	z_index = 120

func hide_display() -> void:
	if _tween:
		_tween.kill()
	
	var offscreen_pos: Vector2
	if _was_left:
		offscreen_pos = OFFSCREEN_LEFT
	else:
		offscreen_pos = OFFSCREEN_RIGHT
	_tween = create_tween()
	_tween.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	_tween.tween_property(self, "global_position", offscreen_pos, 0.15)
	_tween.tween_property(self, "visible", false, 0.0)
	GlobalEffects.request(FX_WIPE_OUT)
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