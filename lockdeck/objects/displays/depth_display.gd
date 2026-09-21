extends Control

signal closed()

const OFFSCREEN_LEFT := Vector2(-1440, 0)
const FX_WIPE := preload("res://assets/fx/menu_swipe.ogg")
const FX_WIPE_OUT := preload("res://assets/fx/menu_swipe_out.ogg")

var _tween: Tween

func show_display() -> void:
	if _tween:
		_tween.kill()
	
	global_position = OFFSCREEN_LEFT
	_tween = create_tween()
	_tween.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	_tween.tween_property(self, "global_position", Vector2.ZERO, 0.15)
	GlobalEffects.request(FX_WIPE)
	visible = true
	z_index = 120

func hide_display() -> void:
	if _tween:
		_tween.kill()
	
	_tween = create_tween()
	_tween.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	_tween.tween_property(self, "global_position", OFFSCREEN_LEFT, 0.15)
	_tween.tween_property(self, "visible", false, 0.0)
	GlobalEffects.request(FX_WIPE_OUT)
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
