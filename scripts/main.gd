extends Node3D

const DEFAULT_PORT := 9080
const SAVE_PATH := "user://slice_zero_world.json"
const WorldStateModel = preload("res://scripts/world_state.gd")

var world_state := WorldStateModel.new()
var peer_to_token: Dictionary = {}
var peer_inputs: Dictionary = {}
var player_nodes: Dictionary = {}
var local_token := ""
var is_server := false
var client_connected := false
var snapshot_accumulator := 0.0

var status_label: Label
var address_input: LineEdit
var connect_button: Button
var collectible_mesh: MeshInstance3D


func _ready() -> void:
	_build_world()
	_build_interface()
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	multiplayer.connected_to_server.connect(_on_connected_to_server)
	multiplayer.connection_failed.connect(_on_connection_failed)
	multiplayer.server_disconnected.connect(_on_server_disconnected)

	if "--server" in OS.get_cmdline_user_args():
		_start_server(_read_port_argument())
	else:
		local_token = _load_or_create_player_token()
		var connect_address := _read_connect_argument()
		if not connect_address.is_empty():
			address_input.text = connect_address
			_connect_to_server.call_deferred()


func _physics_process(delta: float) -> void:
	if is_server:
		_simulate_server(delta)
		return
	if not client_connected:
		return
	var input_vector := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	submit_input.rpc_id(1, input_vector)


func _simulate_server(delta: float) -> void:
	for peer_id: int in peer_to_token:
		var token: String = peer_to_token[peer_id]
		var pending_input: Vector2 = peer_inputs.get(peer_id, Vector2.ZERO)
		world_state.move_player(token, pending_input, delta)
		if world_state.try_collect(token):
			_save_world()

	snapshot_accumulator += delta
	if snapshot_accumulator >= 0.05:
		snapshot_accumulator = 0.0
		receive_snapshot.rpc(_snapshot_for_clients())


@rpc("any_peer", "call_remote", "reliable")
func register_player(player_token: String) -> void:
	if not is_server or player_token.is_empty():
		return
	var sender_id := multiplayer.get_remote_sender_id()
	peer_to_token[sender_id] = player_token
	peer_inputs[sender_id] = Vector2.ZERO
	world_state.register_player(player_token)
	_save_world()
	receive_snapshot.rpc_id(sender_id, _snapshot_for_clients())


@rpc("any_peer", "call_remote", "unreliable_ordered", 1)
func submit_input(input_vector: Vector2) -> void:
	if not is_server:
		return
	var sender_id := multiplayer.get_remote_sender_id()
	if peer_to_token.has(sender_id):
		peer_inputs[sender_id] = input_vector.limit_length(1.0)


@rpc("authority", "call_remote", "unreliable_ordered", 1)
func receive_snapshot(snapshot: Dictionary) -> void:
	var seen_tokens := {}
	var positions: Dictionary = snapshot.get("positions", {})
	for token: String in positions:
		seen_tokens[token] = true
		var position: Vector3 = positions[token]
		_get_or_create_player_node(token).position = position
	for token: String in player_nodes.keys():
		if not seen_tokens.has(token):
			player_nodes[token].queue_free()
			player_nodes.erase(token)
	collectible_mesh.visible = not bool(snapshot.get("collectible_collected", false))


func _start_server(port: int) -> void:
	is_server = true
	_load_world()
	var web_socket_peer := WebSocketMultiplayerPeer.new()
	var error := web_socket_peer.create_server(port)
	if error != OK:
		_status("Server failed: %s" % error_string(error))
		return
	multiplayer.multiplayer_peer = web_socket_peer
	_status("Server listening on port %d" % port)
	connect_button.visible = false
	address_input.visible = false


func _connect_to_server() -> void:
	connect_button.disabled = true
	_status("Connecting…")
	var web_socket_peer := WebSocketMultiplayerPeer.new()
	var error := web_socket_peer.create_client(address_input.text.strip_edges())
	if error != OK:
		connect_button.disabled = false
		_status("Connection failed: %s" % error_string(error))
		return
	multiplayer.multiplayer_peer = web_socket_peer


func _on_connected_to_server() -> void:
	client_connected = true
	_status("Connected — use WASD or arrow keys")
	connect_button.disabled = true
	register_player.rpc_id(1, local_token)


func _on_connection_failed() -> void:
	client_connected = false
	_status("Could not connect")
	connect_button.disabled = false


func _on_server_disconnected() -> void:
	client_connected = false
	_status("Server disconnected")
	connect_button.disabled = false


func _on_peer_connected(_peer_id: int) -> void:
	pass


func _on_peer_disconnected(peer_id: int) -> void:
	if not is_server:
		return
	peer_inputs.erase(peer_id)
	peer_to_token.erase(peer_id)
	_save_world()
	receive_snapshot.rpc(_snapshot_for_clients())


func _snapshot_for_clients() -> Dictionary:
	var active_positions := {}
	for peer_id: int in peer_to_token:
		var token: String = peer_to_token[peer_id]
		active_positions[token] = world_state.positions[token]
	return {
		"positions": active_positions,
		"collectible_collected": world_state.collectible_collected,
	}


func _save_world() -> void:
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file != null:
		file.store_string(JSON.stringify(world_state.to_dictionary()))


func _load_world() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		return
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		return
	var parsed = JSON.parse_string(file.get_as_text())
	if parsed is Dictionary:
		world_state.load_dictionary(parsed)


func _load_or_create_player_token() -> String:
	var path := "user://slice_zero_player.txt"
	if FileAccess.file_exists(path):
		var existing := FileAccess.get_file_as_string(path).strip_edges()
		if not existing.is_empty():
			return existing
	var generated := "%s-%s" % [Time.get_unix_time_from_system(), randi()]
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file != null:
		file.store_string(generated)
	return generated


func _read_port_argument() -> int:
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with("--port="):
			return int(argument.trim_prefix("--port="))
	return DEFAULT_PORT


func _read_connect_argument() -> String:
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with("--connect="):
			return argument.trim_prefix("--connect=")
	return ""


func _build_world() -> void:
	var environment := WorldEnvironment.new()
	var environment_resource := Environment.new()
	environment_resource.background_mode = Environment.BG_COLOR
	environment_resource.background_color = Color("8fc7d8")
	environment_resource.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment_resource.ambient_light_color = Color.WHITE
	environment_resource.ambient_light_energy = 0.65
	environment.environment = environment_resource
	add_child(environment)

	var light := DirectionalLight3D.new()
	light.rotation_degrees = Vector3(-55.0, -25.0, 0.0)
	light.shadow_enabled = true
	add_child(light)

	var floor_mesh := MeshInstance3D.new()
	var floor_box := BoxMesh.new()
	floor_box.size = Vector3(18.0, 0.25, 14.0)
	floor_mesh.mesh = floor_box
	floor_mesh.position.y = -0.125
	var floor_material := StandardMaterial3D.new()
	floor_material.albedo_color = Color("7aae68")
	floor_mesh.material_override = floor_material
	add_child(floor_mesh)

	collectible_mesh = MeshInstance3D.new()
	var collectible_shape := SphereMesh.new()
	collectible_shape.radius = 0.45
	collectible_shape.height = 0.9
	collectible_mesh.mesh = collectible_shape
	collectible_mesh.position = WorldStateModel.COLLECTIBLE_POSITION
	var collectible_material := StandardMaterial3D.new()
	collectible_material.albedo_color = Color("ffd45c")
	collectible_material.emission_enabled = true
	collectible_material.emission = Color("ba7b15")
	collectible_mesh.material_override = collectible_material
	add_child(collectible_mesh)

	var camera := Camera3D.new()
	camera.position = Vector3(0.0, 11.0, 10.5)
	camera.rotation_degrees = Vector3(-45.0, 0.0, 0.0)
	add_child(camera)


func _build_interface() -> void:
	var layer := CanvasLayer.new()
	add_child(layer)
	var panel := PanelContainer.new()
	panel.position = Vector2(20.0, 20.0)
	panel.custom_minimum_size = Vector2(390.0, 0.0)
	layer.add_child(panel)
	var content := VBoxContainer.new()
	content.add_theme_constant_override("separation", 10)
	panel.add_child(content)
	var title := Label.new()
	title.text = "PROJECT HEARTH — SLICE 0"
	content.add_child(title)
	address_input = LineEdit.new()
	address_input.text = "ws://127.0.0.1:%d" % DEFAULT_PORT
	address_input.placeholder_text = "Server address"
	content.add_child(address_input)
	connect_button = Button.new()
	connect_button.text = "Connect"
	connect_button.pressed.connect(_connect_to_server)
	content.add_child(connect_button)
	status_label = Label.new()
	status_label.text = "Start the server, then connect."
	content.add_child(status_label)


func _get_or_create_player_node(player_token: String) -> MeshInstance3D:
	if player_nodes.has(player_token):
		return player_nodes[player_token]
	var player_mesh := MeshInstance3D.new()
	var capsule := CapsuleMesh.new()
	capsule.radius = 0.4
	capsule.height = 1.2
	player_mesh.mesh = capsule
	var material := StandardMaterial3D.new()
	material.albedo_color = Color("4c77d6") if player_token == local_token else Color("d66d4c")
	player_mesh.material_override = material
	add_child(player_mesh)
	player_nodes[player_token] = player_mesh
	return player_mesh


func _status(message: String) -> void:
	status_label.text = message
	print(message)
