extends PanelContainer

@export var title := "POPOVER HEADER"

func _ready() -> void:
	var node: Node = get_child(1)
	remove_child(node)
	%CenterContainer.add_child(node)
	%TitleLabel.text = title