extends Resource
## AbilitySpec describes pick abilities
## most of their actual logic is implemented around the codebase, but this is
## basically a centra enum +
class_name Abilities

@export var description: String = ""

func _init(description_: String):
	description = description_

static var NONE := Depths.new("")

static var DEBUG := Depths.new("Tell starshine you saw this!")

static var TEMPORARY := Depths.new("Breaks after this heist.")
