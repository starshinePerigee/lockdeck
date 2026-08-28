extends Node2D

#func _process(delta: float) -> void:
#	var global_mouse := get_global_mouse_position()
#	var text := (
#		"X position: %s, Y position: %s"
#		% [global_mouse.x, global_mouse.y]
#	)
#	var rect := Rect2(global_mouse, Vector2(128, 64))
#	TooltipManager.request_tooltip(rect, text)

var display_text := "x"

func _do_request(color_rect: ColorRect) -> void:
	print("entered %s" % color_rect.name)
	display_text = "%s%s " % [display_text, display_text]
	if len(display_text) > 1000:
		display_text = display_text.substr(1000, len(display_text))
	var rect := color_rect.get_global_rect()
	$ReferenceRect.global_position = rect.position
	$ReferenceRect.size = rect.size
	TooltipManager.request_tooltip(rect, display_text)

func _ready() -> void:
	for node in $Control.get_children():
		node = node as ColorRect
		node.mouse_entered.connect(_do_request.bind(node))