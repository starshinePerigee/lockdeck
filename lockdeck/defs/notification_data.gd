class_name NotificationData
## Contains the defined data collection for the play area notifications.
extends Object

#region base class
class NotificationDef:
	static func _get_texture(n: String) -> Resource:
		var res_str = "res://assets/notifications/notif_%s.png" % [n]
		if ResourceLoader.exists(res_str):
			return load(res_str)
		else:
			return load("res://assets/notifications/notif_debug.png")
	
	## The large notification texture
	var texture:Resource
	
	func _init(name: String):
		self.texture = _get_texture(name)
#endregion

#region global instances
# the order must match the order of the declaration, below
enum NotificationFlavors {
	DEBUG,  ## DEBUG
	BREAK,  ## Current pick broke
	UNLOCK,  ## Lock unlocked, stage complete
	FAILURE,  ## Stage failed
	RELOAD  ## Deck reloaded (vestigial)
}

static var _defs: Array[NotificationDef] = []

static func _get_def() -> Array[NotificationDef]:
	if _defs.is_empty():
		_defs = [
			NotificationDef.new("debug"),
			NotificationDef.new("break"),
			NotificationDef.new("unlock"),
			NotificationDef.new("failure"),
			NotificationDef.new("reload"),
		]
		assert(len(_defs) == len(NotificationFlavors), "Hey dipshit update the enum")
		print("Loaded %s notifications" % len(_defs))
	return _defs

## Gets a live NotificationDef object given an NotificationFlavors enum value.
static func get_def(notification_: NotificationFlavors) -> NotificationDef:
	return _get_def()[notification_]
#endregion
