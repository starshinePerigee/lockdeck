extends HBoxContainer
## A full horizontal collection of effect stacks for a pick card
## Has logic for spacing and drawing

# Dictionary of pin_index_offset: Array[EffectSpec)
@export var effect_stacks: Dictionary[int, Array]

func redraw() -> void:
	for child in get_children():
		remove_child(child)
		child.queue_free()
	
	if len(effect_stacks) == 0:
		return
	
	for i in range(3, -2, -1):
		# use big icons if you're the only effect on the card
		# might cut this?
		
		var effect_stack: Array[EffectSpec] = []
		if i in effect_stacks:
			effect_stack.assign(effect_stacks[i])
		
		var stack := EffectStack.build(effect_stack)
		add_child(stack)