extends Control
## Manages the position of the indicator pick

signal at_top

var INTER_PIN_SPACING := 80 + 32
var STOW_POSITION := Vector2(-128, -16)
var OFFSCREEN := STOW_POSITION + Vector2(-256, 0)
var SPEED_PIXELS_PER_SEC := 1000

var mouse_box := Rect2()

var _tween: Tween = null
@onready var _current_dest: Vector2 = $Position.position

func _calc_delay(new_pos: Vector2) -> float:
	return new_pos.distance_to($Position.position) / SPEED_PIXELS_PER_SEC

func _new_tween_to(new_pos: Vector2) -> Tween:
	if new_pos == _current_dest:
		return
	if _tween and _tween.is_running():
		_tween.kill()
	_current_dest = new_pos
	
	_tween = get_tree().create_tween()
	_tween.tween_property($Position, "position", new_pos, _calc_delay(new_pos))
	return _tween

var _waiting_for_stow := false

func _process(_delta: float) -> void:
	if _waiting_for_stow:
		if not mouse_box.has_point(get_global_mouse_position()):
			_actually_stow()
			_waiting_for_stow = false

## Sets the pin to away and stowed
func go_stow() -> void:
	_waiting_for_stow = true

func _actually_stow() -> void:
	$Position.visible = true
	_new_tween_to(STOW_POSITION)

## show the pick for the first time
func show_pick() -> void:
	if not $Position.visible:
		$Position.position = OFFSCREEN
		_actually_stow()
	else:
		go_stow()

## Sets the pick to a given pin index
func go_index(index: int) -> void:
	$Position.visible = true
	_new_tween_to(Vector2(INTER_PIN_SPACING * index, 0))

## Hides the pick
func go_hide() -> void:
	var tween := _new_tween_to(OFFSCREEN)
	if tween:
		tween.tween_property($Position, "visible", false, 0)

func _ready() -> void:
	$Position.position = OFFSCREEN
	$Position.visible = false
