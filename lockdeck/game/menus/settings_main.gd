extends Control

# honestly i'm not sure why this class still exists with all the logic in settings_widget
# dont harm no-one tho

## Show the settings. Hiding them will be handled by settings widget itself.
func show_settings():
	visible = true
	$SettingsWidget.show_widget()

func _ready() -> void:
	$SettingsWidget.closed.connect(hide)
