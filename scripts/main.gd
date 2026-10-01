extends Node3D

const DEFAULT_PORT := 9080
const SAVE_PATH := "user://slice_zero_world.json"
const WorldStateModel = preload("res://scripts/world_state.gd")
const GrayboxWorldBuilder = preload("res://scripts/graybox_world.gd")

var world_state := WorldStateModel.new()
var peer_to_token: Dictionary = {}
var peer_inputs: Dictionary = {}
var player_nodes: Dictionary = {}
var touch_directions: Dictionary = {}
var local_token := ""
var is_server := false
var client_connected := false
var snapshot_accumulator := 0.0

var status_label: Label
var address_input: LineEdit
var connect_button: Button
var collectible_mesh: MeshInstance3D
var game_camera: Camera3D


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
	input_vector = (input_vector + _touch_input_vector()).limit_length(1.0)
	submit_input.rpc_id(1, input_vector)


func _process(delta: float) -> void:
	if game_camera == null or not player_nodes.has(local_token):
		return
	var player_node: MeshInstance3D = player_nodes[local_token]
	var target_position := player_node.position + Vector3(0.0, 13.0, 11.0)
	game_camera.position = game_camera.position.lerp(target_position, minf(delta * 6.0, 1.0))
	game_camera.look_at(player_node.position + Vector3(0.0, 0.5, 0.0))


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
	_status("Connected — follow the road toward the lost supplies")
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
	var world_nodes := GrayboxWorldBuilder.build(self)
	collectible_mesh = world_nodes["collectible"]
	game_camera = world_nodes["camera"]


func _build_interface() -> void:
	var layer := CanvasLayer.new()
	add_child(layer)
	var safe_margin := MarginContainer.new()
	safe_margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	safe_margin.add_theme_constant_override("margin_left", 24)
	safe_margin.add_theme_constant_override("margin_top", 24)
	safe_margin.add_theme_constant_override("margin_right", 24)
	safe_margin.add_theme_constant_override("margin_bottom", 24)
	layer.add_child(safe_margin)
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(420.0, 0.0)
	panel.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	panel.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	safe_margin.add_child(panel)
	var content := VBoxContainer.new()
	content.add_theme_constant_override("separation", 10)
	panel.add_child(content)
	var title := Label.new()
	title.text = "PROJECT HEARTH — A NEW HOME"
	content.add_child(title)
	var objective := Label.new()
	objective.text = "GRAYBOX GOAL: Follow the road, find the abandoned cottage, then recover the lost supplies."
	objective.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	content.add_child(objective)
	address_input = LineEdit.new()
	address_input.text = "ws://127.0.0.1:%d" % DEFAULT_PORT
	address_input.placeholder_text = "Server address"
	content.add_child(address_input)
	connect_button = Button.new()
	connect_button.text = "Connect"
	connect_button.custom_minimum_size.y = 48.0
	connect_button.pressed.connect(_connect_to_server)
	content.add_child(connect_button)
	status_label = Label.new()
	status_label.text = "Start the server, then connect."
	status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	content.add_child(status_label)
	if OS.has_feature("mobile") or DisplayServer.is_touchscreen_available():
		_build_touch_controls(layer)


func _build_touch_controls(layer: CanvasLayer) -> void:
	var controls := HBoxContainer.new()
	controls.set_anchors_preset(Control.PRESET_BOTTOM_LEFT)
	controls.offset_left = 24.0
	controls.offset_top = -96.0
	controls.offset_right = 360.0
	controls.offset_bottom = -24.0
	controls.add_theme_constant_override("separation", 12)
	layer.add_child(controls)
	_add_touch_button(controls, "←", "left")
	_add_touch_button(controls, "↑", "forward")
	_add_touch_button(controls, "↓", "back")
	_add_touch_button(controls, "→", "right")


func _add_touch_button(parent: Control, label: String, direction: String) -> void:
	var button := Button.new()
	button.text = label
	button.custom_minimum_size = Vector2(72.0, 72.0)
	button.button_down.connect(_set_touch_direction.bind(direction, true))
	button.button_up.connect(_set_touch_direction.bind(direction, false))
	parent.add_child(button)


func _set_touch_direction(direction: String, pressed: bool) -> void:
	touch_directions[direction] = pressed


func _touch_input_vector() -> Vector2:
	return Vector2(
		float(touch_directions.get("right", false)) - float(touch_directions.get("left", false)),
		float(touch_directions.get("back", false)) - float(touch_directions.get("forward", false)),
	)


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
