extends Control
class_name DragCard

signal picked_up()
signal dropped(Area2D)

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
	picked_up.emit()

func _stop_drag():
	_dragging = false
	dropped.emit($Area2D)
	call_deferred("snapback")

func snapback():
	set_global_position(start_position)

@export var has_card: bool = false:
	set(v):
		has_card = v
	
		if not is_node_ready():
			await ready
		
		$PickCard.visible = has_card
		$Area2D.visible = has_card

@export var card_spec: CardSpec: 
	set(v):
		card_spec = v
		
		if not is_node_ready():
			await ready
		
		$PickCard.card_spec = v

func _ready():
	$PickCard.button_down.connect(_start_drag)
	$PickCard.button_up.connect(_stop_drag)
