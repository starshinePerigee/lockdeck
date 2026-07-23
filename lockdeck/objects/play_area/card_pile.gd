extends TextureRect

signal pile_pressed

@export var count: int = 0:
	set(v):
		count = v
		for i in range($Holder.get_child_count()):
			$Holder.get_child(i).visible = i < count

@export var highlighted: bool = false:
	set(v):
		highlighted = v
		$Highlight.visible = v

func _ready():
	$Button.pressed.connect(pile_pressed.emit)
	count = 0
