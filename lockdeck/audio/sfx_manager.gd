extends Node

var _loop: Tween

func start_fx() -> void:
	stop_fx()
	_loop = create_tween()
	_loop.set_loops()
	_loop.tween_callback($SettingsFX.play)
	_loop.tween_interval(0.08)
	_loop.tween_callback($SettingsFX.play)
	_loop.tween_interval(0.08)
	_loop.tween_callback($SettingsFX.play)
	_loop.tween_interval(0.5)

func stop_fx() -> void:
	if _loop:
		_loop.kill()