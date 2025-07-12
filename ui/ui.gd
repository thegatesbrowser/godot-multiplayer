extends Control

signal start_server
signal connect_client(ip_address: String)

@export var hide_ui_and_connect: bool

const SAVE_FILE_PATH = "user://ip_settings.dat"


func _ready():
	if Connection.is_server(): return
	
	# Connect to connection events for error handling
	var connection_node = get_node("/root/Main/Connection")
	if connection_node:
		connection_node.disconnected.connect(_on_connection_failed)
	
	# Load saved IP address
	_load_ip_address()
	
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
	var ip_address = $MainMenu/MenuContainer/IPSection/IPInput.text.strip_edges()
	if ip_address.is_empty():
		ip_address = "localhost"
	
	# Basic IP validation
	if not _is_valid_ip_or_hostname(ip_address):
		_show_connection_error("Invalid IP address or hostname!")
		return
	
	# Save IP address for next time
	_save_ip_address(ip_address)
	
	connect_client.emit(ip_address)
	hide_ui()


func exit_game_emit() -> void:
	get_tree().quit()


func hide_ui() -> void:
	$MainMenu.visible = false
	$InGameUI.visible = true


func show_ui() -> void:
	$MainMenu.visible = true
	$InGameUI.visible = false


func _is_valid_ip_or_hostname(address: String) -> bool:
	if address.is_empty():
		return false
	
	# Allow localhost
	if address == "localhost":
		return true
	
	# Basic hostname validation (alphanumeric, dots, hyphens)
	var hostname_regex = RegEx.new()
	hostname_regex.compile("^[a-zA-Z0-9.-]+$")
	if hostname_regex.search(address):
		return true
	
	# Basic IP address validation
	var parts = address.split(".")
	if parts.size() != 4:
		return false
	
	for part in parts:
		if not part.is_valid_int():
			return false
		var num = part.to_int()
		if num < 0 or num > 255:
			return false
	
	return true


func _show_connection_error(message: String) -> void:
	print("Connection error: " + message)
	# Visual feedback by highlighting the IP input field
	var ip_input = $MainMenu/MenuContainer/IPSection/IPInput
	ip_input.modulate = Color.RED
	
	# Reset color after 2 seconds
	await get_tree().create_timer(2.0).timeout
	ip_input.modulate = Color.WHITE


func _on_connection_failed() -> void:
	# Show UI again if connection fails
	if not $MainMenu.visible:
		show_ui()
		_show_connection_error("Failed to connect to server!")


func _save_ip_address(ip_address: String) -> void:
	var file = FileAccess.open(SAVE_FILE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(ip_address)
		file.close()


func _load_ip_address() -> void:
	if FileAccess.file_exists(SAVE_FILE_PATH):
		var file = FileAccess.open(SAVE_FILE_PATH, FileAccess.READ)
		if file:
			var saved_ip = file.get_as_text().strip_edges()
			file.close()
			if not saved_ip.is_empty():
				$MainMenu/MenuContainer/IPSection/IPInput.text = saved_ip
