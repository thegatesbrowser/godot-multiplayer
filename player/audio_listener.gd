extends AudioListener3D

@onready var _pivot: Node3D = $"../CameraController"


func _ready() -> void:
	if is_multiplayer_authority():
		make_current()
	else:
		clear_current()


func _process(_delta: float) -> void:
	rotation_degrees = _pivot.rotation_degrees
	rotation_degrees.y += 180
