extends Control
## This is the top level entrypoint for Handful of Lockpicks

var VERSION_NUMBER := "v0.7.0"

func _ready() -> void:
	$Version.text = VERSION_NUMBER

	$TopLevelMenus/Title.show_settings.connect($SettingsWidget.show_widget)
