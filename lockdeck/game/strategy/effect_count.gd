extends VBoxContainer

static var _effects_template: Dictionary[String, int] = {
	"push": 0,
	"test": 0,
	"reveal": 0,
	"jam": 0
}

func count_effects(cards: Array[CardSpec]) -> Dictionary[String, int]:
	var effects: Dictionary[String, int] = _effects_template.duplicate()
	
	for card in cards:
		for effect_array in card.effects.values():
			for effect in effect_array as Array[EffectSpec]:
				if effect.flavor.effect_name in effects:
					effects[effect.flavor.effect_name] += effect.value

	return effects

func display_count(effects: Dictionary[String, int]) -> void:
	for effect in _effects_template.keys():
		var effect_name: String = effect.capitalize()
		var label: Label = find_child(effect_name).get_child(1)
		label.text = effect_name + ": " + str(effects[effect])

func update_counts(cards: Array[CardSpec]) -> void:
	display_count(count_effects(cards))

func _ready() -> void:
	if get_parent() == get_tree().root:
		update_counts(GameSpec.get_in_progress_game().current_deck)
