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

func _init(depth_name_: String, effect_: Effects):
	depth_name = depth_name_
	texture = _get_texture(depth_name_)
	effect = effect_

## Debug depth. Should not be used.
static var DEBUG := Depths.new("debug", Effects.DEBUG)

## "?" texture. Should not be used.
static var HIDDEN := Depths.new("hidden", Effects.DEBUG)

## Blank depth with no effect.
static var EMPTY := Depths.new("empty", Effects.EMPTY)

## Unlock depth, needed to win.
static var KEY := Depths.new("key", Effects.KEY)

## Breaks the pick. Bad.
static var BREAK := Depths.new("break", Effects.BREAK)

## The neutral depth at the top of a pin. Has no effect.
static var BASE := Depths.new("base", Effects.EMPTY)
