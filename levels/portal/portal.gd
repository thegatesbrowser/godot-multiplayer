extends Node3D

signal portal_entered(url: String)

@export var url: String


func _on_portal_entered(body):
	if not body is CharacterBody3D: return
	await get_tree().create_timer(0.2).timeout
	print("portal_entered: " + url)
	portal_entered.emit(url)


func shut_down(_body) -> void:
	$Portal/MeshInstance3D.visible = false
	$Portal/MeshInstance3D2.visible = false
	$Portal/OmniLight3D.visible = false
	$Portal/CollisionShape3D.set_deferred("disabled", true)
