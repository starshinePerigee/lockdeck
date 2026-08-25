extends Node
## Handles queing and playing ambience as requested by bgm main

func set_play(
	player: AudioStreamPlayer,
	tween: Tween,
	make_playing: bool,
	volume: float,
	ramp_in := 5.0,
	ramp_out := 5.0
) -> Tween:
	if tween:
		tween.kill()
	var new_tween := get_tree().create_tween()
	if make_playing:
		if not player.playing:
			player.play()
		new_tween.tween_property(player, "volume_db", volume, ramp_in)
	else:
		new_tween.tween_property(player, "volume_db", -80, ramp_out)
		new_tween.tween_callback(player.stop)
	return new_tween

@onready var fire_db: float = $CracklePlayer.volume_db
var _fire_tween: Tween

func set_fire(fire_on := true) -> void:
	_fire_tween = set_play(
		$CracklePlayer, 
		_fire_tween, 
		fire_on,
		fire_db
	)

@onready var wind_db: float = $WindPlayer.volume_db
var _wind_tween: Tween

func set_wind(wind_on := true) -> void:
	_wind_tween = set_play(
		$WindPlayer,
		_wind_tween,
		wind_on,
		wind_db,
		10.0,
		8.0
	)

@onready var night_db: float = $WindPlayer.volume_db
var _night_tween: Tween

func set_night(night_on := true, volume_mod := 0.0) -> void:
	_night_tween = set_play(
		$NightPlayer, 
		_night_tween,
		night_on,
		night_db + volume_mod,
		3.0,
		8.0
	)


func title_screen() -> void:
	set_wind(true)
	
	$NightPlayer.volume_db = -30
	set_night(true)
	
	$CracklePlayer.volume_db = -60
	_fire_tween = get_tree().create_tween()
	_fire_tween.tween_interval(4)
	_fire_tween.tween_callback(set_fire.bind(true))

func start_bugs() -> void:
	set_night(true, -6.0)

func shift_bugs() -> void:
	pass

func stop_bugs() -> void:
	set_night(false, 0.0)

func _ready() -> void:
	title_screen()
	
	if get_tree().current_scene == self:
		var timer := get_tree().create_timer(10.0)
		timer.timeout.connect(start_bugs)
