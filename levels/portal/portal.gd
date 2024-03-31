extends Node3D

@export var url: String


func _on_portal_entered(body):
	if not body is Player: return
	if body.get_multiplayer_authority() != multiplayer.get_unique_id(): return
	
	print("Portal_entered: " + url)
	await get_tree().create_timer(0.2).timeout
	
	if get_tree().has_method("open_gate"):
		get_tree().open_gate(url)
	else:
		push_warning("Tree doesn't have method open_gate. Do nothing")
