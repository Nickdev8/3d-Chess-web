extends Node3D

@export var rotation_speed: Vector2 = Vector2(0.01, 0.01)  # yaw/pitch speed
@export var min_pitch: float     = -80.0
@export var max_pitch: float     =  80.0

@export var zoom_speed: float    = 1.0   # units per wheel tick
@export var min_distance: float  = 2.0
@export var max_distance: float  = 20.0
@export var Start_distance: float  = 10.0

@export var pan_speed: float     = 0.005  # tweak to taste

var yaw: float   = 0.0
var pitch: float = 0.0
@onready var camera: Camera3D = $Camera3D

func _ready() -> void:
	pitch = rotation.x
	yaw = rotation.y
	camera.position.z = Start_distance
	camera.position.z = clamp(camera.position.z, min_distance, max_distance)

func _unhandled_input(event: InputEvent) -> void:
	# — Rotate on LMB drag —
	if event is InputEventMouseMotion and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		yaw   -= event.relative.x * rotation_speed.x
		pitch -= event.relative.y * rotation_speed.y
		pitch = clamp(pitch, deg_to_rad(min_pitch), deg_to_rad(max_pitch))
		rotation = Vector3(pitch, yaw, 0)

	# — Zoom on scroll —
	elif event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			camera.position.z = clamp(camera.position.z - zoom_speed,
									  min_distance, max_distance)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			camera.position.z = clamp(camera.position.z + zoom_speed,
									  min_distance, max_distance)

	# — Pan on RMB drag —
	elif event is InputEventMouseMotion and Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
		 #get the camera’s global basis
		var b = camera.global_transform.basis
		# move opposite X for horizontal, and Y for vertical
		var pan_delta = (-b.x * event.relative.x + b.y * event.relative.y) * pan_speed
		global_position += pan_delta
