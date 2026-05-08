@tool
extends Control

const EFFECT_ICON = preload("res://objects/card/effect_icon.tscn")

const SIZE_SCALE = {
	# these start at 1; the 5th element is the space if you have five values
	true: [0, -8, -12, -16, -18, -19, -20],  # small
	false: [-5, -20, -30, -35, -38, -40, -41, -42, -43, -43, -44, -44, -44, -45]  # big
}

@export var effects: Array[EffectSpec] = []:
	set(v):
		effects = v
		for i in range(len(effects)):
			if effects[i] == null:
				effects[i] = EffectSpec.new()
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
		var fill_icon := EFFECT_ICON.instantiate()
		fill_icon.effect = EffectData.EffectFlavors.EMPTY
		fill_icon.small = small
		fill_icon.refrect_visible = refrect_visible
		fill_icon.show_text = false
		add_child(fill_icon)

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
