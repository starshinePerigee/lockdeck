extends Control
## This is a quick summary screen between locks on a heist

signal continue_to_next

var current_pos: int = 1

func reset(lock_in_set: int = 0) -> void:
	current_pos = lock_in_set
	$SpeedBonusLabel.visible = false
	$AnimationPlayer.play("go_%s" % lock_in_set, -1, 1000)
	_has_played = false

const FX_COIN_GET := preload("res://assets/fx/coin_claim.ogg")
const FX_DRAW_X := preload("res://assets/fx/draw_scratch.ogg")
var _has_played := false

func play_chime():
	if _has_played:
		GlobalEffects.request(FX_DRAW_X)
	else:
		# horrible hack to the logic on betweens
		_has_played = true

func animate() -> void:
	$SpeedBonusLabel/DisplayCoin.reset()
	var timer := get_tree().create_timer(1.1)
	timer.timeout.connect(continue_to_next.emit)
	if $SpeedBonusLabel.visible:
		var claim_tween := create_tween()
		claim_tween.tween_interval(0.3667)
		claim_tween.tween_callback($SpeedBonusLabel/DisplayCoin.claim_coin)
		claim_tween.tween_callback(GlobalEffects.request.bind(FX_COIN_GET))
		claim_tween.tween_interval(2)
		claim_tween.tween_callback($SpeedBonusLabel/DisplayCoin.reset)
	current_pos += 1
	$AnimationPlayer.play("go_%s" % current_pos)

func _ready() -> void:
	pass

