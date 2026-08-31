extends TextureRect

func _ready() -> void:
	var double_picks: Array[PickTemplates] = []
	double_picks.append_array(PickTemplates.ALL_PICKS.duplicate())
	double_picks.append_array(PickTemplates.ALL_PICKS.duplicate())
	double_picks.shuffle()
	
	var cards: Array[PickCard] = []
	cards.assign(get_children())
	
	for i in len(cards):
		cards[i].card_spec = CardSpec.from_template(double_picks[i])
		cards[i].find_child("EffectBar").visible = false
