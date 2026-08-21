extends Control

## Show the settings. Hiding them will be handled by settings widget itself.
func show_settings():
	visible = true
	$SettingsWidget.show_widget()

func do_nothing():
	pass

func _ready() -> void:
	$SettingsWidget.closed.connect(hide)
	$SettingsWidget.add_button("Button 1", do_nothing)
	$SettingsWidget.add_button("Button 2", do_nothing)
	$SettingsWidget.add_button("Button 3", do_nothing, true)