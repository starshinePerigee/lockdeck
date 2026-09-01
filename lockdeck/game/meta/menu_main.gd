extends Control

signal open_settings
signal return_to_title
signal auto_complete_level
signal reveal_level
signal break_three


var screenshot_number := 0

func request_screenshot() -> void:
	get_tree().create_timer(0.1).timeout.connect(take_screenshot)
	

func take_screenshot() -> void:
	await RenderingServer.frame_post_draw
	var img = get_viewport().get_texture().get_image()
	img.save_png("user://screenshot_%s.png" % screenshot_number)
	screenshot_number += 1

## Show the main menu. Hiding it will be handled by the widget itself.
func show_menu():
	visible = true
	$MenuWidget.show_widget()

func _ready() -> void:
	$MenuWidget.closed.connect(hide)
	$MenuWidget.return_to_title.connect(return_to_title.emit)
	$MenuWidget.add_button("Game settings", open_settings.emit, true)
	$MenuWidget.add_button("DEBUG: Solve level", auto_complete_level.emit, true)
	$MenuWidget.add_button("DEBUG: Reveal lock", reveal_level.emit, true)
#	$MenuWidget.add_button("DEBUG: Break three", break_three.emit) 
#	$MenuWidget.add_button("DEBUG: Screenshot", request_screenshot, true) 