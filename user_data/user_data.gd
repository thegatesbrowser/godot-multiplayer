extends Node
class_name UserData

signal speaking_changed(speaking: bool)
signal nickname_changed(nickname: String)

@export var speaking: bool:
	set(value):
		speaking = value
		speaking_changed.emit(value)

@export var nickname: String:
	set(value):
		nickname = value
		nickname_changed.emit(value)

var is_my_data: bool
var id: int


func _process(_delta: float) -> void:
	if not is_multiplayer_authority(): return

	if speaking != Microphone.is_speaking:
		speaking = Microphone.is_speaking
