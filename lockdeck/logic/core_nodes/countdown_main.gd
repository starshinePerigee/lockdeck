extends Control

## emitted when we are out of turns
signal countdown_ended

## emitted when countdown is pressed (and confirmed, if needed)
signal countdown_triggered

@export var count: int = 0

## disregard button presses
@export var button_disable := false:
	set(v):
		button_disable = v
		if button_disable:
			$Countdown/Label.add_theme_color_override(
				"font_color", Color("#918891")
			)
		else:
			$Countdown/Label.add_theme_color_override(
				"font_color", Color("FFFFFF")
			)

## If end turn is suggested
@export var suggest := false:
	set(v):
		suggest = v
		$Countdown/Highlight.visible = suggest
		$Countdown.show_end = suggest

func count_down() -> void:
	if count == 0:
		return
	if count == 1:
		count = 0
		countdown_ended.emit()
	else:
		count -= 1
	$Countdown.count = count

func set_count(new_count: int) -> void:
	count = new_count
	$Countdown.count = count

func handle_press() -> void:
	if button_disable:
		return
	if suggest:
		countdown_triggered.emit()
	else:
		suggest = true

func _ready() -> void:
	$Countdown.candle_clicked.connect(handle_press)
