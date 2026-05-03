extends Area2D

class_name Car
@export var max_speed: float = 380.0
@export var friction: float = 300.0
@export var acceleration: float = 150.0
@export var steer_strength: float = 2.0
@export var min_steer_factor: float = 0.5
@export var bounce_time: float = 0.8
@export var bounce_force: float = 30.0


var _throttle: float = 0.0
var _steer: float = 0.0
var _velocity: float = 0.0
var _verifications_count: int = 0
var _verifications_passed: Array[int] = []
var _lap_timer: float = 0.0
var _is_timing: bool = false
var _lap_count: int = 0
var _is_race_finished: bool = false
var _player_id: int = 1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass 

func setup(vc: int) -> void:
	_verifications_count = vc
	pass
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if _is_race_finished:
		return
		
	_throttle = Input.get_action_strength("ui_up")
	_steer = Input.get_axis("ui_left", "ui_right")
	
	if _is_timing:
		_lap_timer += delta
	
func _physics_process(delta: float) -> void:
	if _is_race_finished:
		return
		
	apply_throttle(delta)
	apply_rotation(delta)
	position += transform.x * _velocity * delta
	
func apply_throttle(delta: float) -> void:
	if _throttle > 0.0:
		_velocity += acceleration * delta
	else:
		_velocity -= friction * delta
		
	_velocity = clampf(_velocity, 0.0, max_speed)
		
func get_steer_factor() -> float:
	return clamp(
		1.0 - pow(_velocity / max_speed, 2.0),
		min_steer_factor,
		1.0
	) * steer_strength
		
		
func apply_rotation(delta:float) -> void:
	rotate(steer_strength * delta * _steer)
	
	
func bounce() -> void:
	if _is_race_finished:
		return
		
	set_physics_process(false)
	_velocity = 0.0
	position += -transform.x * bounce_force
	await get_tree().create_timer(bounce_time).timeout
	set_physics_process(true)
	
func hit_boundary() -> void:
	bounce()
	
	
func lap_completed() -> void:
	if _is_race_finished:
		return
		
	if _verifications_count == _verifications_passed.size():
		_lap_count += 1
		var formatted_time = _format_time(_lap_timer)
		print("Lap %d completed for Car %d - Time: %s" % [_lap_count, _player_id, formatted_time])
		
		if _lap_count >= 3:
			finish_race()
		else:
			# Reset timer for next lap
			_lap_timer = 0.0
			_is_timing = true
		
	_verifications_passed.clear()

func hit_verification(verification_id: int) -> void:
	if _is_race_finished:
		return
		
	if verification_id not in _verifications_passed:
		_verifications_passed.append(verification_id)
		pass

func start_timing() -> void:
	_is_timing = true
	_lap_timer = 0.0

func set_player_id(id: int) -> void:
	_player_id = id

func finish_race() -> void:
	_is_race_finished = true
	_is_timing = false
	_throttle = 0.0
	_steer = 0.0
	_velocity = 0.0
	print("Car %d has finished the race!" % _player_id)
	
	# Notify the track that this car finished
	var track = get_tree().root.get_node_or_null("Track")
	if track and track.has_method("car_finished"):
		track.car_finished(_player_id)

func _format_time(seconds: float) -> String:
	var minutes = floor(seconds / 60)
	var remaining_seconds = seconds - (minutes * 60)
	var milliseconds = floor((remaining_seconds - floor(remaining_seconds)) * 1000)
	return "%02d:%02d.%03d" % [minutes, floor(remaining_seconds), milliseconds]
	
func is_race_finished() -> bool:
	return _is_race_finished
