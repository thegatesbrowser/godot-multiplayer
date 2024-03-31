class_name CharacterSkin
extends Node3D

@export var main_animation_player : AnimationPlayer

var moving_blend_path := "parameters/StateMachine/move/blend_position"

# False : set animation to "idle"
# True : set animation to "move"
@onready var moving : bool = false : set = set_moving

# Blend value between the walk and run cycle
# 0.0 walk - 1.0 run
@onready var move_speed : float = 0.0 : set = set_moving_speed
@onready var animation_tree : AnimationTree = $AnimationTree
@onready var state_machine : AnimationNodeStateMachinePlayback = animation_tree.get("parameters/StateMachine/playback")

@onready var _step_sound: AudioStreamPlayer3D = $StepSound
@onready var _landing_sound: AudioStreamPlayer3D = $LandingSound


func _ready():
	animation_tree.active = true
	main_animation_player["playback_default_blend_time"] = 0.1


@rpc("authority", "call_local", "unreliable_ordered")
func set_moving(value : bool):
	moving = value
	if moving:
		state_machine.travel("move")
	else:
		state_machine.travel("idle")


@rpc("authority", "call_local", "unreliable_ordered")
func set_moving_speed(value : float):
	move_speed = clamp(value, 0.0, 1.0)
	animation_tree.set(moving_blend_path, move_speed)


@rpc("authority", "call_local", "unreliable_ordered")
func jump():
	state_machine.travel("jump")


@rpc("authority", "call_local", "unreliable_ordered")
func fall():
	state_machine.travel("fall")


func play_step_sound():
	_step_sound.pitch_scale = randfn(1.1, 0.05)
	_step_sound.play()


func play_landing_sound():
	_landing_sound.play()
