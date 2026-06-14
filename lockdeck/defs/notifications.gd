extends RefCounted
## Contains the defined data collection for the play area notifications.
class_name Notifications

static func _get_texture(n: String) -> Resource:
	var res_str = "res://assets/notifications/notif_%s.png" % [n]
	if ResourceLoader.exists(res_str):
		return load(res_str)
	else:
		return load("res://assets/notifications/notif_debug.png")

## Notification name (ie: alt text)
var notification_name: String

## The large notification texture
var texture: Resource

func _init(notification_name_: String):
	notification_name = notification_name_
	texture = _get_texture(notification_name_)


## debug
static var DEBUG := Notifications.new("debug") 

## Current pick broke
static var BREAK := Notifications.new("break")

## Lock unlocked, stage complete
static var UNLOCK := Notifications.new("unlock")

## Stage failed
static var FAILURE := Notifications.new("failure")

## Deck reloaded (vestigial)
static var RELOAD := Notifications.new("reload")