extends Control

var is_in_game: bool


func _ready() -> void:
	visibility_changed.connect(on_visibility_changed)
	on_visibility_changed()


func _input(_event: InputEvent) -> void:
	if not is_in_game: return
	
	if Input.is_action_just_pressed("show_mouse"): set_captured(false)
	if Input.is_action_just_released("show_mouse"): set_captured(true)


func on_visibility_changed() -> void:
	if is_visible_in_tree():
		set_captured(true)
		is_in_game = true
	else:
		set_captured(false)
		is_in_game = false


func _notification(what: int) -> void:
	match what:
		MainLoop.NOTIFICATION_APPLICATION_FOCUS_IN:
			if is_visible_in_tree(): set_captured(true)
		MainLoop.NOTIFICATION_APPLICATION_FOCUS_OUT:
			pass


func set_captured(captured: bool) -> void:
	if captured:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	else:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
