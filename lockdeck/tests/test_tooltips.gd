extends Node2D

func _process(delta: float) -> void:
	var global_mouse := get_global_mouse_position()
	var text := (
		"X position: %s, Y position: %s"
		% [global_mouse.x, global_mouse.y]
	)
	var rect := Rect2(global_mouse, Vector2(128, 64))
	TooltipManager.request_tooltip(rect, text)
