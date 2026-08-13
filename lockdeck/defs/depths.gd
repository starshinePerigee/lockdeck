extends Resource
## Stores all depths flavors as a hand-rolled enum equivalent
class_name Depths

enum DangerLevel {
	## Raises a warning if tested, but tests as interesting
	INVALID,
	CLEAR,
	INTERESTING,
	DANGEROUS
}

static func _get_texture(n: String) -> Resource:
	var res_str := "res://assets/depths/depth_%s.png" % [n]
	if ResourceLoader.exists(res_str):
		return load(res_str)
	else:
		return load("res://assets/depths/depth_debug.png")

## Human readable name of this depth, in lower case.
var depth_name: String
## Depth texture (as seen in a pin)
var texture: Resource
## Effect flavor
var effect: Effects
## What the depth tests as
var tests_as
## Default effect value
var value: int

func _init(
	depth_name_: String,
	tests_as_: DangerLevel = DangerLevel.INVALID,
	effect_: Effects = Effects.DEBUG,
	value_: int = 1
):
	depth_name = depth_name_
	texture = _get_texture(depth_name_)
	tests_as = tests_as_
	effect = effect_
	value = value_

## Debug depth. Should not be used.
static var DEBUG := Depths.new("debug")

## Pending depth. used for level generation
static var PENDING := Depths.new("pending")

## The neutral depth at the top of a pin. Has no effect.
static var BASE := Depths.new("base", DangerLevel.CLEAR, Effects.EMPTY)

## The target end of the pin
static var FINAL := Depths.new("final_neutral", DangerLevel.CLEAR, Effects.UNLOCK)

## Default unrevealed depth
static var HIDDEN := Depths.new("hidden")

## Marked clear
static var MARK_CLEAR := Depths.new("mark_clear")

## Default unrevealed depth
static var MARK_INTERESTING := Depths.new("mark_interesting")

## Default unrevealed depth
static var MARK_DANGEROUS := Depths.new("mark_dangerous")

## Blank depth with no effect.
static var EMPTY := Depths.new("empty", DangerLevel.CLEAR, Effects.EMPTY)

## Execution only depth indicating a depth has already been activated this turn
## and is now not activating again
static var EXHAUSTED := Depths.new("exhausted", DangerLevel.INVALID, Effects.EMPTY)

## Push effect
static var PUSH := Depths.new("push", DangerLevel.CLEAR, Effects.SAFE_PUSH, 2)

## Jam effect
static var JAM := Depths.new("jam", DangerLevel.INTERESTING, Effects.JAM, 3)

## Unlock depth, needed to win.
static var UNLOCK := Depths.new("unlock", DangerLevel.CLEAR, Effects.UNLOCK)

## Reveals the next hazard (if one) or sets the pin as clear
static var HINT := Depths.new("hint", DangerLevel.CLEAR, Effects.HINT)  # TODO

## Breaks the pick. Bad.
static var BREAK := Depths.new("break", DangerLevel.DANGEROUS, Effects.BREAK)

# ## Locks pin if skipped, does nothing if activated.
## extra fun bonus break
static var TRAP := Depths.new("trap", DangerLevel.DANGEROUS, Effects.BREAK)

## Locks the cylinder until another pin is set
static var BIND := Depths.new("bind", DangerLevel.INTERESTING, Effects.BIND)

## Resets another set pin (or this one, if none are set)
static var RESET := Depths.new("reset", DangerLevel.INTERESTING, Effects.RESET)

## Does nothing except indicates a break is ahead somewhere
static var WARN := Depths.new("warn", DangerLevel.CLEAR, Effects.EMPTY)

## Bounces up four (or to the edge)
static var BOUNCE := Depths.new("bounce", DangerLevel.INTERESTING, Effects.BOUNCE, 4)
