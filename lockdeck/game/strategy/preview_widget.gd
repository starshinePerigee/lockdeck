extends VBoxContainer

const DEPTH_INFO := preload("res://game/strategy/depth_info.tscn")

func _update_depth_preview(game: GameSpec) -> void:
	for child in %DepthsVBox.get_children():
		%DepthsVBox.remove_child(child)
		child.queue_free()
	
	var next_depths := game.lockset_deck.get_unique_depths()
	for difficulty in next_depths:
		var label := Label.new()
		label.theme_type_variation = "SmallText"
		var add_separator := true
		
		match difficulty:
			DepthTemplates.Difficulty.ESSENTIAL:
				label.text = "Always and forever:"
				add_separator = false
			DepthTemplates.Difficulty.CRITICAL:
				label.text = "Hazards:"
			DepthTemplates.Difficulty.ANNOYING:
				label.text = "Complications:"
			DepthTemplates.Difficulty.HELPFUL:
				label.text = "Weaknesses:"
		
		if add_separator:
			%DepthsVBox.add_child(HSeparator.new())
		%DepthsVBox.add_child(label)
		
		for depth in next_depths[difficulty]:
			var next_line := DEPTH_INFO.instantiate()
			next_line.depth = depth
			%DepthsVBox.add_child(next_line)

func update(game: GameSpec) -> void:
	%HeistLabel.text = "Heist %s" % game.heist_number
	%PinsLabel.text = "%s pins maximum" % game.get_max_pin_count()
	_update_depth_preview(game)

func reset(game: GameSpec) -> void:
	pass

func _ready() -> void:
	if get_tree().current_scene == self:
		var game := GameSpec.get_in_progress_game()
		update(game)
