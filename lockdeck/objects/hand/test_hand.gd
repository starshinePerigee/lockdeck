extends Control

func print_discard(index: int):
	print("Discarded: %s" % index)
	
func print_reordered(index: int, p: int):
	print("Reordered: %s to %s" % [index, p])

func _ready():
	$Hand.card_discarded.connect(print_discard)
	$Hand.card_rearranged.connect(print_reordered)
