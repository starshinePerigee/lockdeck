extends HBoxContainer

func draw(effect: Effects) -> void:	
	$EffectIcon.effect = effect
	$EffectIcon.redraw()
	$Label.text = (
		"%s: %s"
		% [effect.effect_name.capitalize(), effect.description]
	)
