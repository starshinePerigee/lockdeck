extends Resource
## Stores all depths flavors as a hand-rolled enum equivalent
class_name Depths

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
## Default effect value
var value: int

func _init(depth_name_: String, effect_: Effects, value_: int = 1):
	depth_name = depth_name_
	texture = _get_texture(depth_name_)
	effect = effect_
	value = value_

## Debug depth. Should not be used.
static var DEBUG := Depths.new("debug", Effects.DEBUG)

## The neutral depth at the top of a pin. Has no effect.
static var BASE := Depths.new("base", Effects.EMPTY)

## The target end of the pin
static var FINAL := Depths.new("final_neutral", Effects.KEY)

## Blank depth with no effect.
static var EMPTY := Depths.new("empty", Effects.EMPTY)

## Force effect
static var FORCE := Depths.new("force", Effects.FORCE, 2)

## Jam effect
static var JAM := Depths.new("jam", Effects.JAM, 3)

## Unlock depth, needed to win.
static var KEY := Depths.new("key", Effects.KEY)

## Reveals the next hazard (if one) or sets the pin as clear
static var HINT := Depths.new("hint", Effects.HINT)  # TODO

## Breaks the pick. Bad.
static var BREAK := Depths.new("break", Effects.BREAK)

## Locks pin if skipped, does nothing if activated.
static var TRAP := Depths.new("trap", Effects.EMPTY)

## Locks the cylinder until another pin is set
static var BIND := Depths.new("bind", Effects.BIND)

## Resets another set pin (or this one, if none are set)
static var REST := Depths.new("reset", Effects.RESET)

## Does nothing except indicates a break is ahead somewhere
static var WARN := Depths.new("warn", Effects.EMPTY)


## Holds all depths which count as solves
static var SOLVE_DEPTHS: Array[Depths] = [
	FINAL, 
	KEY
]