extends TextureRect
## Represents a single card or space for a card on the game field.
## Note that despite being used for empty spaces, this always has a child PickCard - just hidden.
class_name CardSpace

## Card is tapped (clicked and relesaed within short distance)
signal card_tapped()
## Drag started
signal card_picked_up()
## Drag eneded
signal card_dropped()
signal animation_complete()

const HIDE_DURATION := 0.23

var _dragging := false
var _active := false
var mouse_start_position := Vector2()
var disabled := false:
	set(v):
		disabled = v
		$PickCard.disabled = disabled

const TEXTURE_OPEN := preload("res://assets/card/space.png")
const TEXTURE_CLOSED := preload("res://assets/card/blocked.png")
const TEXTURE_EMPTY := preload("res://assets/card/empty.png")
const CARD_SCENE := preload("res://objects/card/pick_card.tscn")

const DRAG_DISTANCE := 25
const SUPER_DRAG_DISTANCE := 60
const HIGHLIGHT_OFFSET := 64

## True if the card in the space is draggable
@export var draggable: bool = false

## True if this is a closed space (has X)
@export var closed: bool = false:
	set(v):
		closed = v
		_set_texture()

## True if there is a card in this space, and if that card should be shown
@export var has_card: bool = false:
	set(v):
		has_card = v
		_set_texture()

@export var highlighted: bool = false:
	set(v):
		highlighted = v
		_set_texture()

var _selected := false

var _card_tween: Tween = null
func _card_tween_to(new_pos: int) -> void:
	if _card_tween:
		_card_tween.kill()
	_card_tween = $PickCard.create_tween()
	_card_tween.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	_card_tween.tween_property($PickCard, "position:y", new_pos, HIDE_DURATION)

## Draw highlight and pop card
func set_selected() -> void:
	_selected = true
	_card_tween_to(-HIGHLIGHT_OFFSET)
	$PickCard.tooltippable = false
	z_boost = true

## Unpop card
func clear_selected() -> void:
	_selected = false
	_card_tween_to(0)
	$PickCard.tooltippable = true
	z_boost = false

var _x_tween: Tween
## Travel to a given  x position
func tween_to(new_x: float, duration: float) -> Tween:
	if _x_tween:
		_x_tween.kill()
	_x_tween = create_tween()
	_x_tween.set_trans(Tween.TRANS_LINEAR)
	_x_tween.tween_property(self, "position:x", new_x, duration)
	_x_tween.tween_callback(animation_complete.emit)
	return _x_tween

var _y_tween: Tween
## Arc through a fixed height above 0 to a given y posistion
func arc_to(new_y: float, arc_height: int, duration:) -> Tween:
	if _card_tween:
		_card_tween.kill()
	
	# set current position to be the pick card's position:
	position += $PickCard.position
	$PickCard.position = Vector2()
	
	if _y_tween:
		_y_tween.kill()
	_y_tween = create_tween()
	
	var arc_peak := -arc_height
	if arc_height > 50:
		if position.y < arc_peak:
			# if we're above the requested arc peak
			arc_peak = int(position.y - 30)
		arc_peak -= randi_range(0, 40)
	_y_tween.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	_y_tween.tween_property(self, "position:y", arc_peak, duration / 2)
	_y_tween.set_ease(Tween.EASE_IN)
	_y_tween.tween_property(self, "position:y", new_y, duration / 2)
	
	_y_tween.set_ease(Tween.EASE_OUT)
	_y_tween.tween_property(self, "position:y", 0, HIDE_DURATION)
	return _y_tween

@export var z_boost: bool:
	set(v):
		if z_boost == v:
			return
		
		z_boost = v
		if z_boost and z_index < 2000:
			z_index += 2000
		elif z_index > 2000:
			z_index -= 2000

@export var card_spec: CardSpec: 
	set(v):
		card_spec = v
		if card_spec != null:
			$PickCard.card_spec = v
		else:
			has_card = false

func _start_click():
	if has_card:
		_cancel_snapback = false
		_active = true
		if draggable:
			mouse_start_position = get_local_mouse_position()

func _end_click():
	if _active:
		if not _dragging:
			card_tapped.emit()
		else:
			z_boost = false
			card_dropped.emit()
			call_deferred("snapback")
	_active = false
	_dragging = false

var _cancel_snapback := false

func cancel_snapback() -> void:
	_cancel_snapback = true

func snapback() -> void:
	if _cancel_snapback:
		return
	var tween := create_tween()
	var distance: float = Vector2().distance_to($PickCard.position)
	tween.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property($PickCard, "position", Vector2(), distance * 0.001)
	$PickCard.tooltippable = true
	$PickCard.force_normal = false

func _set_texture():
	if not is_node_ready():
		await ready

	$PickCard.visible = has_card
	if has_card and false:  # trying leaving the outline out
		texture = TEXTURE_EMPTY
	elif closed:
		texture = TEXTURE_CLOSED
	else:
		texture = TEXTURE_OPEN

func _process(_delta: float) -> void:
	if _active:
		var curr_mouse_position := get_local_mouse_position()
		if not _dragging and draggable:
			if curr_mouse_position.distance_to(mouse_start_position) >= DRAG_DISTANCE:
				_dragging = true
				z_boost = true
				$PickCard.tooltippable = false
				$PickCard.force_normal = true
				card_picked_up.emit()
		else:
			$PickCard.set_position(
				get_local_mouse_position() - mouse_start_position
			)

func _ready():
	$PickCard.button_down.connect(_start_click)
	$PickCard.button_up.connect(_end_click)	
		
	_set_texture()
	clear_selected()
	
	if get_tree().current_scene == self:
		card_spec = CardSpec.DEBUG

func get_mouse_rect() -> Rect2:
	return $PickCard.get_global_rect()

func core_hover() -> void:
	z_boost = true
	get_parent().move_child(self, -1)

func core_unhover() -> void:
	if not _selected:
		z_boost = false

func get_card_area() -> Area2D:
	return $PickCard/Area2D
