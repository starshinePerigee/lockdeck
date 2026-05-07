@tool
extends Control

const EFFECT_STACK = preload("res://objects/card/effect_stack.tscn")
const SIZE_SCALE = [0, -15, -25, -30, -30, -30, -30, -30]

@export var effect_stacks: Dictionary[int, Array] = {}:
	set(v):
		for stack in effect_stacks.values():
			for spec in stack:
				if spec.changed.is_connected(_redraw):
					spec.changed.disconnect(_redraw)

		effect_stacks = v

		# rebuild because i guess that's necessary??
		for key in effect_stacks.keys():
			var rebuild: Array[EffectSpec] = []
			for j in len(effect_stacks[key]):
				if effect_stacks[key][j] == null:
					rebuild.append(EffectSpec.new())
				else:
					rebuild.append(effect_stacks[key][j])
			effect_stacks[key] = rebuild

		for stack in effect_stacks.values():
			for spec in stack:
				if not spec.changed.is_connected(_redraw):
					spec.changed.connect(_redraw)
		_redraw()

@export var refrect_visible = true:
	set(v):
		refrect_visible = v
		if not is_node_ready():
			await ready
		$ReferenceRect.visible = refrect_visible
		_redraw()

func _redraw() -> void:
	if not is_node_ready():
		await ready
	for child in $StackHBox.get_children():
		$StackHBox.remove_child(child)
		child.queue_free()
	
	if len(effect_stacks) == 0:
		return

	var lowest: int = min(0, effect_stacks.keys().min())
	var highest: int = max(0, effect_stacks.keys().max())
	var dist = max(-lowest, highest)
	
	for k in range(-dist, dist + 1):
		var stack = EFFECT_STACK.instantiate()
		if k in effect_stacks:
			stack.effects = effect_stacks[k]
		
		if k == 0:
			stack.small = false
			stack.fill = true
		elif k < 0 and k > lowest:
			stack.fill = true
		elif k > 0 and k < highest:
			stack.fill = true
			
		stack.refrect_visible = refrect_visible
		$StackHBox.add_child(stack)
	
	$StackHBox.add_theme_constant_override("separation", SIZE_SCALE[dist])
			
