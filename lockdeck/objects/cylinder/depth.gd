extends TextureRect
## The view for a single depth in a pin.
class_name Depth

## Flavor to show for this depth.
@export var flavor: Depths = Depths.DEBUG:
	set(v):
		flavor = v
		_redraw()

func set_hints(letters: String, color: Color = Color()):
	if letters:
		$HintTracker.visible = true
	if len(letters) > 8:
		$HintTracker.text = "*" + letters.substr(len(letters) - 7, 7)
	else:
		$HintTracker.text = letters
	$HintTracker.add_theme_color_override("font_color", color)

func _redraw() -> void:
	if not is_node_ready():
		await ready
		
	texture = flavor.texture
	size = texture.get_size()
