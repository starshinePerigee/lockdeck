extends TextureRect
class_name Depth

@export var revealed: bool = false
const TEXTURE_HIDDEN = preload("res://assets/icons/depths/hidden.png")

@export var flavor: DepthData.DepthFlavors = DepthData.DepthFlavors.DEBUG:
	set(value):
		flavor = value
		if revealed:
			texture = DepthData.get_def(value).texture
		else:
			texture = TEXTURE_HIDDEN
