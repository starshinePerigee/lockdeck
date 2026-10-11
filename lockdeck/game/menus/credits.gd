extends Control

signal return_to_menu

func open_attributions() -> void:
	OS.shell_open("https://github.com/starshinePerigee/lockdeck/blob/dev/ATTRIBUTION.md")

func _ready() -> void:
	$ReturnButton.pressed.connect(return_to_menu.emit)
	$AttributionsButton.pressed.connect(open_attributions)