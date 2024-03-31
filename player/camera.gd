extends Camera3D


func _ready() -> void:
	if is_multiplayer_authority():
		make_current()
	else:
		clear_current(false)
