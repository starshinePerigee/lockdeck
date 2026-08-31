extends Button

signal show_previous()
signal go_back()

static var T_NORMAL := load("res://assets/game/view_more_button.png")
static var T_HOVER := load("res://assets/game/view_more_button_hover.png")
static var T_PRESS := load("res://assets/game/view_more_button_press.png")
static var T_DISABLE := load("res://assets/game/view_more_button_disabled.png")

@export var show_see_prev := true:
	set(v):
		show_see_prev = v
		$TextureRect.flip_v = not show_see_prev
		if show_see_prev:
			text = "Prev turn"
		else:
			text = "Go back"

@export var disable := false:
	set(v):
		disable = v
		disabled = v

func _emit_signal():
	if show_see_prev:
		show_previous.emit()
	else:
		go_back.emit()

func _update_icon(texture: Texture2D):
	$TextureRect.texture = texture

func request_tooltip() -> void:
	TooltipManager.request_tooltip(
		get_global_rect,
		(
			"See a summary of what all happened last turn."
		)
	)

func _ready() -> void:
	mouse_entered.connect(_update_icon.bind(T_HOVER))
	mouse_exited.connect(_update_icon.bind(T_NORMAL))
	button_down.connect(_update_icon.bind(T_PRESS))
	button_up.connect(_update_icon.bind(T_HOVER))
	focus_entered.connect(_update_icon.bind(T_HOVER))
	focus_exited.connect(_update_icon.bind(T_NORMAL))
	
	pressed.connect(_emit_signal)
