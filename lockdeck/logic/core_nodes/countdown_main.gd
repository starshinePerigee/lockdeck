extends Control

@export var count: int = 0:
	set(v):
		count = max(0, v)
		$Countdown.set_count(v)