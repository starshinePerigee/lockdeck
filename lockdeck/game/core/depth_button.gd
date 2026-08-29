extends Button

func request_tooltip() -> void:
	TooltipManager.request_tooltip(
		get_global_rect().grow(4),
		(
			"Each pin is made of multiple depths, each with an effect.\n\n"
			+ "Press this button to see the depths that could be in this lock."
		)
	)

func _ready() -> void:
	mouse_entered.connect(request_tooltip)