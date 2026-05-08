@tool
extends TextureRect

signal pile_pressed

@export var count: int = 0:
	set(v):
		count = v
	
		if not is_node_ready():
			await ready
		
		$Label.text = str(count)
		for i in range($Holder.get_child_count()):
			$Holder.get_child(i).visible = i < count

func _ready():
	$Button.pressed.connect(pile_pressed.emit)
