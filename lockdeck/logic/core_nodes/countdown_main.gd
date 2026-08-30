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
		break_bag.append(true)
		$Countdown.count = 0
		return false

func game_over() -> void:
	$Countdown.game_over = true
	button_disable = true
#endregion

#region interface code
var _is_hovered := false

## disregard button presses
@export var button_disable := false:
	set(v):
		button_disable = v
		_draw_label()

func _draw_label() -> void:
	var font_color := Color("#ffffff")
	if button_disable:
		font_color = Color("#918891")
	elif _is_hovered:
		font_color = Color("#ffbc57")
	
	$Countdown/Label.add_theme_color_override(
		"font_color", font_color 
	)

func set_hovered(hovered: bool) -> void:
	_is_hovered = hovered
	_draw_label()

## If end turn is suggested
@export var suggest := false:
	set(v):
		suggest = v
		$Countdown/Highlight.visible = suggest
		$Countdown.show_end = suggest

func count_down() -> void:
	if count <= 0:
		push_error("Countdown less than 0! Count: %s" % count)
		break_bag = [true]
		return
	if count == 1:
		count = 0
		countdown_ended.emit()
	else:
		count -= 1
	$Countdown.count = count

func set_count(new_count: int) -> void:
	count = new_count
	$Countdown.game_over = false
	$Countdown.count = count
	reset_odds()

var _pressed := false

func handle_press() -> void:
	if button_disable:
		return
	if suggest:
		_pressed = false
		countdown_triggered.emit()
	else:
		_pressed = true
		suggest = true
#endregion

func request_tooltip() -> void:
	if button_disable or _pressed:
		return
	
	TooltipManager.request_tooltip(
		get_mouse_rect(),
		(
			"This is your turn counter.\n\n"
			+ "Click to end your turn.\n\n"
			+ "If you run out of picks, or need one from your discard, "
			+ "ending your turn will shuffle your hand and discard pile back into your deck and "
			+ "you will draw a new hand.\n\n" 
			+ "Ending your turn will also reset all non-jammed pins, moving them back to their "
			+ "starting positions. All depths will reset and can be triggered again.\n\n"
			+ "After two turns, your light will go out and you will have a chance to break each pick "
			+ "when you use it.\n\n"
			+ "After three turns, you will be locked out and your game will end."
		) 
	)

func get_mouse_rect() -> Rect2:
	return $Countdown.get_global_rect().grow_side(Side.SIDE_BOTTOM, 26)

func _ready() -> void:
	$Countdown.candle_clicked.connect(handle_press)
	$Countdown.mouse_entered.connect(request_tooltip)
	$Countdown.mouse_entered.connect(set_hovered.bind(true))
	$Countdown.mouse_exited.connect(set_hovered.bind(false))
	reset_odds()
