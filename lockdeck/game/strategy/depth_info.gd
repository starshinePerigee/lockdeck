extends HBoxContainer

@export var depth: Depths:
	set(v):
		depth = v
		$Depth.flavor = depth
		$Label.text = depth.english_name.capitalize()

func _ready() -> void:
	if get_tree().current_scene == self:
		depth = Depths.DEBUG