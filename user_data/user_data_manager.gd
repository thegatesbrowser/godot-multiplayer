extends Node
class_name UserDataManager

@export var user_data_spawner: UserDataSpawner
@export var user_data_events: UserDataEvents

var my_user_data: UserData
var user_datas = {} # {Peer ID: UserData}


func _ready() -> void:
	if Connection.is_server(): return
	
	user_data_events.set_user_data_manager(self)
	user_data_spawner.user_data_spawned.connect(user_data_spawned)
	user_data_spawner.user_data_despawned.connect(user_data_despawned)


func user_data_spawned(id: int, user_data: UserData) -> void:
	if id == multiplayer.get_unique_id():
		user_data.is_my_data = true
		my_user_data = user_data
	else:
		user_datas[id] = user_data
	
	user_data_events.user_data_spawned_emit(id, user_data)


func user_data_despawned(id: int) -> void:
	if id == multiplayer.get_unique_id():
		my_user_data = null
	else:
		user_datas.erase(id)
	
	user_data_events.user_data_despawned_emit(id)


func try_get_user_data(id: int) -> UserData:
	return user_datas[id] if user_datas.has(id) else null
