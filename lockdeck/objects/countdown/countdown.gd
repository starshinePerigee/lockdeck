extends Control
## The countdown clock/candle

const SEGMENT := preload("res://objects/countdown/segment.tscn")

func set_count(count: int) -> void:
	$Label.text = str(count)

	for child in $VBoxContainer.get_children():
		remove_child(child)
		child.queue_free()
	
	for i in range(count):
		$VBoxContainer.add_child(SEGMENT.instantiate())
