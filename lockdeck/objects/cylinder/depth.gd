extends TextureRect
## The view for a single depth in a pin.
class_name Depth

## Flavor to show for this depth.
@export var flavor: Depths = Depths.DEBUG:
	set(v):
		flavor = v
		_redraw()

func _redraw() -> void:
	if not is_node_ready():
		await ready
		
	texture = flavor.texture
	size = texture.get_size()
