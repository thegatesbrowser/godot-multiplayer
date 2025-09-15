extends AudioStreamPlayer
class_name Microphone

static var is_speaking: bool

var speak_action: StringName = "speak"


func _process(_delta: float) -> void:
	if not Input.is_action_pressed(speak_action) or EditMode.is_enabled:
		set_speaking(false)


func _unhandled_input(event: InputEvent) -> void:
	if EditMode.is_enabled: return
	
	if event.is_action_pressed(speak_action):
		set_speaking(true)
	
	if event.is_action_released(speak_action):
		set_speaking(false)


func set_speaking(speaking: bool) -> void:
	if speaking == is_speaking: return
	is_speaking = speaking


func _exit_tree() -> void:
	set_speaking(false)
