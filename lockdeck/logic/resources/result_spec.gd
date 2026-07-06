extends Resource
## This is a very simple dataclass to pass the result of a pin execution
class_name ResultSpec

@export var pick_broke := false
@export var lock_solved := false
@export var turn_number := -1
@export var last_hint := ""