extends Resource
class_name UserDataEvents

signal user_data_spawned(id: int, user_data: UserData)
signal user_data_despawned(id: int)
signal user_volume_changed(id: int, volume: float)

var user_data_manager: UserDataManager


func set_user_data_manager(manager: UserDataManager) -> void:
	user_data_manager = manager


func user_data_spawned_emit(id: int, user_data: UserData) -> void:
	user_data_spawned.emit(id, user_data)


func user_data_despawned_emit(id: int) -> void:
	user_data_despawned.emit(id)


func user_volume_changed_emit(id: int, volume: float) -> void:
	user_volume_changed.emit(id, volume)
