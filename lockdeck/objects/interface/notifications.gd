extends VBoxContainer

var notifications: Array[Notifications] = []

func notify(notif: Notifications):
	notifications.append(notif)

	if not is_node_ready():
		await ready

	var next := TextureRect.new()
	next.texture = notif.texture
	next.custom_minimum_size = Vector2(1000, 150)
	add_child(next)

func clear():
	notifications.clear()

	if not is_node_ready():
		await ready

	for child in get_children():
		remove_child(child)
		child.queue_free()
