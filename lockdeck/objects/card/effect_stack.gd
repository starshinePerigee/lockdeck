@tool
extends Control
class_name EffectStack

const EFFECT_ICON = preload("res://objects/card/effect_icon.tscn")


const SIZE_SCALE = {
	true: [0, -8, -12, -16, -18, -19, -20],  # small
	false: [0, -15, -22, -25, -28, -30, -32, -33, -34, -35]  # big
}

@export var effects: Array[EffectSpec] = []:
	set(v):
		for spec in effects:
			if spec.changed.is_connected(_redraw):
				spec.changed.disconnect(_redraw)

		effects = v
		for i in range(len(effects)):
			if effects[i] == null:
				effects[i] = EffectSpec.new()

		for spec in effects:
			if not spec.changed.is_connected(_redraw):
				spec.changed.connect(_redraw)
		_redraw()

@export var small := true:
	set(v):
		small = v
		_redraw()

@export var fill := false:
	set(v):
		fill = v
		_redraw()

@export var refrect_visible = true:
	set(v):
		refrect_visible = v
		_redraw()

func _redraw() -> void:
	if not is_node_ready():
		await ready
		
	for child in get_children():
		remove_child(child)
		child.queue_free()
	
	for s in effects.size():
		var spec: EffectSpec = effects[s]
		var count: int = max(1, spec.value)
		
		for j in count:
			var icon := EFFECT_ICON.instantiate()
			icon.effect = spec.flavor
			icon.value = spec.value
			icon.refrect_visible = refrect_visible
			icon.small = small
			icon.show_text = j == spec.value - 1 or spec.value == 0
			icon.z_index = j - 5 * s
			add_child(icon)
		
		# hidden spacer between effect groups
		var spacer := EFFECT_ICON.instantiate()
		spacer.small = small
		spacer.hide_all = true
		spacer.refrect_visible = refrect_visible
		add_child(spacer)
	
	if effects.size() == 0 and fill:
		var fill := EFFECT_ICON.instantiate()
		fill.effect = EffectData.EffectFlavors.EMPTY
		fill.small = small
		fill.refrect_visible = refrect_visible
		fill.show_text = false
		add_child(fill)

	var child_count = get_child_count() - 1  # -1 for refrect
	var spacing: Array = SIZE_SCALE[small]
	var space := 0
	if child_count > len(spacing):
		space = spacing[-1]
	else:
		space = spacing[child_count - 1]
	add_theme_constant_override("separation", space)

func _ready() -> void:
	_redraw()
