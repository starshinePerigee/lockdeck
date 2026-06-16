extends Control

# emitted when we are out of turns
signal countdown_ended

@export var count: int = 0

func count_down() -> void:
	if count == 0:
		return
	if count == 1:
		count = 0
		countdown_ended.emit()
	else:
		count -= 1
	$Countdown.set_count(count)

func set_count(new_count: int) -> void:
	count = new_count
	$Countdown.set_count(count)