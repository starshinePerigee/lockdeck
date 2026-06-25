extends Control
## A vertical stack of multiple card effect icons
## Has logic for drawing multiple different EffectSpecs
class_name EffectStack


const SIZE_SCALE := {
	true: -8,  # small
	false: -12,  # big
}

## Array of effect specs to draw for this column
@export var effects: Array[EffectSpec]

## If small icons should be used. (Cards use small icons)
@export var small: bool

func redraw() -> void:
	for child in get_children():
		remove_child(child)
		child.queue_free()
	
	for s in effects.size():
		var spec: EffectSpec = effects[s]
		var count: int = max(1, spec.value)
		
		for j in count:
			var show_text := j == spec.value - 1 or spec.value == 0
			var icon := EffectIcon.build(spec.flavor, small, spec.value, show_text)
			icon.z_index = j - 5 * s
			add_child(icon)
		
		# hidden spacer between effect groups
		add_child(EffectIcon.build(Effects.BLANK, small))
	
	add_theme_constant_override("separation", SIZE_SCALE[small])

const SELF_PACKED := preload("res://objects/card/effect_stack.tscn")

## Create a new instantiated instance from data
static func build(
	effects_: Array[EffectSpec],
	small_: bool = false,
) -> Node:
	var n := SELF_PACKED.instantiate()
	n.effects = effects_
	n.small = small_
	n.redraw()
	return n
