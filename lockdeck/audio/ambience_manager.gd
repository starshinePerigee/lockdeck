extends Node
## Handles queing and playing ambience as requested by bgm main

@onready var fire_db: float = $CracklePlayer.volume_db
var _fire_tween: Tween

func set_fire(fire_on := true) -> void:
	if _fire_tween:
		_fire_tween.kill()
	_fire_tween = get_tree().create_tween()
	if fire_on:
		if not $CracklePlayer.playing:
			$CracklePlayer.play()
		_fire_tween.tween_property($CracklePlayer, "volume_db", fire_db, 5.0)
	else:
		_fire_tween.tween_property($CracklePlayer, "volume_db", -80, 5.0)
		_fire_tween.tween_callback($CracklePlayer.stop)


@onready var wind_db: float = $WindPlayer.volume_db
var _wind_tween: Tween

func set_wind(wind_on := true) -> void:
	if _wind_tween:
		_wind_tween.kill()
	_wind_tween = get_tree().create_tween()
	if wind_on:
		if not $WindPlayer.playing:
			$WindPlayer.play()
		_wind_tween.tween_property($WindPlayer, "volume_db", wind_db, 10.0)
	else:
		_wind_tween.tween_property($WindPlayer, "volume_db", -80, 8.0)
		_wind_tween.tween_callback($WindPlayer.stop)

func title_screen() -> void:
	set_wind(true)
	$CracklePlayer.volume_db = -60
	_fire_tween = get_tree().create_tween()
	_fire_tween.tween_interval(4)
	_fire_tween.tween_callback(set_fire.bind(true))

func _ready() -> void:
	title_screen()