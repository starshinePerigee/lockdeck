@tool
extends TextureRect
class_name Depth

const TEXTURE_HIDDEN = preload("res://assets/depths/depth_hidden.png")

@export var flavor: DepthData.DepthFlavors = DepthData.DepthFlavors.DEBUG:
	set(v):
		flavor = v
		_redraw()

@export var revealed: bool = false:
	set(v):
		revealed = v
		_redraw()

func _redraw():
	if not is_node_ready():
		await ready
		
	if revealed:
		texture = DepthData.get_def(flavor).texture
	else:
		texture = TEXTURE_HIDDEN
