extends CharacterBody3D

const PITCH_MAX: float = 89.0
const PITCH_MIN: float = -89.0

@export var look_sensitivity: float = 0.2

@export var base_speed: float = 10.0
@export var sprint_multiplier: float = 1.3
@export var acceleration: float = 100

var _mouse_captured: bool

var _look_dir: Vector2
var _camera_yaw: float
var _camera_pitch: float

var _walk_vel: Vector3

@onready var _camera: Camera3D = $CameraPivot/Camera
@onready var _camera_pivot: Node3D = $CameraPivot

func _ready() -> void:
	_capture_mouse()
	
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		_look_dir = event.relative
		if _mouse_captured: _rotate_camera()
		
func _physics_process(delta: float) -> void:
	if _mouse_captured:
		_handle_joypad_camera_rotation(delta)

	velocity = _walk(delta)
	move_and_slide()

func _capture_mouse() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	_mouse_captured = true
	
func _handle_joypad_camera_rotation(delta: float) -> void:
	var joypad_dir: Vector2 = Input.get_vector(&"look_left", &"look_right", &"look_up", &"look_down")
	if joypad_dir.length() > 0:
		_look_dir += joypad_dir * delta
		_rotate_camera()
		_look_dir = Vector2.ZERO
	
func _rotate_camera() -> void:
	_camera_yaw = fmod(_camera_yaw - _look_dir.x * look_sensitivity, 360)
	_camera_pitch = clamp(_camera_pitch - _look_dir.y * look_sensitivity, PITCH_MIN, PITCH_MAX)
	
	_camera_pivot.rotation.y = deg_to_rad(_camera_yaw)
	_camera.rotation.x = deg_to_rad(_camera_pitch)

func _walk(delta: float) -> Vector3:
	var move_dir: Vector2 = Input.get_vector(&"move_left", &"move_right", &"move_forward", &"move_backwards")

	var forward: Vector3 = _camera.global_transform.basis * Vector3(move_dir.x, 0, move_dir.y)
	var walk_dir: Vector3 = Vector3(forward.x, 0, forward.z).normalized()

	var speed: float = base_speed
	if Input.is_action_pressed(&"sprint"):
		speed *= sprint_multiplier

	_walk_vel = _walk_vel.move_toward(walk_dir * speed * move_dir.length(), acceleration * delta)
	return _walk_vel
