extends Resource
## AbilitySpec describes pick abilities
## most of their actual logic is implemented around the codebase, but this is
## basically a centra enum +
class_name Abilities

@export var description: String = ""

static var static_registry: Dictionary[String, Abilities] = {}

func _init(description_: String = "Null ability"):
	description = description_
	
	if description != "Null ability":
		static_registry[description] = self

static var NONE := Abilities.new("")

static var DEBUG := Abilities.new("Tell feather you saw this!")

static var TEMPORARY := Abilities.new("Abandoned after this heist.")
