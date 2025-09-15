extends Node

@export var user_scn: PackedScene
@export var player_spawner: PlayerSpawner

var opuschunked: AudioEffectOpusChunked
var prepend: PackedByteArray = PackedByteArray()
var users = {} # {Peer ID: VoipUser}


func _ready() -> void:
	if Connection.is_server(): return
	
	multiplayer.peer_connected.connect(peer_connected)
	multiplayer.peer_disconnected.connect(peer_disconnected)
	player_spawner.player_spawned.connect(player_spawned)
	
	var mic_bus = AudioServer.get_bus_index("Record")
	opuschunked = AudioServer.get_bus_effect(mic_bus, 0)


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


func _process(_delta: float) -> void:
	if not Connection.is_peer_connected: return
	if multiplayer.is_server(): return
	
	var accumulated_opusdata: Array[PackedByteArray] = []
	while opuschunked.chunk_available():
		if not Microphone.is_speaking:
			opuschunked.drop_chunk()
			continue
		
		var opusdata: PackedByteArray = opuschunked.read_opus_packet(prepend)
		opuschunked.drop_chunk()
		accumulated_opusdata.append(opusdata)
	
	if Microphone.is_speaking:
		rpc("opus_data_received", accumulated_opusdata)


@rpc("any_peer", "call_remote", "unreliable_ordered", 1)
func opus_data_received(opusdata_array: Array[PackedByteArray]) -> void:
	if multiplayer.is_server(): return
	
	var sender_id = multiplayer.get_remote_sender_id()
	users[sender_id].opuspacketsbuffer.append_array(opusdata_array)
