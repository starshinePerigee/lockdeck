extends Control
## A global singleton used to request tooltips
## Exactly one instance of this class should be created on the top level scene.
class_name TooltipManager

const TOOLTIP_MARGIN := -4
const RECT_MARGIN := 2

static var _instance: TooltipManager

var _request_rect: Rect2:
	set(v):
		_request_rect = v
		if $ReferenceRect.visible:
			$ReferenceRect.position = _request_rect.position
			$ReferenceRect.size = _request_rect.size

var _request_widget: Control = null
var _request_text: String = ""

var _current_widget: Control = null


## Shows a text-only tooltip.
static func request_tooltip(rect: Rect2, text: String) -> void:
	if not _instance:
		return
	_instance._request_internal(rect, null, text)

## Shows a specific widget as a tooltip 
## This widget should have a minimum width of 256 px or less
static func request_widget_tooltip(rect: Rect2, widget: Control) -> void:
	if not _instance:
		return
	_instance._request_internal(rect, widget, "")

static func request_tooltip_close() -> void:
	if not _instance:
		return
	_instance._hide_tooltip()

func _request_internal(rect: Rect2, widget: Control, text: String) -> void:
	_hide_tooltip()
	_request_rect = rect
	$ReferenceRect.position = rect.position
	$ReferenceRect.size = rect.size
	_request_widget = widget
	_request_text = text
	$Timer.start()


func _redraw() -> void:
	if _request_widget:
		%Label.visible = false
		_current_widget = _request_widget
		%Tooltip.add_child(_current_widget)
		_current_widget.position = Vector2()
	else:
		%Label.text = _request_text
		%Label.visible = true

	%Tooltip.size = Vector2()
	call_deferred("_finalize", _request_rect)

func _finalize(rect: Rect2) -> void:
	%Tooltip.global_position = _get_tooltip_pos(rect, %Tooltip.size)
	%Tooltip.show()
	%Rect.global_position = rect.position - Vector2(RECT_MARGIN, RECT_MARGIN)
	%Rect.size = rect.size + Vector2(RECT_MARGIN, RECT_MARGIN)
	%Rect.show()

func _get_tooltip_pos(rect: Rect2, tooltip_size: Vector2) -> Vector2:
	var window: Vector2 = get_viewport().size
	# each bias is "how much space is there between the specified border and the rect" 
	var left_bias := rect.position.x
	var right_bias := window.x - rect.end.x
	var show_left := right_bias < left_bias
	
	var top_bias := rect.position.y
	var bottom_bias := window.y - rect.end.y
	var show_top := bottom_bias < top_bias
	
	var x: float
	if show_left:
		x = rect.position.x - tooltip_size.x - TOOLTIP_MARGIN
	else:
		x = rect.end.x + TOOLTIP_MARGIN
	
	var y: float
	if show_top:
		y = rect.position.y - tooltip_size.y - TOOLTIP_MARGIN
	else:
		y = rect.end.y + TOOLTIP_MARGIN
	
	return Vector2(x, y)

func _input(event: InputEvent) -> void:
	if (
		event is InputEventScreenDrag
		or event is InputEventMouseButton
	):
		_exit_tooltip()

func _process(_delta: float) -> void:
	if _request_rect:
		if not _request_rect.has_point(get_global_mouse_position()):
			_exit_tooltip()

func _hide_tooltip() -> void:
	if _current_widget:
		_current_widget.queue_free()
		_current_widget = null
	_request_rect = Rect2()
	$Timer.stop()
	%Tooltip.hide()
	%Tooltip.position = Vector2()
	%Tooltip.size = Vector2()
	%Rect.hide()
	%Rect.position = Vector2()
	%Rect.size = Vector2()

func _exit_tooltip() -> void:
	_hide_tooltip()
	_horrible_mouse_input_hack()


## This re-fires mouse entered logic and lets you reset the timer and handle
## overlapping controls
func _horrible_mouse_input_hack() -> void:
	var global_pos := get_global_mouse_position()
	var refresh := InputEventMouseMotion.new()
	refresh.position = Vector2(-9999, -9999)
	refresh.global_position = refresh.position
	Input.parse_input_event(refresh)

	await get_tree().process_frame

	var reset := InputEventMouseMotion.new()
	reset.position = global_pos
	reset.global_position = global_pos
	Input.parse_input_event(reset)

func _ready() -> void:
	if _instance:
		push_error("Static global tooltip manager already initialized!")
		return
	_instance = self
	$Timer.timeout.connect(_redraw)
