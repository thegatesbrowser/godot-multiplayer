extends MultiplayerSpawner
class_name PlayerSpawner

signal player_spawned(id: int, player: Player)
signal player_despawned(id: int)

@export var player_scene: PackedScene
@export var spawn_points: SpawnPoints


func _ready() -> void:
	spawn_function = custom_spawn
	multiplayer.peer_connected.connect(create_player)
	multiplayer.peer_disconnected.connect(destroy_player)
	spawned.connect(on_spawned)
	despawned.connect(on_despawned)


func create_player(id: int):
	if not multiplayer.is_server(): return
	
	var spawn_position = spawn_points.get_spawn_position()
	spawn([id, spawn_position])
	print("Player %d spawned at " % [id] + str(spawn_position))


func destroy_player(id: int):
	if not multiplayer.is_server(): return
	get_node(spawn_path).get_node(str(id)).queue_free()
	
	player_despawned.emit(id)


func respawn_player(id: int) -> void:
	var player = get_node(spawn_path).get_node(str(id)) as Player
	var spawn_position = spawn_points.get_spawn_position()
	player.respawn.rpc_id(id, spawn_position)
	print("Respawn player %d at " % [id] + str(spawn_position))


func custom_spawn(vars) -> Node:
	var id = vars[0]
	var pos = vars[1]
	
	var p: Player = player_scene.instantiate()
	p.set_multiplayer_authority(id)
	p.name = str(id)
	p.position = pos
	
	player_spawned.emit(id, p)
	return p


func get_player_or_null(id: int) -> Player:
	return get_node(spawn_path).get_node_or_null(str(id))


func on_spawned(node: Node) -> void:
	player_spawned.emit(node.get_multiplayer_authority(), node)


func on_despawned(node: Node) -> void:
	player_despawned.emit(node.get_multiplayer_authority())
