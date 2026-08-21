extends Control

## Show the settings. Hiding them will be handled by settings widget itself.
func show_settings():
	visible = true
	$MenuWidget.show_widget()

func do_nothing():
	pass

func _ready() -> void:
	$MenuWidget.closed.connect(hide)
	$MenuWidget.add_button("Button 1", do_nothing)
	$MenuWidget.add_button("Button 2", do_nothing)
	$MenuWidget.add_button("Button 3", do_nothing, true)
