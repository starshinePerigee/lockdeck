extends Resource
## Stores all effect flavors as a hand-rolled enum equivalent
class_name Effects

static func _get_texture(n: String) -> Resource:
	var res_str := "res://assets/effects/icon_%s.png" % n
	if ResourceLoader.exists(res_str):
		return load(res_str)
	else:
		return load("res://assets/effects/icon_activate.png")

## Human readable name of this effect, in lower case.
@export var effect_name: String
## Large texture, such as used for indicators and help.
var texture: Resource
## Used for tooltips
var description: String

static var static_registry: Dictionary[String, Effects] = {}

func _init(name_: String = "", description_: String = ""):
	effect_name = name_
	description = description_
	texture = _get_texture(name_)
	
	if effect_name:
		static_registry[effect_name] = self

#region utility effects

## Debug effect. should not be used.
static var DEBUG := Effects.new("debug", "If you see this tell starshine!")

## Blank effect - needed for a display hack when composing cards :c
static var BLANK := Effects.new("blank")

## also do nothing.
static var EXHAUSTED := Effects.new("exhausted")

## used to record effects blocked by jam
static var UNJAM := Effects.new("unjam")

## Depth effect - pick out of bounds (typically breaks)
static var OUT_OF_BOUNDS := Effects.new("out_of_bounds")

## Used for tracking bomb status
static var BOMB_DEFUSED := Effects.new("bomb_defused")

## stop evaluating current card. Used as a sentinel value in execution.
static var END_EXECUTION := Effects.new("end_execution")

#endregion

#region card effects

## move the pin, triggering the depth at the destination and hinting everything between
static var PUSH := Effects.new(
	"push",
	"Pushes the pin upward. Push the pin to the top to unlock the lock."
)

## Test the next depths, indicating if there is a hazard or not
static var TEST := Effects.new(
	"test",
	(
		"Tests this depth. "
		+ "All tested depths will be evaluated together "
		+ "and the worst case depth (safe, caution, or dangerous) will be "
		+ "indicated."
	)
)

## reveal the next depth but do not advance the pin
static var REVEAL := Effects.new(
	"reveal",
	"Shows the exact contents of this depth."
)

## apply jam
static var JAM := Effects.new(
	"jam",
	(
		"\"Jams\" the pin. "
		+ "Each point of jam requires one push to undo, "
		+ "and jammed pins can't be tested or revealed. "
		+ "Jammed pins don't reset at the end of a turn."
	)
)

## Card effect - advance the pin without activating. 
static var SKIP := Effects.new(
	"skip",
	(
		"Skips this depth, doing nothing except moving future "
		+ "test or reveal effects down the pin."
	)
)

#endregion

#region depth effects

## do nothing. Depth / pick effect  
static var EMPTY := Effects.new("empty")

## Do nothing but record it.
static var DISARM := Effects.new("disarm")

## like push, but doesn't break on OOB
static var SAFE_PUSH := Effects.new("safe_push")

## Advance to the end but don't hint anything
static var LUCKY := Effects.new("lucky")

## Depth effect - unlock the current pin
static var UNLOCK := Effects.new("unlock")

## Depth effect - break the current pick
static var BREAK := Effects.new("break")

## Breaks from deck (unless it's empty)
static var BREAK_FROM_DECK := Effects.new("break_from_deck")

## Depth effect - bounces up four, or to top. Triggers landing spot.
static var BOUNCE := Effects.new("bounce")

## Draw cards from discard (or deck)
static var DRAW_FROM_DISCARD := Effects.new("draw_from_discard")

## Depth effect - hint at the next danger or sets the pin to clear
static var HINT := Effects.new("hint")

## Depth effect - discard your hand
static var DISCARD_HAND := Effects.new("discard_hand")

## Starts the bomb countdown
static var BOMB := Effects.new("bomb")

## Unlocks the gate
static var GATE_UNLOCK := Effects.new("gate_unlock")

#endregion
