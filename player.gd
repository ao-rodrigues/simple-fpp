extends CharacterBody3D

const PITCH_MIN: float = -1.5
const PITCH_MAX: float = 1.5

@export_range(1, 35, 1) var base_speed: float = 10
@export_range(10, 400, 1) var acceleration: float = 100
@export var sprint_multiplier: float = 1.3

@export_range(0.1, 3.0, 0.1, "or_greater") var camera_sensitivity: float = 1
@export_range(0.001, 0.01, 0.001) var mouse_camera_sensitivity_modifier: float = 0.001

var _mouse_captured: bool
var _look_dir: Vector2
var _walk_vel: Vector3

@onready var _camera: Camera3D = $CameraPivot/Camera
@onready var _camera_pivot: Node3D = $CameraPivot

func _ready() -> void:
	_capture_mouse()
	
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		_look_dir = event.relative
		if _mouse_captured: 
			_rotate_camera(mouse_camera_sensitivity_modifier)
	if Input.is_action_pressed(&"capture_mouse"):
		_capture_mouse()
	if Input.is_action_pressed(&"release_mouse"):
		_release_mouse()
	if Input.is_action_pressed(&"exit"):
		get_tree().quit()

func _physics_process(delta: float) -> void:
	if _mouse_captured:
		_handle_joypad_camera_rotation(delta)

	velocity = _walk(delta)
	move_and_slide()

func _capture_mouse() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	_mouse_captured = true

func _release_mouse() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	_mouse_captured = false
	
func _handle_joypad_camera_rotation(delta: float) -> void:
	var joypad_dir: Vector2 = Input.get_vector(&"look_left", &"look_right", &"look_up", &"look_down")
	if joypad_dir.length() > 0:
		_look_dir += joypad_dir * delta
		_rotate_camera()
		_look_dir = Vector2.ZERO
	
func _rotate_camera(sensitivity_modifier: float = 1) -> void:
	_look_dir *= sensitivity_modifier
	_camera_pivot.rotation.y -= _look_dir.x * camera_sensitivity
	_camera.rotation.x = clamp(_camera.rotation.x - _look_dir.y * camera_sensitivity, PITCH_MIN, PITCH_MAX)

func _walk(delta: float) -> Vector3:
	var move_dir: Vector2 = Input.get_vector(&"move_left", &"move_right", &"move_forward", &"move_backwards")

	var forward: Vector3 = _camera.global_transform.basis * Vector3(move_dir.x, 0, move_dir.y)
	var walk_dir: Vector3 = Vector3(forward.x, 0, forward.z).normalized()

	var speed: float = base_speed
	if Input.is_action_pressed(&"sprint"):
		speed *= sprint_multiplier

	_walk_vel = _walk_vel.move_toward(walk_dir * speed * move_dir.length(), acceleration * delta)
	return _walk_vel
