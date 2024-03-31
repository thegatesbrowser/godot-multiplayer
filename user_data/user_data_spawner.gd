extends MultiplayerSpawner
class_name UserDataSpawner

signal user_data_spawned(id: int, user_data: UserData)
signal user_data_despawned(id: int)

@export var user_data_scene: PackedScene


func _ready() -> void:
	spawn_function = custom_spawn
	multiplayer.peer_connected.connect(create_user_data)
	multiplayer.peer_disconnected.connect(destroy_user_data)
	spawned.connect(on_spawned)
	despawned.connect(on_despawned)


func create_user_data(id: int):
	if not multiplayer.is_server(): return
	spawn([id])


func destroy_user_data(id: int):
	if not multiplayer.is_server(): return
	get_node(spawn_path).get_node(str(id)).queue_free()


func custom_spawn(vars) -> Node:
	var id = vars[0]
	
	var u: UserData = user_data_scene.instantiate() as UserData
	u.set_multiplayer_authority(id)
	u.name = str(id)
	u.id = id
	return u


func get_user_data_or_null(id: int) -> UserData:
	return get_node(spawn_path).get_node_or_null(str(id))


func on_spawned(node: Node) -> void:
	user_data_spawned.emit(node.get_multiplayer_authority(), node)


func on_despawned(node: Node) -> void:
	user_data_despawned.emit(node.get_multiplayer_authority())
