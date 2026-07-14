extends Control

## emitted when we are out of turns
signal countdown_ended

## emitted when countdown is pressed (and confirmed, if needed)
signal countdown_triggered

@export var count: int = 0

#region end turn logic
# End of turn mechanics work like this:
# once you run out of turns, countdown puts SAFE_COUNT white balls in a bag.
# at the end of each turn, countdown puts a black ball in that bag, then draws a ball.
# if it's white, it's a safe turn and nothing happens
# if it's black, the next pick will break and countdown resets.

## How much to bias end of countdown towards breaks
const SAFE_COUNT := 3

@export var break_bag: Array[bool] = []

## resets the break odds
func reset_odds() -> void:
	break_bag.resize(SAFE_COUNT)
	break_bag.fill(false)

## Performs the end turn step, returning true if the next pick is to break.
func end_turn() -> bool:
	if len(break_bag) == 0:
		push_error("You forgot to initialize countdown odds!")
		return true
	
	if count > 0:
		return false
	
	break_bag.shuffle()
	if break_bag[0]:
		reset_odds()
		$Countdown.count = -1
		return true
	else:
		early_lockout = false
		break_bag.append(true)
		$Countdown.count = 0
		return false

#endregion

#region interface code
## disregard button presses
@export var button_disable := false:
	set(v):
		button_disable = v
		_draw_label()

func _draw_label() -> void:
	if button_disable or early_lockout:
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

var early_lockout := false:
	set(v):
		early_lockout = v
		_draw_label()

func count_down() -> void:
	if count <= 0:
		break_bag = [true]
		early_lockout = true
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
	early_lockout = false
	reset_odds()

func handle_press() -> void:
	print(early_lockout)
	if button_disable or early_lockout:
		return
	if suggest:
		countdown_triggered.emit()
	else:
		suggest = true
#endregion

func _ready() -> void:
	$Countdown.candle_clicked.connect(handle_press)
	reset_odds()
