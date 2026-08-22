extends Control
## This is a popover to manage settings

signal closed()

func set_highlight_active_row(setting: bool) -> void:
	var settings := GameSettings.instance()
	settings.set_highlight_active_row(setting)

func set_ambience_volume(setting: float) -> void:
	var settings := GameSettings.instance()
	settings.set_ambience_volume(setting)

func set_music_volume(setting: float) -> void:
	var settings := GameSettings.instance()
	settings.set_music_volume(setting)

func set_effect_volume(setting: float) -> void:
	var settings := GameSettings.instance()
	settings.set_effect_volume(setting)

func show_widget():
	global_position = Vector2(0, 0)
	visible = true
	z_index = 1200

func hide_widget():
	visible = false
	closed.emit()

func _handle_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			hide_widget()

func _ready() -> void:
	gui_input.connect(_handle_input)
	visible = false
	
	var settings := GameSettings.instance()
	%ActiveRowToggle.button_pressed = settings.highlight_active_row
	%AmbienceSlider.set_value(settings.ambience_volume)
	%MusicSlider.set_value(settings.music_volume)
	%EffectSlider.set_value(settings.effect_volume)
	
	closed.connect(settings.save)
	%ActiveRowToggle.toggled.connect(set_highlight_active_row)
	%AmbienceSlider.setting_updated.connect(set_ambience_volume)
	%MusicSlider.setting_updated.connect(set_music_volume)
	%EffectSlider.setting_updated.connect(set_effect_volume)

	if get_parent() == get_tree().root:
		show_widget()
