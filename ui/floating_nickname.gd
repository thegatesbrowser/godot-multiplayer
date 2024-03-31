extends Control

@export var user_data_events: UserDataEvents
@export var label: Label
@export var speaking_indicator: Control
@export var anchor: Node3D
@export var offset: Vector3

var camera: Camera3D
var user_data: UserData


func _ready() -> void:
	if Connection.is_server() or is_multiplayer_authority():
		set_visible(false)
		set_process(false)
		return
	
	var id = get_multiplayer_authority()
	var _user_data = user_data_events.user_data_manager.try_get_user_data(id)
	if is_instance_valid(_user_data):
		retrieve_user_data(id, _user_data)
	else:
		user_data_events.user_data_spawned.connect(retrieve_user_data)


func _process(_delta: float) -> void:
	camera = get_viewport().get_camera_3d()
	if not is_instance_valid(camera): return
	
	var anchor_pos = anchor.global_position + offset
	visible = not camera.is_position_behind(anchor_pos)
	position = camera.unproject_position(anchor_pos)


func retrieve_user_data(id: int, _user_data: UserData) -> void:
	if id != get_multiplayer_authority(): return
	
	user_data = _user_data
	user_data.nickname_changed.connect(nickname_changed)
	user_data.speaking_changed.connect(speaking_changed)
	nickname_changed(user_data.nickname)
	speaking_changed(user_data.speaking)


func nickname_changed(nickname: String) -> void:
	label.text = nickname


func speaking_changed(speaking: bool) -> void:
	speaking_indicator.visible = speaking
