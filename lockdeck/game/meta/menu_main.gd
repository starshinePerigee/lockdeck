extends Control

signal open_settings
signal return_to_title
signal auto_complete_level
signal reveal_level
signal break_three

## Show the main menu. Hiding it will be handled by the widget itself.
func show_menu():
	visible = true
	$MenuWidget.show_widget()

func _ready() -> void:
	$MenuWidget.closed.connect(hide)
	$MenuWidget.add_button("Save and return to title", return_to_title.emit, true)
	$MenuWidget.add_button("Game settings", open_settings.emit, true)
	$MenuWidget.add_button("DEBUG: Solve level", auto_complete_level.emit, true)
	$MenuWidget.add_button("DEBUG: Reveal lock", reveal_level.emit, true)
	$MenuWidget.add_button("DEBUG: Break three", break_three.emit) 
