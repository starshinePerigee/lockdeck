extends Control
class_name Pin

const DEPTH = preload("res://objects/pin/depth.tscn")
var depths: Array[Depth] = []

@export_range(0, 12) var depth_size: int = 6

func _ready() -> void:
	for i in depth_size:
		var next = DEPTH.instantiate()
		next.flavor = DepthData.DepthFlavors.DEBUG
		$Stack/Depths.add_child(next)
		depths.append(next)
