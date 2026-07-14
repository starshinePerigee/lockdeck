extends Control
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

@export var exhausted: bool = false:
	set(v):
		exhausted = v
		_update_exhaust()

@export var show_exhausted: bool = false:
	set(v):
		show_exhausted = v
		_update_exhaust()

func _update_exhaust() -> void:
	# TODO: this should be a shader to replace the normal background texture
	# as modulation breaks the color limitations
	if exhausted and show_exhausted:
		$DepthTexture.modulate = Color("B4B4B4")
	else:
		$DepthTexture.modulate = Color("ffffff")

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
		
	$DepthTexture.texture = flavor.texture
	$DepthTexture.size = $DepthTexture.texture.get_size()
	size = $DepthTexture.size
