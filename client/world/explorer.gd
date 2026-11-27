extends CharacterBody2D

signal move_requested(direction: Vector2)

const SPEED := 144.0
const RADIUS := 10.0

@onready var _visual: Node2D = $Figure
@onready var _camera: Camera2D = $Camera2D

var authoritative := false

var _bounds: Rect2
var _animation_time := 0.0
var _network_walk_until := 0

func configure_bounds(bounds: Rect2) -> void:
	_bounds = bounds
	_camera.limit_left = int(bounds.position.x)
	_camera.limit_top = int(bounds.position.y)
	_camera.limit_right = int(bounds.end.x)
	_camera.limit_bottom = int(bounds.end.y)

func apply_confirmed_position(confirmed: Vector2) -> void:
	if not confirmed.is_equal_approx(position):
		_network_walk_until = Time.get_ticks_msec() + 150
	position = confirmed

func _physics_process(delta: float) -> void:
	var direction := Input.get_vector("walk_left", "walk_right", "walk_up", "walk_down")
	var walking: bool
	if authoritative:
		move_requested.emit(direction)
		walking = Time.get_ticks_msec() < _network_walk_until
	else:
		velocity = direction * SPEED
		move_and_slide()
		if _bounds.has_area():
			var margin := Vector2.ONE * RADIUS
			position = position.clamp(_bounds.position + margin, _bounds.end - margin)
		walking = get_real_velocity().length_squared() > 1.0

	_animation_time += delta
	_visual.position.y = roundf(sin(_animation_time * (14.0 if walking else 4.0)))
	if direction.x != 0.0:
		_visual.scale.x = signf(direction.x)
