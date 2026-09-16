extends Node

func set_fullscreen(fullscreen: bool) -> void:
	if fullscreen:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

func set_scale_mode(discrete: bool) -> void:
	var root := get_tree().root
	if discrete:
		root.content_scale_mode = Window.CONTENT_SCALE_MODE_VIEWPORT
		root.content_scale_stretch = Window.CONTENT_SCALE_STRETCH_INTEGER
	else:
		root.content_scale_mode = Window.CONTENT_SCALE_MODE_CANVAS_ITEMS
		root.content_scale_stretch = Window.CONTENT_SCALE_STRETCH_FRACTIONAL

func _ready() -> void:
	# This is an autoload so this should be your settings entrypoint
	var settings := GameSettings.instance()
	
	set_fullscreen(settings.fullscreen)
	settings.fullscreen_changed.connect(set_fullscreen)
	
	set_scale_mode(settings.discrete_scale)
	settings.discrete_scale_changed.connect(set_scale_mode)
	