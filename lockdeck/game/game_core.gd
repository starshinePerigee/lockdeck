extends Control

const CYLINDER_COUNT = 4

func _ready() -> void:
	$LockBody/Cylinders.cylinder_count = CYLINDER_COUNT
	$LockBody/Keyway.space_count = CYLINDER_COUNT
	
	for i in range(CYLINDER_COUNT):
		$LockBody/Cylinders.pins[i] = PinGenerator.get_random_base_pin()
		for j in range(4):
			$LockBody/Cylinders.pins[i].reveals[j] = true
		print(i)
		$LockBody/Keyway.cards[i] = PickGenerator.get_random_base_card()
	
	$LockBody/Cylinders.redraw()
	$LockBody/Keyway.redraw()
