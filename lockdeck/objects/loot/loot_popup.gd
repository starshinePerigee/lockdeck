extends Control
## This contains and displays the widget for each loot type
## Note that the containing loot widget must contain and emit a close_popup signal.

## Centers the main panel in the screen
func center_container() -> void:
	$PanelContainer.position = Vector2(
		(size.x - $PanelContainer.size.x) / 2,
		(size.y - $PanelContainer.size.y) / 2,
	)

func add_contents_and_show(
	contents: Control,
	loot: Loots,
):
	%LootName.text = "    " + loot.readable_name.capitalize()
	%LootTexture.texture = loot.texture
	%Description.text = loot.description + "\n"
	for child in %InnerContainer.get_children():
		child.queue_free()
	%PanelContainer.size = Vector2()
	%InnerContainer.add_child(contents)
	center_container.call_deferred()
	visible = true
	mouse_filter = MOUSE_FILTER_STOP

func remove_and_close() -> void:
	for child in %InnerContainer.get_children():
		child.queue_free()
	visible = false
	mouse_filter = MOUSE_FILTER_IGNORE

func _ready() -> void:
	center_container()
	
	# if name == "__main__:
	if get_tree().current_scene == self:
		var temp_contents := HBoxContainer.new()
		for __ in range(3):
			temp_contents.add_child(PickCard.build_from_template(PickTemplates.DEBUG))
		add_contents_and_show(temp_contents, Loots.BAR_3)
