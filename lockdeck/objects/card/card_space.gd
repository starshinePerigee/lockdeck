@tool
extends TextureRect
class_name CardSpace

signal card_pressed

const TEXTURE_OPEN = preload("res://assets/card/card_space.png")
const TEXTURE_CLOSED = preload("res://assets/card/card_space_blocked.png")
const TEXTURE_EMPTY = preload("res://assets/card/card_space_empty.png")
const CARD_SCENE = preload("res://objects/card/pick_card.tscn")

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

func handle_click():
	if has_card:
		card_pressed.emit()

func _set_texture():
	if has_card:
		texture = TEXTURE_EMPTY
	elif closed:
		texture = TEXTURE_CLOSED
	else:
		texture = TEXTURE_OPEN

func _ready():
	$PickCard.pressed.connect(handle_click)
