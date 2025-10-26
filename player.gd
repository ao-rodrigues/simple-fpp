extends CharacterBody3D

const PITCH_MAX: float = 89.0
const PITCH_MIN: float = -89.0

@export var look_sensitivity: float = 0.2

@export var base_speed: float = 10.0
@export var sprint_multiplier: float = 1.3

var _mouse_captured: bool

var _yaw: float
var _pitch: float

@onready var _camera: Camera3D = $CameraPivot/Camera
@onready var _camera_pivot: Node3D = $CameraPivot

func _ready() -> void:
	_capture_mouse()
	
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		var look_dir = event.relative
		if _mouse_captured: _rotate_camera(look_dir)

func _physics_process(delta: float) -> void:
	_handle_movement(delta)

func _capture_mouse() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	_mouse_captured = true
	
func _release_mouse() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	_mouse_captured = false
	
func _rotate_camera(look_dir: Vector2) -> void:
	_yaw = fmod(_yaw - look_dir.x * look_sensitivity, 360)
	_pitch = clamp(_pitch - look_dir.y * look_sensitivity, PITCH_MIN, PITCH_MAX)
	
	_camera_pivot.rotation.y = deg_to_rad(_yaw)
	_camera.rotation.x = deg_to_rad(_pitch)

func _handle_movement(delta: float) -> void:
	var look_dir: Vector3 = _camera.get_camera_transform().basis.z
