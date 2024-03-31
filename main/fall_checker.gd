extends Node
class_name FallChecker

@export var fall_height: float
@export var player_spawner: PlayerSpawner

var timer : Timer
var players = {} # {Peer ID: Player}


func _ready() -> void:
	if not Connection.is_server(): return
	
	timer = Timer.new()
	add_child(timer)
	timer.start(1)
	timer.timeout.connect(check_fallen)
	
	player_spawner.player_spawned.connect(player_spawned)
	player_spawner.player_despawned.connect(player_despawned)


func player_spawned(id: int, player: Player) -> void:
	players[id] = player


func player_despawned(id: int) -> void:
	players.erase(id)


func check_fallen() -> void:
	for id in players.keys():
		var player = players[id] as Player
		if player.global_position.y < fall_height:
			player_spawner.respawn_player(id)
