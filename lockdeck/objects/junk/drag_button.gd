extends TextureButton

var _dragging := false
var start_position := Vector2()
var mouse_start_position := Vector2()

func _process(_delta: float) -> void:
	if _dragging:
		set_global_position(start_position + get_global_mouse_position() - mouse_start_position)

func _start_drag():
	start_position = global_position
	mouse_start_position = get_global_mouse_position()
	_dragging = true

func _stop_drag():
	_dragging = false

func _ready():
	button_down.connect(_start_drag)
	button_up.connect(_stop_drag)
