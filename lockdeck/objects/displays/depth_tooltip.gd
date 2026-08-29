extends VBoxContainer

@export var depth: Depths:
	set(v):
		depth = v
		
		%DepthName.text = "  " + depth.english_name.capitalize()
		%Description.text = "  " + depth.description
		
		var tests_as_text: String
		var tests_as_color: Color
		match depth.tests_as:
			Depths.DangerLevel.INVALID:
				tests_as_text = "unknown"
				tests_as_color = Color("918891")
			Depths.DangerLevel.CLEAR:
				tests_as_text = "clear"
				tests_as_color = Pin.HINT_COLORS[PinSpec.RevealLevel.CLEAR]
			Depths.DangerLevel.INTERESTING:
				tests_as_text = "caution"
				tests_as_color = Pin.HINT_COLORS[PinSpec.RevealLevel.INTERESTING]
			Depths.DangerLevel.DANGEROUS:
				tests_as_text = "danger"
				tests_as_color = Pin.HINT_COLORS[PinSpec.RevealLevel.DANGEROUS]
		%TestsAs.text = tests_as_text
		%TestsAs.add_theme_color_override("font_color", tests_as_color)


func _ready() -> void:
	if get_tree().current_scene == self:
		var depth_list := [Depths.EMPTY, Depths.JAM, Depths.BREAK]
		depth = depth_list.pick_random()