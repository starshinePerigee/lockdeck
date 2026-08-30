extends Control
## A global singleton used to request tooltips
## Exactly one instance of this class should be created on the top level scene.
class_name TooltipManager

const TOOLTIP_MARGIN := -4
const RECT_MARGIN := 2

static var _instance: TooltipManager

var _request_queue: Array[TooltipRequest] = []

class TooltipRequest:
	var rect: Rect2
	var widget: Control = null
	var text: String = ""
	var time: int
	
	func _init(
		rect_: Rect2,
		widget_: Control = null,
		text_: String = ""
	) -> void:
		rect = rect_
		widget = widget_
		text = text_
		time = Time.get_ticks_msec() 
		
		TooltipManager._instance._request_queue.append(self)

## Shows a text-only tooltip.
static func request_tooltip(rect: Rect2, text: String) -> void:
	if not _instance:
		return
	TooltipRequest.new(rect, null, text)

## Shows a specific widget as a tooltip 
## This widget should have a minimum width of 256 px or less
static func request_widget_tooltip(rect: Rect2, widget: Control) -> void:
	if not _instance:
		return
	TooltipRequest.new(rect, widget, "")

static func request_tooltip_close() -> void:
	if not _instance:
		return
	_instance._hide_tooltip()
	_instance._request_queue = []

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

var _displayed_request: TooltipRequest = null

func _process(_delta: float) -> void:
	# remove any requests we're no longer requesting
	for req in _request_queue.duplicate():
		if not req.rect.has_point(get_global_mouse_position()):
			if req == _displayed_request:
				# clean up the current request
				_hide_tooltip()
			_request_queue.erase(req)
	
	if len(_request_queue) == 0:
		# no tooltip requests in queue, so peace out
		return
	
	if _displayed_request == _request_queue.front():
		# nothing has changed since last _process interval
		return
	
	# update the refrect since it doesn't need timing
	if $ReferenceRect.visible:
		$ReferenceRect.global_position = _request_queue.front().rect.position
		$ReferenceRect.size = _request_queue.front().rect.size 
	
	# at this point, something has changed, and we have requests in queue.
	# so check time
	if Time.get_ticks_msec() - _request_queue.front().time > tooltip_speed_ms:
		# tooltip is done!
		_displayed_request = _request_queue.front()
		_show_tooltip(_request_queue.front())

func _show_tooltip(req: TooltipRequest) -> void:
	if req.widget:
		%Label.visible = false
		%Tooltip.add_child(req.widget)
		req.widget.position = Vector2()
	else:
		%Label.text = req.text
		%Label.visible = true

	%Tooltip.size = Vector2()
	call_deferred("_finalize", req.rect)

func _finalize(rect: Rect2) -> void:
	%Tooltip.global_position = _get_tooltip_pos(rect, %Tooltip.size)
	%Tooltip.show()
	%Rect.global_position = rect.position - Vector2(RECT_MARGIN, RECT_MARGIN)
	%Rect.size = rect.size + Vector2(RECT_MARGIN, RECT_MARGIN)
	%Rect.show()

func _hide_tooltip() -> void:
	if _displayed_request.widget:
		_displayed_request.widget.queue_free()
	_displayed_request = null
	for req in _request_queue:
		req.time = Time.get_ticks_msec()
	
	%Tooltip.hide()
	%Tooltip.position = Vector2()
	%Tooltip.size = Vector2()
	%Rect.hide()
	%Rect.position = Vector2()
	%Rect.size = Vector2()


static var tooltip_speed_ms: float

static func update_tooltip_speed(new_speed: float) -> void:
	tooltip_speed_ms = new_speed * 1000

func _ready() -> void:
	if _instance:
		push_error("Static global tooltip manager already initialized!")
		return
	_instance = self
	
	GameSettings.instance().tooltip_speed_changed.connect(update_tooltip_speed)
	update_tooltip_speed(GameSettings.instance().tooltip_speed)
