extends Control

signal closed()

func show_display() -> void:
	global_position = Vector2(0, 0)
	visible = true
	z_index = 120

func hide_display() -> void:
	visible = false
	closed.emit()

func _handle_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			hide_display()

const DEPTH_INFO := preload("res://game/strategy/depth_info.tscn")

func update(depths: Dictionary[DepthTemplates.Difficulty, Array]) -> void:
	for child in %DepthsVBox.get_children():
		%DepthsVBox.remove_child(child)
		child.queue_free()
	
	var add_separator := false
	
	var difficulties = DepthTemplates.Difficulty.values()
	difficulties.erase(DepthTemplates.Difficulty.ESSENTIAL)
	difficulties.append(DepthTemplates.Difficulty.ESSENTIAL)
	
	for difficulty in difficulties:
		if (
			difficulty not in depths
			or len(depths[difficulty]) == 0
		):
			continue
		
		if add_separator:
			%DepthsVBox.add_child(HSeparator.new())
		add_separator = true
		
		for depth in depths[difficulty]:
			var next_line := DEPTH_INFO.instantiate()
			next_line.depth = depth
			%DepthsVBox.add_child(next_line)


func _ready() -> void:
	gui_input.connect(_handle_input)
	visible = false

	if get_parent() == get_tree().root:
		update(GameSpec.get_in_progress_game().lockset_deck.get_unique_depths())
		visible = true