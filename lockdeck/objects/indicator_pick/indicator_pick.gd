extends Control
## Manages the position of the indicator pick

# Indicator pick works as following:
# When visible, it will try to move to a position
# if a new position if updated, it'll stop moving, and move to a new position instead
# if a "stow" is recieved, it'll wait until the mouse is out of the box, then stow
# if a push is recieved, it'll move to that position and then push

signal start_push
signal at_top
signal reset

var INTER_PIN_SPACING := 80 + 32
var STOW_POSITION := Vector2(-128, -16)
var OFFSCREEN := STOW_POSITION + Vector2(-256, 0)
var PUSH := Vector2(0, -64)
var SPEED_PIXELS_PER_SEC := 1000
var PUSH_DURATION := 0.4

var mouse_box := Rect2()

var _tween: Tween = null

func _calc_delay(new_pos: Vector2) -> float:
	return new_pos.distance_to($Position.position) / SPEED_PIXELS_PER_SEC

func _tween_to(new_pos: Vector2) -> bool:
	if _push_requested:
		return false
	
	if _tween and _tween.is_running():
		_tween.kill()

	$Position.visible = true
	_tween = get_tree().create_tween()
	_tween.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	_tween.tween_property($Position, "position", new_pos, _calc_delay(new_pos))
	_tween.tween_callback(_on_tween_end)
	return true

var _current_target: Vector2
var _waiting_for_stow := false
var _push_requested := false

func _on_tween_end() -> void:
	if _push_requested:
		_actually_push()

func _process(_delta: float) -> void:
	if _waiting_for_stow:
		if not mouse_box.has_point(get_global_mouse_position()):
			_tween_to(STOW_POSITION)
			_waiting_for_stow = false

func _actually_push() -> void:
	if _tween and _tween.is_running():
		_tween.kill()
	
	_current_target = OFFSCREEN
	_tween = get_tree().create_tween()
	_tween.tween_callback(start_push.emit)
	_tween.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	_tween.tween_property($Position, "position", $Position.position + PUSH, PUSH_DURATION)
	_tween.tween_callback(at_top.emit)
	_tween.tween_property($Position, "position", $Position.position, PUSH_DURATION - 0.1)
	_tween.tween_callback(reset.emit)
	_tween.tween_property(self, "_push_requested", false, 0.0)
	_tween.tween_callback(_go_to_target)

func _go_to_target() -> void:
	_tween_to(_current_target)

func _actually_hide() -> void:
	_tween_to(OFFSCREEN)
	_tween.tween_property($Position, "visible", false, 0)

## Sets the pick to a given pin index
func go_index(index: int) -> void:
	_tween_to(Vector2(INTER_PIN_SPACING * index, 0))
	_waiting_for_stow = false

## Sets the pin to away and stowed
func go_stow() -> void:
	_current_target = STOW_POSITION
	_waiting_for_stow = true

## Hides the pick
func go_hide() -> void:
	_tween_to(OFFSCREEN)

func do_push() -> void:
	_push_requested = true
	if not _tween.is_running():
		_actually_push()

func _ready() -> void:
	$Position.position = OFFSCREEN
	$Position.visible = false
