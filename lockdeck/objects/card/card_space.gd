@tool
extends TextureRect
class_name CardSpace

signal card_tapped()
signal card_picked_up()
signal card_dropped(Area2D)

var _active := false
var _dragging := false
var start_position := Vector2()
var mouse_start_position := Vector2()

const TEXTURE_OPEN = preload("res://assets/card/card_space.png")
const TEXTURE_CLOSED = preload("res://assets/card/card_space_blocked.png")
const TEXTURE_EMPTY = preload("res://assets/card/card_space_empty.png")
const CARD_SCENE = preload("res://objects/card/pick_card.tscn")

const DRAG_DISTANCE = 50
@export var draggable: bool = false

@export var closed: bool = false:
	set(v):
		closed = v
		_set_texture()

@export var has_card: bool = false:
	set(v):
		has_card = v
	
		if not is_node_ready():
			await ready
		
		$PickCard.visible = has_card
		_set_texture()

@export var highlighted: bool:
	set(v):
		highlighted = v
		if highlighted:
			$HighlightRect.z_index = 90
			$HighlightRect.position = Vector2(-5, -30)
			$HighlightRect.visible = true
			$PickCard.z_index = 100
			$PickCard.position = Vector2(0, -25)
		else:
			$HighlightRect.z_index = -10
			$HighlightRect.position = Vector2(-5, -5)
			$HighlightRect.visible = false
			$PickCard.z_index = 0
			$PickCard.position = Vector2(0, 0)

@export var card_spec: CardSpec: 
	set(v):
		card_spec = v
		
		if not is_node_ready():
			await ready
		
		$PickCard.card_spec = v

func _start_click():
	if has_card:
		_active = true
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
	set_global_position(start_position)

func _set_texture():
	if has_card and false:  # trying leaving the outline out
		texture = TEXTURE_EMPTY
	elif closed:
		texture = TEXTURE_CLOSED
	else:
		texture = TEXTURE_OPEN

func _process(_delta: float) -> void:
	if _active:
		var curr_mouse_position = get_global_mouse_position()
		if not _dragging and draggable:
			if curr_mouse_position.distance_to(mouse_start_position) >= DRAG_DISTANCE:
				_dragging = true
				card_picked_up.emit()
		if _dragging:
			set_global_position(start_position + get_global_mouse_position() - mouse_start_position)

func _ready():
	$PickCard.button_down.connect(_start_click)
	$PickCard.button_up.connect(_end_click)
