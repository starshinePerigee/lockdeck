extends VBoxContainer

const LINE := preload("res://objects/displays/card_tooltip_line.tscn")

func add_effects(effects: Array[Effects]) -> void:
	for effect in effects:
		var l := LINE.instantiate()
		l.draw(effect)
		add_child(l)

func _ready() -> void:
	if get_tree().current_scene == self:
		add_effects(
			CardSpec.from_template(PickTemplates.DEBUG).get_unique_list()
		)