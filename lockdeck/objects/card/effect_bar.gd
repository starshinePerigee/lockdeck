extends HBoxContainer
## A full horizontal collection of effect stacks for a pick card
## Has logic for spacing and drawing

# spacing between items (i is number on one side)
const SIZE_SCALE := [0, -15, -25, -35, -40, -45, -50, -50]

# Dictionary of pin_index_offset: Array[EffectSpec)
@export var effect_stacks: Dictionary[int, Array]

func redraw() -> void:
	for child in get_children():
		remove_child(child)
		child.queue_free()
	
	if len(effect_stacks) == 0:
		return

	var lowest: int = min(0, effect_stacks.keys().min())
	var highest: int = max(0, effect_stacks.keys().max())
	var dist = max(-lowest, highest)
	
	# iterate from -dist to dist for centering purposes (bad hack alert lol)
	for i in range(-dist, dist + 1):
		# fill only if you're in the actual range
		var fill := i not in effect_stacks and i >= lowest and i <= highest
		# use big icons if you're the only effect on the card
		# might cut this?
		var small := len(effect_stacks) != 1
		
		var effect_stack: Array[EffectSpec] = []
		if i in effect_stacks:
			effect_stack.assign(effect_stacks[i])
		
		var stack := EffectStack.build(effect_stack, small, fill)
		add_child(stack)
	
	add_theme_constant_override("separation", SIZE_SCALE[dist])
