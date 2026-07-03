extends TextureRect
## The view for a single depth in a pin.
class_name Depth

const _TEXTURE_HIDDEN := preload("res://assets/depths/depth_hidden.png")

## Flavor for this depth.
@export var flavor: Depths = Depths.DEBUG:
	set(v):
		flavor = v
		_redraw()

## If this depth is revealed. False sets the default ? texture.
@export var revealed: bool = false:
	set(v):
		revealed = v
		_redraw()

func _redraw() -> void:
	if not is_node_ready():
		await ready
		
	if revealed:
		texture = flavor.texture
	else:
		texture = _TEXTURE_HIDDEN
	
	size = texture.get_size()
