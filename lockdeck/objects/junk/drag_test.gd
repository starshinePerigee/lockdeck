extends Control

func _enter_discard(area):
	print("Discard? %s" % area)

func _ready():
	$DiscardTarget/DiscardArea.area_entered.connect(_enter_discard)
