extends CharacterBody3D

const PITCH_MAX: float = 89.0
const PITCH_MIN: float = -89.0

@export var look_sensitivity : float = 0.2

var _mouse_captured: bool = false

var _yaw : float = 0
var _pitch: float = 0

@onready var _camera : Camera3D = $CameraPivot/Camera
@onready var _camera_pivot : Node3D = $CameraPivot


func _ready() -> void:
	_capture_mouse()


func _unhandled_input(event: InputEvent) -> void:
	_check_mouse_capture(event)
	
	if not _mouse_captured:
		return
		
	_move_camera(event)	


func _check_mouse_capture(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MouseButton.MOUSE_BUTTON_LEFT and event.pressed:
			_capture_mouse()
	elif event is InputEventKey:
		if event.keycode == Key.KEY_ESCAPE and event.pressed:
			_release_mouse()


func _capture_mouse() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	_mouse_captured = true


func _release_mouse() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	_mouse_captured = false


func _move_camera(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		_yaw = fmod(_yaw - event.relative.x * look_sensitivity, 360)
		_pitch = clamp(_pitch - event.relative.y * look_sensitivity, PITCH_MIN, PITCH_MAX)
		
		_camera_pivot.rotation.y = deg_to_rad(_yaw)
		_camera.rotation.x = deg_to_rad(_pitch)
