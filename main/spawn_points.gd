extends Node3D
class_name SpawnPoints

var spawn_points: Array[Node]
var used_ids: Array[int]
var size: int


func _ready() -> void:
	spawn_points = get_children() as Array[Node]
	size = spawn_points.size()


func get_spawn_position() -> Vector3:
	var id = 0
	for x in range(1000):
		id = randi() % size
		if not id in used_ids:
			used_ids.push_back(id)
			break
		elif used_ids.size() == size:
			used_ids.pop_front()
	
	return spawn_points[id].global_position
