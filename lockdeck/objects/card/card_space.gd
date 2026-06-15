extends TextureRect
## Represents a single card or space for a card on the game field.
## Note that despite being used for empty spaces, this always has a child PickCard - just hidden.
class_name CardSpace

## Card is present and clicked (could be tap, could be drag)
signal card_clicked()
## Card is tapped (clicked and relesaed within short distance)
signal card_tapped()
## Drag started
signal card_picked_up(Area2D)
## Drag eneded
signal card_dropped(Area2D)
## Other card has dragged into this space
signal drag_entered(Area2D)
## Other card has dragged out of this space
signal drag_exited(Area2D)
## Card is not present and space is clicked
signal area_clicked()

var _active := false
var _dragging := false
var start_position := Vector2()
var mouse_start_position := Vector2()

const TEXTURE_OPEN := preload("res://assets/card/card_space.png")
const TEXTURE_CLOSED := preload("res://assets/card/card_space_blocked.png")
const TEXTURE_EMPTY := preload("res://assets/card/card_space_empty.png")
const CARD_SCENE := preload("res://objects/card/pick_card.tscn")

const DRAG_DISTANCE := 25

## True if the card in the space is draggable
@export var draggable: bool = false

## True if this is a closed space (has X)
## Implies but does not set can_drop = false and has_card = false
@export var closed: bool = false:
	set(v):
		closed = v
		_set_texture()

## True if there is a card in this space, and if that card should be drawn
@export var has_card: bool = false:
	set(v):
		has_card = v
		_set_texture()

## True if this space should listen for collisions and highlight on them
@export var can_drop: bool = false

## Draw highlight and pop card
func set_selected() -> void:
	$HighlightRect.z_index = 90
	$HighlightRect.position = Vector2(-5, -30)
	$HighlightRect.visible = true
	$PickCard.position = Vector2(0, -25)
	z_boost = true

## Unpop card
func clear_selected() -> void:
	$HighlightRect.z_index = -10
	$HighlightRect.position = Vector2(-5, -5)
	$HighlightRect.visible = false
	$PickCard.position = Vector2(0, 0)
	z_boost = false

## Check if area is a valid collision source
## (card but not this card)
func _valid_collider(area: Area2D) -> bool:
	if not can_drop:
		return false
	if area == null:
		return true
	var parent := area.get_parent()
	if parent == $PickCard:
		return false
	return parent is PickCard

var _card_inside := false

# Used for signal targets:
func set_highlight(area: Area2D = null) -> void:
	if not _valid_collider(area):
		return
	_card_inside = true
	$HighlightRect.visible = true
	drag_entered.emit(area)

func clear_highlight(area: Area2D = null) -> void:
	$HighlightRect.visible = false
	if _card_inside:
		_card_inside = false
		drag_exited.emit(area)

@export var z_boost: bool:
	set(v):
		z_boost = v
		if z_boost:
			z_index = 200
		else:
			z_index = 0

@export var card_spec: CardSpec: 
	set(v):
		card_spec = v
		if card_spec != null:
			$PickCard.card_spec = v
		else:
			has_card = false

func _handle_space_input(event: InputEvent):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			area_clicked.emit()

func _start_click():
	if has_card:
		_active = true
		card_clicked.emit()
		if draggable:
			start_position = global_position
			mouse_start_position = get_global_mouse_position()

func _end_click():
	if _active:
		if not _dragging:
			card_tapped.emit()
		else:
			card_dropped.emit($PickCard/Area2D)
			call_deferred("snapback")
	_active = false
	_dragging = false

func snapback():
	$PickCard.set_global_position(start_position)

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
		var curr_mouse_position := get_global_mouse_position()
		if not _dragging and draggable:
			if curr_mouse_position.distance_to(mouse_start_position) >= DRAG_DISTANCE:
				_dragging = true
				card_picked_up.emit($PickCard/Area2D)
		if _dragging:
			$PickCard.set_global_position(
				start_position + get_global_mouse_position() - mouse_start_position
			)

func _ready():
	$PickCard.button_down.connect(_start_click)
	$PickCard.button_up.connect(_end_click)
	$Area2D.area_entered.connect(set_highlight)
	$Area2D.area_exited.connect(clear_highlight)
	
	gui_input.connect(_handle_space_input)
	_set_texture()
	clear_selected()

func get_area() -> Area2D:
	return $Area2D
