extends Resource
## Stores all effect flavors as a hand-rolled enum equivalent
class_name Effects

static func _get_texture(n: String) -> Resource:
	var res_str := "res://assets/effects/icon_%s.png" % n
	if ResourceLoader.exists(res_str):
		return load(res_str)
	else:
		return load("res://assets/effects/icon_debug.png")

## Human readable name of this effect, in lower case.
var effect_name: String
## Large texture, such as used for indicators and help.
var texture: Resource
## Small texture, such as used on a pick card.
var texture_small: Resource

func _init(name: String):
	self.effect_name = name
	self.texture = _get_texture(name)


## Debug effect. should not be used.
static var DEBUG := Effects.new("debug")

## Blank effect - needed for a display hack when composing cards :c
static var BLANK := Effects.new("blank")

## do nothing. Depth / pick effect  
static var EMPTY := Effects.new("empty")

## move the pin, triggering the depth at the destination and hinting everything between
static var PUSH := Effects.new("push")

## reveal the next depth but do not advance the pin
static var REVEAL := Effects.new("reveal")

## apply jam
static var JAM := Effects.new("jam")

## Test the next depths, indicating if there is a hazard or not
static var TEST := Effects.new("test")

## Destroy the affected depth, replacing it with a blank
static var CRUSH := Effects.new("crush")

## Depth effect - hint at the next danger or sets the pin to clear
static var HINT := Effects.new("hint")  # TODO

## Depth effect - unlock the current pin
static var UNLOCK := Effects.new("unlock")

## Depth effect - lock spin until other pin is set
static var BIND := Effects.new("bind")

## Depth effect - break the current pin
static var BREAK := Effects.new("break")

## Depth effect - resets another pin (if set) or this one
static var RESET := Effects.new("reset")

## Depth effect - bounces up four, or to top. Triggers landing spot.
static var BOUNCE := Effects.new("bounce")

## Depth effect - pick out of bounds (typically breaks)
static var OUT_OF_BOUNDS := Effects.new("out_of_bounds")

## stop evaluating current card. Used as a sentinel value in execution.
static var END_EXECUTION := Effects.new("end_execution")
