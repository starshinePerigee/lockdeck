extends Control
## This is a popover to manage settings

signal opened()
signal closed()
signal ambience_hovered_start()
signal ambience_hovered_end()
signal music_hovered_start()
signal music_hovered_end()
signal effects_hovered_start()
signal effects_hovered_end()
signal reset_meta()
signal unlock_meta()


func set_fullscreen(setting: bool) -> void:
	var settings := GameSettings.instance()
	settings.set_fullscreen(setting)

func set_discrete_scale(setting: bool) -> void:
	var settings := GameSettings.instance()
	settings.set_discrete_scale(setting)


func set_highlight_active_row(setting: bool) -> void:
	var settings := GameSettings.instance()
	settings.set_highlight_active_row(setting)

static var tooltip_speeds: Dictionary[float, String] = {
	0.8: "Fast",
	1.4: "Medium",
	2.4: "Slow",
	999999: "Off"
}

func set_tooltip_speed() -> void:
	var settings := GameSettings.instance()
	var speed_pos := tooltip_speeds.keys().find(settings.tooltip_speed)
	settings.set_tooltip_speed(
		tooltip_speeds.keys()[
			(speed_pos + 1) % len(tooltip_speeds)
		]
	)

func update_tooltip_button(speed: float) -> void:
	if speed > 10:
		%TooltipSpeedButton.text = "Tooltips disabled"
	elif speed in tooltip_speeds:
		%TooltipSpeedButton.text = (
			"Tooltip speed: %s (%.1f s)"
			% [tooltip_speeds[speed], speed] 
		)

static var animation_speeds: Dictionary[float, String] = {
	2.6: "Slow",
	1.6: "Medium",
	1.0: "Fast",
	0.6: "Very Fast",
	0.0: "Instant"
}

func set_animation_speed() -> void:
	var settings := GameSettings.instance()
	var speed_pos := animation_speeds.keys().find(settings.animation_speed)
	settings.set_animation_speed(
		animation_speeds.keys()[
			(speed_pos + 1) % len(animation_speeds)
		]
	)

func update_animation_button(speed: float) -> void:
	if speed in animation_speeds:
		%AnimationSpeedButton.text = (
			"Animation speed: %s"
			% [animation_speeds[speed]] 
		)


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
	z_index = 3410
	opened.emit()
	reset_meta_buttons()

func hide_widget():
	visible = false
	closed.emit()

func _handle_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if (
			(event.button_index == MOUSE_BUTTON_LEFT or event.button_index == MOUSE_BUTTON_RIGHT)
			and event.pressed
		):
			hide_widget()

func request_active_row_tooltip() -> void:
	TooltipManager.request_tooltip(
		func(): return %ActiveRowToggle.get_global_rect().grow(4.0),
		"Shows an outline of the current row of depths, which will activate after using a pick."
	)
func request_fullscreen_tooltip() -> void:
	TooltipManager.request_tooltip(
		func(): return %FullscreenButton.get_global_rect().grow(4.0),
		"Toggles between fullscreen-windowed and windowed modes."
	)

func request_discrete_tooltip() -> void:
	TooltipManager.request_tooltip(
		func(): return %DiscreteScale.get_global_rect().grow(4.0),
		(
			"If checked, the game will scale its resolution to the largest whole number that "
			+ "will fit the window.\n"
			+ "Leave it checked to ensure crisp visuals, or uncheck it to remove the black outline "
			+ "and make sure the game is the largest possible size for your display."
		)
	)

func request_meta_reset_tooltip() -> void:
	TooltipManager.request_tooltip(
		func(): return %ResetMetaButton.get_global_rect().grow(4.0),
		(
			"Resets all meta-progression, re-locking all unlocked depths and decks."
		)
	)

func meta_reset() -> void:
	reset_meta.emit()
	%ResetMetaButton.disabled = true
	%ResetMetaButton.text = "Meta-progression reset!"
	%ResetMetaButton.base_text = "Meta-progression reset!"

func request_meta_unlock_tooltip() -> void:
	TooltipManager.request_tooltip(
		func(): return %ResetMetaButton.get_global_rect().grow(4.0),
		(
			"Unlocks all meta-progression, making all decks immediately available and unlocks all depths."
		)
	)

func meta_unlock() -> void:
	unlock_meta.emit()
	%UnlockMetaButton.disabled = true
	%UnlockMetaButton.text = "Meta-progression unlocked!"
	%UnlockMetaButton.base_text = "Meta-progression unlocked!"

func reset_meta_buttons() -> void:
	%ResetMetaButton.disabled = false
	%ResetMetaButton.text = "Reset progress"
	%ResetMetaButton.base_text = "Reset progress"
	%UnlockMetaButton.disabled = false
	%UnlockMetaButton.text = "Unlock everything"
	%UnlockMetaButton.base_text = "Unlock everything"

const FX_CLICK := preload("res://assets/fx/shell_click.ogg")

func _ready() -> void:
	gui_input.connect(_handle_input)
	visible = false
	%ActiveRowToggle.mouse_entered.connect(request_active_row_tooltip)
	%FullscreenButton.mouse_entered.connect(request_fullscreen_tooltip)
	%DiscreteScale.mouse_entered.connect(request_discrete_tooltip)
	%ResetMetaButton.mouse_entered.connect(request_meta_reset_tooltip)
	%UnlockMetaButton.mouse_entered.connect(request_meta_unlock_tooltip)
	
	var settings := GameSettings.instance()
	update_tooltip_button(settings.tooltip_speed)
	settings.tooltip_speed_changed.connect(update_tooltip_button)
	update_animation_button(settings.animation_speed)
	settings.animation_speed_changed.connect(update_animation_button)
	%ActiveRowToggle.button_pressed = settings.highlight_active_row
	%FullscreenButton.button_pressed = settings.fullscreen
	%DiscreteScale.button_pressed = settings.discrete_scale
	%AmbienceSlider.set_value(settings.ambience_volume)
	%MusicSlider.set_value(settings.music_volume)
	%EffectSlider.set_value(settings.effect_volume)
	
	closed.connect(settings.save)
	%TooltipSpeedButton.pressed.connect(set_tooltip_speed)
	%AnimationSpeedButton.pressed.connect(set_animation_speed)
	%ActiveRowToggle.toggled.connect(set_highlight_active_row)
	%FullscreenButton.toggled.connect(set_fullscreen)
	%DiscreteScale.toggled.connect(set_discrete_scale)
	%AmbienceSlider.setting_updated.connect(set_ambience_volume)
	%AmbienceSlider.hovered_start.connect(ambience_hovered_start.emit)
	%AmbienceSlider.hovered_stop.connect(ambience_hovered_end.emit)
	%MusicSlider.setting_updated.connect(set_music_volume)
	%MusicSlider.hovered_start.connect(music_hovered_start.emit)
	%MusicSlider.hovered_stop.connect(music_hovered_end.emit)
	%EffectSlider.setting_updated.connect(set_effect_volume)
	%EffectSlider.hovered_start.connect(effects_hovered_start.emit)
	%EffectSlider.hovered_stop.connect(effects_hovered_end.emit)
	%ResetMetaButton.pressed_confirmed.connect(meta_reset)
	%UnlockMetaButton.pressed_confirmed.connect(meta_unlock)
	
	for button in [
		%TooltipSpeedButton,
		%AnimationSpeedButton,
		%ResetMetaButton,
		%UnlockMetaButton,
	]:
		button.pressed.connect(GlobalEffects.request.bind(FX_CLICK))
	
	for toggle in [
		%ActiveRowToggle,
		%FullscreenButton,
		%DiscreteScale,
	]:
		toggle.toggled.connect(func(_x): GlobalEffects.request(FX_CLICK))
	
	if get_parent() == get_tree().root:
		show_widget()
