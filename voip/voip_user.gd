extends AudioStreamPlayer3D
class_name VoipUser

@export var offset: Vector3
@export var volume_curve: Curve
@export var user_data_events: UserDataEvents

var user_id: int
var anchor: Node3D

var audiostreamopuschunked : AudioStreamOpusChunked
var opuspacketsbuffer: Array[PackedByteArray] = []


func _ready() -> void:
	user_data_events.user_volume_changed.connect(change_volume)
	audiostreamopuschunked = stream as AudioStreamOpusChunked


func _process(_delta: float) -> void:
	while audiostreamopuschunked.chunk_space_available() and not opuspacketsbuffer.is_empty():
		audiostreamopuschunked.push_opus_packet(opuspacketsbuffer.pop_front(), 0, 0)


func _physics_process(_delta: float) -> void:
	if not is_instance_valid(anchor): return
	global_position = anchor.global_position + offset


func set_user_id(id: int) -> void:
	user_id = id


func set_anchor(_anchor: Node3D) -> void:
	anchor = _anchor


func change_volume(id: int, volume: float) -> void:
	if id != user_id: return
	volume_db = linear_to_db(volume_curve.sample(volume))
