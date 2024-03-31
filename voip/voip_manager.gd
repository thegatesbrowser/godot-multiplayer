extends Node

@export var user_scn: PackedScene
@export var player_spawner: PlayerSpawner

var mic_capture: VOIPInputCapture
var users = {} # {Peer ID: VoipUser}


func _ready() -> void:
	if Connection.is_server(): return
	
	multiplayer.peer_connected.connect(peer_connected)
	multiplayer.peer_disconnected.connect(peer_disconnected)
	player_spawner.player_spawned.connect(player_spawned)
	
	var mic_bus = AudioServer.get_bus_index("Record")
	mic_capture = AudioServer.get_bus_effect(mic_bus, 0)
	mic_capture.packet_ready.connect(voice_packet_ready)


func peer_connected(id: int) -> void:
	if id == 1: return
	
	var user = user_scn.instantiate() as VoipUser
	user.set_user_id(id)
	users[id] = user
	add_child(user, true)
	print("Voip user added ", id)
	
	var player = player_spawner.get_player_or_null(id)
	if is_instance_valid(player): user.set_anchor(player)


func peer_disconnected(id: int) -> void:
	if id == 1: return
	
	users[id].queue_free()
	users.erase(id)
	print("Voip user removed ", id)


func player_spawned(id: int, player: Player) -> void:
	if users.has(id): users[id].set_anchor(player)


func voice_packet_ready(packet: PackedByteArray) -> void:
	if not Microphone.is_speaking: return
	if Connection.is_peer_connected:
		rpc("voice_packet_received", packet)


@rpc("any_peer", "call_remote", "unreliable_ordered", 1)
func voice_packet_received(packet: PackedByteArray) -> void:
	if multiplayer.is_server(): return
	
	var sender_id = multiplayer.get_remote_sender_id()
	users[sender_id].stream.push_packet(packet)


func _process(_delta: float) -> void:
	if not Connection.is_peer_connected: return
	if multiplayer.is_server(): return
	
	mic_capture.send_test_packets()
