extends Control

signal closed()

var grid: GridContainer
var label: Label

@export var header: String = "CARD_DISPLAY_HEADER":
	set(v):
		header = v
		
		if not is_node_ready():
			await ready
		
		label.text = header

@export var cards: Array[CardSpec] = []

func show_display():
	visible = true

func hide_display():
	visible = false
	closed.emit()

func redraw():
	if not is_node_ready():
		await ready
	
	for child in grid.get_children():
		grid.remove_child(child)
		child.queue_free()
	
	for card in cards:
		grid.add_child(PickCard.build_from_spec(card))

func _handle_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			hide_display()

func _ready() -> void:
	grid = $Container/MarginContainer/VBoxContainer/ScrollContainer/GridContainer
	label = $Container/MarginContainer/VBoxContainer/Label
	gui_input.connect(_handle_input)
	redraw()
	global_position = Vector2(0, 0)
	visible = false
