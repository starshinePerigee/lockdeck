extends VBoxContainer

func update(
	reveal := PinSpec.RevealLevel.REVEALED, 
) -> void:
	visible = true
			
	var tests_as_text: String
	var tests_as_color: Color
	
	match reveal:
		PinSpec.RevealLevel.REVEALED:
			tests_as_text = "Nothing new"
			tests_as_color = Color("918891")
		PinSpec.RevealLevel.DANGEROUS:
			tests_as_text = "Danger"
			tests_as_color = Pin.HINT_COLORS[PinSpec.RevealLevel.DANGEROUS]
		PinSpec.RevealLevel.INTERESTING:
			tests_as_text = "Caution"
			tests_as_color = Pin.HINT_COLORS[PinSpec.RevealLevel.INTERESTING]
		PinSpec.RevealLevel.CLEAR:
			tests_as_text = "Safe"
			tests_as_color = Pin.HINT_COLORS[PinSpec.RevealLevel.CLEAR]
	
	%Result.text = tests_as_text
	%Result.add_theme_color_override("font_color", tests_as_color)
