extends TextureRect
## The view for a single depth in a pin.
class_name Depth

const PREV_SPACING := 12

## Flavor to show for this depth.
@export var flavor: Depths = Depths.DEBUG:
	set(v):
		flavor = v
		_redraw()

@export var result: Results = Results.DEBUG:
	set(v):
		result = v
		$Result.visible = result != Results.EMPTY
		$Result.texture = result.texture

@export var show_jam_result: bool = false:
	set(v):
		show_jam_result = v
		$JamResult.visible = show_jam_result

@export var show_previous: bool = false:
	set(v):
		show_previous = v
		$PreviousAnchor.visible = show_previous

func set_hints(letters: String, color: Color = Color()):
	if letters:
		$HintTracker.visible = true
	if len(letters) > 8:
		$HintTracker.text = "*" + letters.substr(len(letters) - 7, 7)
	else:
		$HintTracker.text = letters
	$HintTracker.add_theme_color_override("font_color", color)

func clear_previous_icons() -> void:
	for child in $PreviousAnchor.get_children():
		$PreviousAnchor.remove_child(child)
		child.queue_free()

func add_previous_icon(space: int, effect: Effects) -> void:
	var new_icon := EffectIcon.build(effect)
	$PreviousAnchor.add_child(new_icon)
	new_icon.position = Vector2(space * PREV_SPACING, 0)

func _redraw() -> void:
	if not is_node_ready():
		await ready
		
	texture = flavor.texture
	size = texture.get_size()
