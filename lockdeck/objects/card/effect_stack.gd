extends Control
## A vertical stack of multiple card effect icons
## Has logic for drawing multiple different EffectSpecs
class_name EffectStack


const ICON_SEPARATION := -12

## Array of effect specs to draw for this column
@export var effects: Array[EffectSpec]

func redraw() -> void:
	for child in get_children():
		remove_child(child)
		child.queue_free()
	
	for s in effects.size():
		var spec: EffectSpec = effects[s]
		var count: int = max(1, spec.value)
		
		for j in count:
			var show_text := j == spec.value - 1 or spec.value == 0
			var icon := EffectIcon.build(spec.flavor, spec.value, show_text)
			icon.z_index = j - 5 * s
			add_child(icon)
		
		# hidden spacer between effect groups
		add_child(EffectIcon.build(Effects.BLANK))
	
	add_theme_constant_override("separation", ICON_SEPARATION)

const SELF_PACKED := preload("res://objects/card/effect_stack.tscn")

## Create a new instantiated instance from data
static func build(
	effects_: Array[EffectSpec],
) -> Node:
	var n := SELF_PACKED.instantiate()
	n.effects = effects_
	n.redraw()
	return n
