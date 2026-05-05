@tool
extends Control

const EFFECT_ICON = preload("res://objects/card/effect_icon.tscn")

const SIZE_SCALE = {
	true: [0, -3, -6, -8, -10],  # small
	false: [0, -15, -22, -25, -28]  # big
}

@export var effects: Array[EffectData.EffectFlavors] = []:
	set(v):
		effects = v
		_redraw()
	
@export var values: Array[int] = []:
	set(v):
		values = v
		_redraw()

@export var small := true:
	set(v):
		small = v
		_redraw()

@export var refrect_visible = true:
	set(v):
		refrect_visible = v
		_redraw()

func _redraw():
	if not is_node_ready():
		await ready
	for child in get_children():
		remove_child(child)
		child.queue_free()
	var next = null
	for i in range(len(effects)):
		next = EFFECT_ICON.instantiate()
		next.effect = effects[i]
		if i < len(values):
			next.value = int(values[i])
		else:
			next.value = 0
		next.refrect_visible = refrect_visible
		next.small = small
		next.z_index = -i
		add_child(next)
	var spacing = SIZE_SCALE[small]
	var space := 0
	if len(effects) > len(spacing):
		space = spacing[-1]
	else:
		space = spacing[len(effects) - 1]
	add_theme_constant_override("separation", space)

func _ready() -> void:
	_redraw()
