extends Control

signal start_server
signal connect_client

@export var hide_ui_and_connect: bool


func _ready():
	if Connection.is_server(): return
	
	if hide_ui_and_connect:
		connect_client_emit()
	else:
		show_ui()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("quit_game"):
		if $MainMenu.visible:
			# If main menu is visible, quit the game
			get_tree().quit()
		elif $InGameUI.visible:
			# If in-game UI is visible, return to main menu
			# Disconnect from server/client first
			if Connection.is_peer_connected:
				multiplayer.multiplayer_peer.close()
			show_ui()


func start_server_emit() -> void:
	start_server.emit()
	$MainMenu.visible = false


func connect_client_emit() -> void:
	connect_client.emit()
	hide_ui()


func exit_game_emit() -> void:
	get_tree().quit()


func hide_ui() -> void:
	$MainMenu.visible = false
	$InGameUI.visible = true


func show_ui() -> void:
	$MainMenu.visible = true
	$InGameUI.visible = false
