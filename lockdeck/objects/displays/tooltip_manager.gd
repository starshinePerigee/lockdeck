extends Control
## A global singleton used to request tooltips
## Exactly one instance of this class should be created on the top level scene.
class_name TooltipManager

const TOOLTIP_MARGIN := -4
const RECT_MARGIN := 2

static var _instance: TooltipManager

## Shows a text-only tooltip.
static func request_tooltip(rect: Rect2, text: String) -> void:
	_instance._request_label_internal(rect, text)

func _request_label_internal(rect: Rect2, text: String) -> void:
	_hide_tooltip()
	$Timer.timeout.connect(_request_label_for_real.bind(rect, text))
	$Timer.start()

func _request_label_for_real(rect: Rect2, text: String) -> void:
	_retrieve_label()
	%Label.text = text
	_request_internal(rect)

## Shows a specific widget as a tooltip 
## This widget should have a minimum width of 256 px or less
static func request_widget_tooltip(rect: Rect2, widget: Control) -> void:
	_instance._request_widget_internal(rect, widget)

func _request_widget_internal(rect: Rect2, widget: Control) -> void:
	_hide_tooltip()
	$Timer.timeout.connect(_request_widget_for_real.bind(rect, widget))
	$Timer.start()

func _request_widget_for_real(rect: Rect2, widget: Control) -> void:
	_stash_label()
	%Tooltip.add_child(widget)
	widget.position = Vector2()
	_request_internal(rect)

func _request_internal(rect: Rect2) -> void:
	%Tooltip.size = Vector2()
	call_deferred("_finalize", rect)

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


func _stash_label() -> void:
	_destroy_non_label_children()
	if %Label not in %Tooltip.get_children():
		return
	%Tooltip.remove_child(%Label)
	%TimeoutCornerForBadWidgets.add_child(%Label)
	%Label.position = Vector2()
	%Label.visible = false

func _retrieve_label() -> void:
	_destroy_non_label_children()
	if %Label not in %TimeoutCornerForBadWidgets.get_children():
		return
	%Tooltip.remove_child(%Label)
	%Tooltip.add_child(%Label)
	%Label.position = Vector2()
	%Label.visible = true

func _destroy_non_label_children() -> void:
	for child in %Tooltip.get_children():
		if child != %Label:
			%Tooltip.remove_child(child)
			child.queue_free()

func _hide_tooltip() -> void:
	for conn in $Timer.timeout.get_connections():
		$Timer.timeout.disconnect(conn.callable)
	$Timer.stop()
	%Tooltip.hide()
	%Tooltip.position = Vector2()
	%Rect.hide()
	%Rect.position = Vector2()
	%Rect.size = Vector2()

func _exit_tooltip() -> void:
	_hide_tooltip()
	_horrible_mouse_input_hack()

func _process(delta: float) -> void:
	if %Tooltip.visible:
		if not %Rect.get_global_rect().has_point(get_global_mouse_position()):
			_exit_tooltip()

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
	else:
		_instance = self
