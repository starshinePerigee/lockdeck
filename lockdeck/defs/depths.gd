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

## Internal depth name used for texture lookup
var depth_name: String
## Human readable name of this depth, in lower case.
var english_name: String
## Tooltip description for this depth
var description
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
	description_: String = "",
	value_: int = 1,
	english_name_: String = "",
):
	depth_name = depth_name_
	description = description_
	texture = _get_texture(depth_name_)
	tests_as = tests_as_
	effect = effect_
	value = value_
	if english_name_:
		english_name = english_name_ 
	else:
		english_name = depth_name

#region fake depths
## Debug depth. Should not be used.
static var DEBUG := Depths.new(
	"debug", DangerLevel.INVALID, Effects.DEBUG, "Tell starshine you saw this!"
)

## Pending depth. used for level generation
static var PENDING := Depths.new("pending")

## Execution only depth indicating a depth has already been activated this turn
## and is now not activating again
static var EXHAUSTED := Depths.new(
	"exhausted", DangerLevel.INVALID, Effects.EMPTY,
	"This depth has been activated and will not activate again this turn."
)
#endregion

#region regular depths
static var EMPTY := Depths.new(
	"empty", DangerLevel.CLEAR, Effects.EMPTY, 
	"There's nothing here."
)

static var BASE := Depths.new(
	"base", DangerLevel.CLEAR, Effects.EMPTY,
	"The resting position of the pin. Does not activate."
)

static var FINAL := Depths.new(
	"final_neutral", DangerLevel.CLEAR, Effects.UNLOCK,
	"Reach this depth to solve this pin. Push past it to break your pick.",
	1, "final"
)

static var HIDDEN := Depths.new(
	"hidden", DangerLevel.INVALID, Effects.DEBUG,
	"Could be anything. Use test or reveal picks to learn more, or just activate it and see what happens."
)

static var MARK_CLEAR := Depths.new(
	"mark_clear", DangerLevel.INVALID, Effects.DEBUG,
	"Marked safe. You can advance to this depth without worry, although it might be dangerous in other ways.",
	0, "marked safe"
)

static var MARK_INTERESTING := Depths.new(
	"mark_interesting", DangerLevel.INVALID, Effects.DEBUG,
	("Marked caution, but could also be safe. If you activate this depth, something might happen. "
	+ "but you can be sure it won't break your pick."),
	0, "marked caution"
)

static var MARK_DANGEROUS := Depths.new(
	"mark_dangerous", DangerLevel.INVALID, Effects.DEBUG,
	("Marked dangerous, but could be actually be caution or even safe. "
	+ "If you activate this depth, anything could happen, including your pick breaking."),
	0, "marked dangerous"
)
#endregion

#region safe depths

## Push effect
static var PUSH := Depths.new(
	"push", DangerLevel.CLEAR, Effects.SAFE_PUSH, 
	"Will move the pick up by two. This can cause that depth to activate next turn, so be careful.",
	2
)

## solves the pin instantly
static var LUCKY := Depths.new(
	"lucky", DangerLevel.CLEAR, Effects.LUCKY,
	"Solves the pin immediately. Lucky you! Unless you break a pick pushing this pin afterwards."
)

## Reveals the next safe depth (if one) or sets the pin as clear
static var HINT := Depths.new(
	"hint", DangerLevel.CLEAR, Effects.HINT,
	"Reveals a safe depth on this pin, if one exists."
)

## Does nothing except indicates a break is ahead somewhere
static var WARN := Depths.new(
	"warn", DangerLevel.CLEAR, Effects.EMPTY,
	"Does nothing if activated, but know that the Break depth is past this one.",
	1, "warning"
)

#endregion

#region interesting depths

## Jam effect
static var JAM := Depths.new(
	"jam", DangerLevel.INTERESTING, Effects.JAM, 
	"Jams this pin by three jam.",
	3
)


## Bounces up four (or to the edge)
static var BOUNCE := Depths.new(
	"bounce", DangerLevel.INTERESTING, Effects.BOUNCE,
	"Bounces this pin backwards four spaces, but thankfully won't break your pick if you get sent past the start.",
	4
)

#endregion

#region break depths

static var BREAK := Depths.new(
	"break", DangerLevel.DANGEROUS, Effects.BREAK,
	"Breaks your pick. Avoid this if possible."
)

static var TRAP := Depths.new(
	"trap", DangerLevel.INVALID, Effects.DISARM,
	("Breaks your pick if you try to test or reveal this depth. "
	+ "Like all pins, it does nothing if exhausted, so activating it disarms it.")
)

#endregion
