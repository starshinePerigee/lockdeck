@tool
extends TextureRect
class_name CardSpace

const TEXTURE_OPEN = preload("res://assets/card/card_space.png")
const TEXTURE_CLOSED = preload("res://assets/card/card_space_blocked.png")
const CARD_SCENE = preload("res://objects/card/pick_card.tscn")

@export var closed: bool = false:
	set(v):
		closed = v
		
		if not is_node_ready():
			await ready
			
		if closed:
			texture = TEXTURE_CLOSED
		else:
			texture = TEXTURE_OPEN

@export var has_card: bool = false:
	set(v):
		has_card = v
	
		if not is_node_ready():
			await ready
		
		$PickCard.visible = has_card

@export var card_spec: CardSpec: 
	set(v):
		card_spec = v
		
		if not is_node_ready():
			await ready
		
		$PickCard.card_spec = v
