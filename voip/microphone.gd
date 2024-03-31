extends AudioStreamPlayer
class_name Microphone

static var is_speaking: bool

var speak_action: StringName = "speak"


func _process(_delta: float) -> void:
	if not Input.is_action_pressed(speak_action) or EditMode.is_enabled:
		is_speaking = false


func _unhandled_input(event: InputEvent) -> void:
	if EditMode.is_enabled: return
	
	if event.is_action_pressed(speak_action):
		is_speaking = true
	
	if event.is_action_released(speak_action):
		is_speaking = false


func _exit_tree() -> void:
	is_speaking = false
