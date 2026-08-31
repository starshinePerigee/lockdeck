extends Control
## This is a quick summary screen between locks on a heist

signal continue_to_next

var current_pos: int = 1

func reset(lock_in_set: int = 0) -> void:
	current_pos = lock_in_set
	$SpeedBonusLabel.visible = false
	$AnimationPlayer.play("go_%s" % lock_in_set)

func animate() -> void:
	$SpeedBonusLabel/DisplayCoin.reset()
	var timer := get_tree().create_timer(0.4)
	timer.timeout.connect(continue_to_next.emit)
	if $SpeedBonusLabel.visible:
		get_tree().create_timer(0.3).timeout.connect($SpeedBonusLabel/DisplayCoin.claim_coin)
		get_tree().create_timer(2).timeout.connect($SpeedBonusLabel/DisplayCoin.reset)
	current_pos += 1
	$AnimationPlayer.play("go_%s" % current_pos)

func _ready() -> void:
	pass

