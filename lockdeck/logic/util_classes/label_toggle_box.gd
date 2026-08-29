extends Control
## this is a mistake but i'm tired so w/e
class_name LabelToggleBox

signal toggled(bool)

@export var label_text: String

static var checked_textures: Dictionary[Button.DrawMode, Texture2D] = {
	Button.DrawMode.DRAW_NORMAL: preload(
		"res://assets/interface/checkbox_checked_normal.png"
	),
	Button.DrawMode.DRAW_HOVER: preload(
		"res://assets/interface/checkbox_checked_hover.png"
	),
	Button.DrawMode.DRAW_HOVER_PRESSED: preload(
		"res://assets/interface/checkbox_checked_pressed.png"
	),
	Button.DrawMode.DRAW_DISABLED: preload(
		"res://assets/interface/checkbox_checked_disabled.png"
	),
}

static var unchecked_textures: Dictionary[Button.DrawMode, Texture2D] = {
	Button.DrawMode.DRAW_NORMAL: preload(
		"res://assets/interface/checkbox_unchecked_normal.png"
	),
	Button.DrawMode.DRAW_HOVER: preload(
		"res://assets/interface/checkbox_unchecked_hover.png"
	),
	Button.DrawMode.DRAW_HOVER_PRESSED: preload(
		"res://assets/interface/checkbox_unchecked_pressed.png"
	),
	Button.DrawMode.DRAW_DISABLED: preload(
		"res://assets/interface/checkbox_unchecked_disabled.png"
	),
}

@export var button_pressed := false:
	set(v):
		button_pressed = v
		update_textures()

func update_textures() -> void:
	var textures: Dictionary[Button.DrawMode, Texture2D]
	if button_pressed:
		textures = checked_textures
	else:
		textures = unchecked_textures
	
	%ActiveRowToggle.texture_normal = textures[Button.DrawMode.DRAW_NORMAL]
	%ActiveRowToggle.texture_hover = textures[Button.DrawMode.DRAW_HOVER]
	%ActiveRowToggle.texture_pressed = textures[Button.DrawMode.DRAW_HOVER_PRESSED]
	%ActiveRowToggle.texture_disabled = textures[Button.DrawMode.DRAW_DISABLED]

func toggle() -> void:
	button_pressed = not button_pressed
	toggled.emit(button_pressed)

func update_size() -> void:
	var h_size: float = $ActiveRowToggle/Label.size.x + 42
	%ActiveRowToggle.custom_minimum_size.x = h_size

func _ready() -> void:
	$ActiveRowToggle/Label.mouse_entered.connect(mouse_entered.emit)
	$ActiveRowToggle.mouse_entered.connect(mouse_entered.emit)
	$ActiveRowToggle/Label.text = label_text
	call_deferred("update_size")
	
	%ActiveRowToggle.pressed.connect(toggle)
	update_textures()