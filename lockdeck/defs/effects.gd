extends Resource
## Stores all effect flavors as a hand-rolled enum equivalent
class_name Effects

static func _get_texture(n: String, small: bool) -> Resource:
	var suffix := "_small" if small else ""
	var res_str := "res://assets/effects/icon_%s%s.png" % [n, suffix]
	if ResourceLoader.exists(res_str):
		return load(res_str)
	else:
		return load("res://assets/effects/icon_debug_small.png")

## Human readable name of this effect, in lower case.
var effect_name:String
## Large texture, such as used for indicators and help.
var texture:Resource
## Small texture, such as used on a pick card.
var texture_small:Resource

func _init(name: String):
	self.effect_name = name
	self.texture = _get_texture(name, false)
	self.texture_small = _get_texture(name, true)


## Debug effect. should not be used.
static var DEBUG := Effects.new("debug")

## actually blank textures
static var BLANK := Effects.new("blank")

## do nothing. Depth / pick effect  
static var EMPTY := Effects.new("empty")

## move the pin
static var FORCE := Effects.new("force")

## apply jam
static var JAM := Effects.new("jam")

## reveal the next depth but do not advance the pin
static var TEST := Effects.new("test")

## Skip the next depth
static var JUMP := Effects.new("jump")

## Depth effect - unlock the current pin
static var KEY := Effects.new("key")

## Depth effect - break the current pin
static var BREAK := Effects.new("break")

## Depth effect - bounce the pin back to the top
static var BOUNCE := Effects.new("bounce")

## Depth effect - pick out of bounds (typically breaks)
static var OUT_OF_BOUNDS := Effects.new("out_of_bounds")

## stop evaluating current card. Used as a sentinel value in execution.
static var END_EXECUTION := Effects.new("end_execution")