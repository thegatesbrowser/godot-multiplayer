extends Control
class_name PlayerPanel

@export var nickname_edit: LineEdit
@export var volume_slider: HSlider
@export var speaking_indicator: Control
@export var animation_player: AnimationPlayer
@export var user_data_events: UserDataEvents

var user_data: UserData


func _ready() -> void:
	user_data.nickname = nickname_edit.text
	speaking_indicator.visible = false
	
	nickname_edit.text_submitted.connect(text_submitted)
	volume_slider.value_changed.connect(volume_changed)


func text_submitted(nickname: String) -> void:
	user_data.nickname = nickname


func volume_changed(volume: float) -> void:
	user_data_events.user_volume_changed_emit(user_data.id, volume)


func set_user_data(_user_data: UserData) -> void:
	user_data = _user_data
	if user_data.is_my_data: animation_player.play("my_panel")
	
	user_data.nickname_changed.connect(nickname_changed)
	user_data.speaking_changed.connect(speaking_changed)


func nickname_changed(nickname: String) -> void:
	nickname_edit.text = nickname


func speaking_changed(speaking: bool) -> void:
	speaking_indicator.visible = speaking
