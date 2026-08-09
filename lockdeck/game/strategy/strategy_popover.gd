extends PanelContainer
class_name StrategyPopover

@export var title := "POPOVER HEADER"

func get_inside_node() -> Control:
	return %CenterContainer.get_child(0)

func _ready() -> void:
	%TitleLabel.text = title
	
	if get_child_count() <= 1:
		push_error("%s missing child node!" % self)
		return
	
	var node: Node = get_child(1)
	remove_child(node)
	%CenterContainer.add_child(node)
