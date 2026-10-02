extends Node3D

const DEFAULT_PORT := 9080
const SAVE_PATH := "user://slice_zero_world.json"
const DEFAULT_ROOM_CODE := "HEARTH"
const MAX_PLAYERS := 4
const CAMERA_FIRST_PERSON := "first_person"
const CAMERA_THIRD_PERSON := "third_person"
const CAMERA_MIN_DISTANCE := 3.0
const CAMERA_MAX_DISTANCE := 8.0
const CAMERA_MOUSE_SENSITIVITY := 0.004
const CAMERA_TOUCH_SENSITIVITY := 0.006
const CAMERA_CONTROLLER_SPEED := 2.2
const CAMERA_MIN_PITCH := deg_to_rad(-65.0)
const CAMERA_MAX_PITCH := deg_to_rad(65.0)
const FIRST_PERSON_EYE_OFFSET := Vector3(0.0, 0.62, 0.0)
const THIRD_PERSON_SHOULDER_HEIGHT := 0.35
const THIRD_PERSON_SHOULDER_OFFSET := 0.75
const PLAYER_POSITION_SMOOTHING_SPEED := 18.0
const WorldStateModel = preload("res://scripts/world_state.gd")
const GrayboxWorldBuilder = preload("res://scripts/graybox_world.gd")

var world_state := WorldStateModel.new()
var peer_to_token: Dictionary = {}
var peer_inputs: Dictionary = {}
var player_nodes: Dictionary = {}
var player_target_positions: Dictionary = {}
var touch_directions: Dictionary = {}
var local_token := ""
var is_server := false
var client_connected := false
var snapshot_accumulator := 0.0
var save_path := SAVE_PATH
var server_room_code := DEFAULT_ROOM_CODE
var latest_snapshot: Dictionary = {}
var camera_yaw := 0.0
var camera_pitch := 0.0
var camera_distance := 5.5
var camera_mode := CAMERA_FIRST_PERSON
var camera_touch_index := -1
var local_input_enabled := true

var status_label: Label
var quest_title_label: Label
var objective_label: Label
var dialogue_label: Label
var progress_label: Label
var interaction_prompt: Label
var inventory_label: Label
var combat_label: Label
var world_change_label: Label
var address_input: LineEdit
var room_code_input: LineEdit
var connect_button: Button
var craft_button: Button
var quest_card: PanelContainer
var map_panel: PanelContainer
var map_label: Label
var chronicle_panel: PanelContainer
var chronicle_label: Label
var connection_panel: PanelContainer
var debug_panel: PanelContainer
var collectible_mesh: MeshInstance3D
var game_camera: Camera3D
var mara_node: Node3D
var resource_nodes: Dictionary = {}
var repair_nodes: Dictionary = {}
var repair_result_nodes: Dictionary = {}
var welcome_lantern_markers: Dictionary = {}
var welcome_lantern_lights: Dictionary = {}
var creature_node: MeshInstance3D
var rumor_marker: MeshInstance3D
var ruin_guardian_node: MeshInstance3D
var waystone_marker: Node3D
var home_waystone: Node3D
var ruin_waystone: Node3D
var waystone_glows: Dictionary = {}


func _ready() -> void:
	_build_world()
	_build_interface()
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	multiplayer.connected_to_server.connect(_on_connected_to_server)
	multiplayer.connection_failed.connect(_on_connection_failed)
	multiplayer.server_disconnected.connect(_on_server_disconnected)

	if "--server" in OS.get_cmdline_user_args():
		save_path = _read_save_path_argument()
		server_room_code = _read_room_argument()
		_start_server(_read_port_argument(), _read_bind_address_argument())
	else:
		local_token = _read_player_token_argument()
		if local_token.is_empty():
			local_token = _load_or_create_player_token()
		room_code_input.text = _read_room_argument()
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
	if not local_input_enabled:
		return
	var input_vector := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	input_vector = (input_vector + _touch_input_vector()).limit_length(1.0)
	input_vector = input_vector.rotated(-camera_yaw)
	submit_input.rpc_id(1, input_vector)
	if Input.is_action_just_pressed("interact"):
		_request_interaction()
	if Input.is_action_just_pressed("craft"):
		_request_craft()
	if Input.is_action_just_pressed("attack"):
		_request_attack()
	if Input.is_action_just_pressed("toggle_debug"):
		debug_panel.visible = not debug_panel.visible
	if Input.is_action_just_pressed("toggle_camera"):
		_toggle_camera_mode()


func _process(delta: float) -> void:
	_interpolate_player_positions(delta)
	if game_camera == null or not player_nodes.has(local_token):
		return
	_update_controller_camera(delta)
	var player_node: MeshInstance3D = player_nodes[local_token]
	var eye_position := player_node.position + FIRST_PERSON_EYE_OFFSET
	var horizontal_forward := Vector3(-sin(camera_yaw), 0.0, -cos(camera_yaw))
	var right_direction := Vector3(cos(camera_yaw), 0.0, -sin(camera_yaw))
	var look_direction := Vector3(
		horizontal_forward.x * cos(camera_pitch),
		-sin(camera_pitch),
		horizontal_forward.z * cos(camera_pitch)
	).normalized()
	if camera_mode == CAMERA_FIRST_PERSON:
		game_camera.position = eye_position
	else:
		var target_position := (
			eye_position
			- horizontal_forward * camera_distance
			+ right_direction * THIRD_PERSON_SHOULDER_OFFSET
			+ Vector3.UP * THIRD_PERSON_SHOULDER_HEIGHT
		)
		game_camera.position = game_camera.position.lerp(target_position, minf(delta * 10.0, 1.0))
	game_camera.look_at(eye_position + look_direction * 10.0)


func _interpolate_player_positions(delta: float) -> void:
	var smoothing_weight := 1.0 - exp(-PLAYER_POSITION_SMOOTHING_SPEED * delta)
	for token: String in player_target_positions:
		if not player_nodes.has(token):
			continue
		var player_node: MeshInstance3D = player_nodes[token]
		player_node.position = player_node.position.lerp(player_target_positions[token], smoothing_weight)


func _unhandled_input(event: InputEvent) -> void:
	if is_server:
		return
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_WHEEL_UP:
			camera_distance = maxf(camera_distance - 1.5, CAMERA_MIN_DISTANCE)
			get_viewport().set_input_as_handled()
		elif event.pressed and event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			camera_distance = minf(camera_distance + 1.5, CAMERA_MAX_DISTANCE)
			get_viewport().set_input_as_handled()
		elif event.pressed and client_connected:
			_capture_mouse()
	elif event is InputEventMouseMotion:
		_orbit_camera(event.relative, CAMERA_MOUSE_SENSITIVITY)
		get_viewport().set_input_as_handled()
	elif event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		_release_mouse()
		get_viewport().set_input_as_handled()
	elif event is InputEventScreenTouch:
		if event.pressed and event.position.x > get_viewport().get_visible_rect().size.x * 0.45:
			camera_touch_index = event.index
		elif not event.pressed and event.index == camera_touch_index:
			camera_touch_index = -1
	elif event is InputEventScreenDrag and event.index == camera_touch_index:
		_orbit_camera(event.relative, CAMERA_TOUCH_SENSITIVITY)


func _orbit_camera(relative_motion: Vector2, sensitivity: float) -> void:
	camera_yaw = wrapf(camera_yaw - relative_motion.x * sensitivity, -PI, PI)
	camera_pitch = clampf(
		camera_pitch + relative_motion.y * sensitivity,
		CAMERA_MIN_PITCH,
		CAMERA_MAX_PITCH
	)


func _update_controller_camera(delta: float) -> void:
	for device_id: int in Input.get_connected_joypads():
		var look := Vector2(
			Input.get_joy_axis(device_id, JOY_AXIS_RIGHT_X),
			Input.get_joy_axis(device_id, JOY_AXIS_RIGHT_Y)
		)
		if look.length() > 0.18:
			_orbit_camera(look * delta, CAMERA_CONTROLLER_SPEED)
			return


func _toggle_camera_mode() -> void:
	camera_mode = CAMERA_THIRD_PERSON if camera_mode == CAMERA_FIRST_PERSON else CAMERA_FIRST_PERSON
	_update_local_player_visibility()


func _update_local_player_visibility() -> void:
	if player_nodes.has(local_token):
		player_nodes[local_token].visible = camera_mode == CAMERA_THIRD_PERSON


func _simulate_server(delta: float) -> void:
	for peer_id: int in peer_to_token:
		var token: String = peer_to_token[peer_id]
		var pending_input: Vector2 = peer_inputs.get(peer_id, Vector2.ZERO)
		world_state.move_player(token, pending_input, delta)
		if world_state.update_exploration(token):
			_save_world()
		if world_state.try_collect(token):
			_save_world()
	if world_state.simulate_creature(delta, peer_to_token.values()):
		_save_world()

	snapshot_accumulator += delta
	if snapshot_accumulator >= 0.05:
		snapshot_accumulator = 0.0
		receive_snapshot.rpc(_snapshot_for_clients())


@rpc("any_peer", "call_remote", "reliable")
func register_player(player_token: String, requested_room_code: String) -> void:
	if not is_server or player_token.is_empty():
		return
	var sender_id := multiplayer.get_remote_sender_id()
	if requested_room_code.strip_edges().to_upper() != server_room_code:
		registration_rejected.rpc_id(sender_id, "Room code not found")
		return
	if not peer_to_token.has(sender_id) and peer_to_token.size() >= MAX_PLAYERS:
		registration_rejected.rpc_id(sender_id, "Room is full (maximum %d players)" % MAX_PLAYERS)
		return
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


@rpc("any_peer", "call_remote", "reliable")
func request_interaction() -> void:
	if not is_server:
		return
	var sender_id := multiplayer.get_remote_sender_id()
	if not peer_to_token.has(sender_id):
		return
	var player_token: String = peer_to_token[sender_id]
	if world_state.interact(player_token):
		_save_world()
		receive_snapshot.rpc(_snapshot_for_clients())


@rpc("any_peer", "call_remote", "reliable")
func request_craft_repair_kit() -> void:
	if not is_server:
		return
	var sender_id := multiplayer.get_remote_sender_id()
	if not peer_to_token.has(sender_id):
		return
	if world_state.craft_repair_kit():
		_save_world()
		receive_snapshot.rpc(_snapshot_for_clients())


@rpc("any_peer", "call_remote", "reliable")
func request_attack() -> void:
	if not is_server:
		return
	var sender_id := multiplayer.get_remote_sender_id()
	if not peer_to_token.has(sender_id):
		return
	if world_state.attack_creature(peer_to_token[sender_id]):
		_save_world()
		receive_snapshot.rpc(_snapshot_for_clients())


@rpc("authority", "call_remote", "unreliable_ordered", 1)
func receive_snapshot(snapshot: Dictionary) -> void:
	latest_snapshot = snapshot.duplicate(true)
	if client_connected and status_label.text == "Joining room…":
		_status("Connected — welcome back to your shared world")
	var seen_tokens := {}
	var positions: Dictionary = snapshot.get("positions", {})
	for token: String in positions:
		seen_tokens[token] = true
		var position: Vector3 = positions[token]
		var is_new_player := not player_nodes.has(token)
		var player_node := _get_or_create_player_node(token)
		player_target_positions[token] = position
		player_node.scale = Vector3(1.0, 0.35, 1.0) if bool(snapshot.get("downed_players", {}).get(token, false)) else Vector3.ONE
		if is_new_player:
			player_node.position = position
	for token: String in player_nodes.keys():
		if not seen_tokens.has(token):
			player_nodes[token].queue_free()
			player_nodes.erase(token)
			player_target_positions.erase(token)
	collectible_mesh.visible = not bool(snapshot.get("collectible_collected", false))
	var gathered: Dictionary = snapshot.get("gathered_resources", {})
	for resource_id: String in resource_nodes:
		resource_nodes[resource_id].visible = not bool(gathered.get(resource_id, false))
	var repairs: Dictionary = snapshot.get("repaired_parts", {})
	var quest_stage := str(snapshot.get("quest_stage", "meet_mara"))
	var event_stage := str(snapshot.get("neighborhood_event_stage", "locked"))
	var materials: Dictionary = snapshot.get("materials", {})
	var has_repair_kit := int(materials.get("repair_kit", 0)) > 0
	for part_id: String in repair_nodes:
		var is_repaired := bool(repairs.get(part_id, false))
		repair_nodes[part_id].visible = quest_stage == "repair_cottage" and has_repair_kit and not is_repaired
		repair_result_nodes[part_id].visible = is_repaired
	var lit_lanterns: Dictionary = snapshot.get("lit_welcome_lanterns", {})
	for lantern_id: String in welcome_lantern_markers:
		var is_lit := bool(lit_lanterns.get(lantern_id, false))
		welcome_lantern_markers[lantern_id].visible = event_stage == "lighting" and not is_lit
		welcome_lantern_lights[lantern_id].visible = is_lit
	mara_node.position = snapshot.get("mara_position", WorldStateModel.MARA_POSITION)
	_update_interaction_prompt(
		quest_stage,
		has_repair_kit,
		repairs,
		event_stage,
		lit_lanterns,
		positions.get(local_token, Vector3.INF)
	)
	_update_quest_interface(
		quest_stage,
		materials,
		repairs,
		event_stage,
		lit_lanterns,
		str(snapshot.get("exploration_stage", "locked")),
		snapshot.get("shared_map_discoveries", {}),
		bool(snapshot.get("ruin_waystone_activated", false))
	)
	var creature_defeated := bool(snapshot.get("creature_defeated", false))
	creature_node.visible = not creature_defeated
	creature_node.position = snapshot.get("creature_position", WorldStateModel.CREATURE_SPAWN)
	_update_combat_interface(snapshot, creature_defeated)
	var rumor_unlocked := bool(snapshot.get("map_rumor_unlocked", false))
	var discoveries: Dictionary = snapshot.get("shared_map_discoveries", {})
	var exploration_stage := str(snapshot.get("exploration_stage", "locked"))
	var guardian_defeated := bool(snapshot.get("ruin_guardian_defeated", false))
	var route_activated := bool(snapshot.get("ruin_waystone_activated", false))
	rumor_marker.visible = rumor_unlocked and not bool(discoveries.get("northwood", false))
	ruin_guardian_node.visible = exploration_stage == "defeat_guardian" and not guardian_defeated
	ruin_guardian_node.position = snapshot.get("ruin_guardian_position", WorldStateModel.RUIN_GUARDIAN_SPAWN)
	waystone_marker.visible = exploration_stage == "restore_waystone" and not route_activated
	home_waystone.visible = route_activated
	ruin_waystone.visible = bool(discoveries.get("old_stone_ruins", false))
	for glow: MeshInstance3D in waystone_glows.values():
		glow.visible = route_activated
	map_panel.visible = rumor_unlocked
	map_label.text = _shared_map_text(discoveries, route_activated)
	var chronicle: Array = snapshot.get("chronicle", [])
	chronicle_panel.visible = not chronicle.is_empty()
	var chronicle_lines := PackedStringArray()
	for entry in chronicle:
		chronicle_lines.append(str(entry))
	chronicle_label.text = "CHRONICLE\n• %s" % "\n• ".join(chronicle_lines) if not chronicle.is_empty() else ""
	world_change_label.text = "Reputation: %d  Morale: %d  Map rumor: %s  Chronicle entries: %d" % [
		int(snapshot.get("reputation", 0)),
		int(snapshot.get("neighborhood_morale", 0)),
		"Old Stone Ruins beyond the northern trail" if rumor_unlocked else "Locked",
		chronicle.size(),
	]
	connection_panel.visible = false


@rpc("authority", "call_remote", "reliable")
func registration_rejected(reason: String) -> void:
	client_connected = false
	_release_mouse()
	multiplayer.multiplayer_peer = OfflineMultiplayerPeer.new()
	connect_button.disabled = false
	room_code_input.editable = true
	connection_panel.visible = true
	_status(reason)


func _start_server(port: int, bind_address: String = "*") -> void:
	is_server = true
	_load_world()
	var web_socket_peer := WebSocketMultiplayerPeer.new()
	var error := web_socket_peer.create_server(port, bind_address)
	if error != OK:
		_status("Server failed: %s" % error_string(error))
		return
	multiplayer.multiplayer_peer = web_socket_peer
	_status("Server listening on %s:%d" % [bind_address, port])
	connect_button.visible = false
	address_input.visible = false
	room_code_input.visible = false


func _connect_to_server() -> void:
	connect_button.disabled = true
	_status("Connecting…")
	_capture_mouse()
	var web_socket_peer := WebSocketMultiplayerPeer.new()
	var error := web_socket_peer.create_client(address_input.text.strip_edges())
	if error != OK:
		_release_mouse()
		connect_button.disabled = false
		_status("Connection failed: %s" % error_string(error))
		return
	multiplayer.multiplayer_peer = web_socket_peer


func _on_connected_to_server() -> void:
	client_connected = true
	_status("Joining room…")
	connect_button.disabled = true
	room_code_input.editable = false
	register_player.rpc_id(1, local_token, room_code_input.text)


func _on_connection_failed() -> void:
	client_connected = false
	_release_mouse()
	_status("Could not connect")
	connect_button.disabled = false
	connection_panel.visible = true


func _on_server_disconnected() -> void:
	client_connected = false
	_release_mouse()
	_status("Server disconnected")
	connect_button.disabled = false
	connection_panel.visible = true


func _on_peer_connected(_peer_id: int) -> void:
	pass


func _capture_mouse() -> void:
	if not OS.has_feature("mobile"):
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _release_mouse() -> void:
	if not OS.has_feature("mobile"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


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
		"quest_stage": world_state.quest_stage,
		"materials": world_state.materials.duplicate(),
		"gathered_resources": world_state.gathered_resources.duplicate(),
		"repaired_parts": world_state.repaired_parts.duplicate(),
		"player_health": world_state.player_health.duplicate(),
		"downed_players": world_state.downed_players.duplicate(),
		"creature_position": world_state.creature_position,
		"creature_health": world_state.creature_health,
		"creature_defeated": world_state.creature_defeated,
		"reputation": world_state.reputation,
		"map_rumor_unlocked": world_state.map_rumor_unlocked,
		"mara_position": world_state.mara_position,
		"neighborhood_event_stage": world_state.neighborhood_event_stage,
		"lit_welcome_lanterns": world_state.lit_welcome_lanterns.duplicate(),
		"neighborhood_morale": world_state.neighborhood_morale,
		"chronicle": world_state.chronicle.duplicate(),
		"shared_map_discoveries": world_state.shared_map_discoveries.duplicate(),
		"exploration_stage": world_state.exploration_stage,
		"ruin_guardian_position": world_state.ruin_guardian_position,
		"ruin_guardian_health": world_state.ruin_guardian_health,
		"ruin_guardian_defeated": world_state.ruin_guardian_defeated,
		"ruin_waystone_activated": world_state.ruin_waystone_activated,
		"room_code": server_room_code,
	}


func _save_world() -> void:
	var file := FileAccess.open(save_path, FileAccess.WRITE)
	if file != null:
		file.store_string(JSON.stringify(world_state.to_dictionary()))


func _load_world() -> void:
	if not FileAccess.file_exists(save_path):
		return
	var file := FileAccess.open(save_path, FileAccess.READ)
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


func _read_bind_address_argument() -> String:
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with("--bind="):
			var requested := argument.trim_prefix("--bind=").strip_edges()
			if not requested.is_empty():
				return requested
	return "*"


func _read_connect_argument() -> String:
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with("--connect="):
			return argument.trim_prefix("--connect=")
	return ""


func _read_player_token_argument() -> String:
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with("--player-token="):
			return argument.trim_prefix("--player-token=").strip_edges()
	return ""


func _read_room_argument() -> String:
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with("--room="):
			var requested := argument.trim_prefix("--room=").strip_edges().to_upper()
			if not requested.is_empty():
				return requested
	return DEFAULT_ROOM_CODE


func _read_save_path_argument() -> String:
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with("--save-file="):
			var requested := argument.trim_prefix("--save-file=").strip_edges()
			if not requested.is_empty():
				return requested
	return SAVE_PATH


func _build_world() -> void:
	var world_nodes := GrayboxWorldBuilder.build(self)
	collectible_mesh = world_nodes["collectible"]
	game_camera = world_nodes["camera"]
	mara_node = world_nodes["mara"]
	resource_nodes = world_nodes["resources"]
	repair_nodes = world_nodes["repairs"]
	repair_result_nodes = world_nodes["repair_results"]
	welcome_lantern_markers = world_nodes["welcome_lantern_markers"]
	welcome_lantern_lights = world_nodes["welcome_lantern_lights"]
	creature_node = world_nodes["creature"]
	rumor_marker = world_nodes["rumor_marker"]
	ruin_guardian_node = world_nodes["ruin_guardian"]
	waystone_marker = world_nodes["waystone_marker"]
	home_waystone = world_nodes["home_waystone"]
	ruin_waystone = world_nodes["ruin_waystone"]
	waystone_glows = world_nodes["waystone_glows"]


func _build_interface() -> void:
	var layer := CanvasLayer.new()
	add_child(layer)
	var safe_margin := MarginContainer.new()
	safe_margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	safe_margin.add_theme_constant_override("margin_left", 20)
	safe_margin.add_theme_constant_override("margin_top", 20)
	safe_margin.add_theme_constant_override("margin_right", 20)
	safe_margin.add_theme_constant_override("margin_bottom", 20)
	layer.add_child(safe_margin)
	var top_stack := VBoxContainer.new()
	top_stack.custom_minimum_size.x = 360.0
	top_stack.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	top_stack.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	top_stack.add_theme_constant_override("separation", 8)
	safe_margin.add_child(top_stack)

	quest_card = PanelContainer.new()
	quest_card.name = "QuestCard"
	quest_card.custom_minimum_size = Vector2(360.0, 0.0)
	var quest_style := StyleBoxFlat.new()
	quest_style.bg_color = Color(0.055, 0.09, 0.12, 0.9)
	quest_style.border_color = Color("20e0f0")
	quest_style.set_border_width_all(2)
	quest_style.set_corner_radius_all(10)
	quest_style.set_content_margin_all(14)
	quest_card.add_theme_stylebox_override("panel", quest_style)
	top_stack.add_child(quest_card)
	var quest_content := VBoxContainer.new()
	quest_content.add_theme_constant_override("separation", 6)
	quest_card.add_child(quest_content)
	quest_title_label = Label.new()
	quest_title_label.text = "A NEW HOME"
	quest_title_label.add_theme_color_override("font_color", Color("7df4f7"))
	quest_title_label.add_theme_font_size_override("font_size", 16)
	quest_content.add_child(quest_title_label)
	objective_label = Label.new()
	objective_label.text = "Meet Mara beside the abandoned cottage."
	objective_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	objective_label.add_theme_font_size_override("font_size", 21)
	quest_content.add_child(objective_label)
	progress_label = Label.new()
	progress_label.text = ""
	progress_label.add_theme_color_override("font_color", Color("7df4f7"))
	progress_label.add_theme_font_size_override("font_size", 18)
	progress_label.visible = false
	quest_content.add_child(progress_label)
	dialogue_label = Label.new()
	dialogue_label.text = "Mara is waiting by the cottage."
	dialogue_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	dialogue_label.add_theme_color_override("font_color", Color("ced8dc"))
	quest_content.add_child(dialogue_label)
	craft_button = Button.new()
	craft_button.text = "Craft Repair Kit (C)"
	craft_button.custom_minimum_size.y = 42.0
	craft_button.visible = false
	craft_button.pressed.connect(_request_craft)
	quest_content.add_child(craft_button)

	map_panel = PanelContainer.new()
	map_panel.name = "SharedMapPanel"
	map_panel.visible = false
	var map_style := StyleBoxFlat.new()
	map_style.bg_color = Color(0.04, 0.1, 0.09, 0.9)
	map_style.border_color = Color("62c4d8")
	map_style.set_border_width_all(2)
	map_style.set_corner_radius_all(10)
	map_style.set_content_margin_all(12)
	map_panel.add_theme_stylebox_override("panel", map_style)
	top_stack.add_child(map_panel)
	map_label = Label.new()
	map_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	map_label.add_theme_color_override("font_color", Color("cbeef1"))
	map_panel.add_child(map_label)

	chronicle_panel = PanelContainer.new()
	chronicle_panel.name = "ChroniclePanel"
	chronicle_panel.visible = false
	var chronicle_style := StyleBoxFlat.new()
	chronicle_style.bg_color = Color(0.12, 0.08, 0.04, 0.9)
	chronicle_style.border_color = Color("e3bd68")
	chronicle_style.set_border_width_all(2)
	chronicle_style.set_corner_radius_all(10)
	chronicle_style.set_content_margin_all(12)
	chronicle_panel.add_theme_stylebox_override("panel", chronicle_style)
	top_stack.add_child(chronicle_panel)
	chronicle_label = Label.new()
	chronicle_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	chronicle_label.add_theme_color_override("font_color", Color("f4dfae"))
	chronicle_panel.add_child(chronicle_label)

	connection_panel = PanelContainer.new()
	connection_panel.name = "ConnectionPanel"
	top_stack.add_child(connection_panel)
	var connection_content := VBoxContainer.new()
	connection_content.add_theme_constant_override("separation", 8)
	connection_panel.add_child(connection_content)
	address_input = LineEdit.new()
	address_input.text = "ws://127.0.0.1:%d" % DEFAULT_PORT
	address_input.placeholder_text = "Server address"
	connection_content.add_child(address_input)
	room_code_input = LineEdit.new()
	room_code_input.text = DEFAULT_ROOM_CODE
	room_code_input.placeholder_text = "Room code"
	room_code_input.max_length = 16
	connection_content.add_child(room_code_input)
	connect_button = Button.new()
	connect_button.text = "Connect"
	connect_button.custom_minimum_size.y = 46.0
	connect_button.pressed.connect(_connect_to_server)
	connection_content.add_child(connect_button)
	status_label = Label.new()
	status_label.text = "Start the server, then connect."
	status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	connection_content.add_child(status_label)

	debug_panel = PanelContainer.new()
	debug_panel.name = "DebugPanel"
	debug_panel.visible = false
	top_stack.add_child(debug_panel)
	var debug_content := VBoxContainer.new()
	debug_panel.add_child(debug_content)
	inventory_label = Label.new()
	inventory_label.text = "Project bag — Wood: 0  Herb: 0  Repair kit: 0"
	debug_content.add_child(inventory_label)
	combat_label = Label.new()
	combat_label.text = "Health: 3/3  Forest creature: 3/3"
	debug_content.add_child(combat_label)
	world_change_label = Label.new()
	world_change_label.text = "Reputation: 0  Map rumor: Locked"
	world_change_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	debug_content.add_child(world_change_label)
	var controls_hint := Label.new()
	controls_hint.text = "F3 closes debug · V changes view · E use · Space attack · C craft · mouse look · Esc cursor"
	controls_hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	debug_content.add_child(controls_hint)

	interaction_prompt = Label.new()
	interaction_prompt.name = "InteractionPrompt"
	interaction_prompt.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
	interaction_prompt.offset_left = -190.0
	interaction_prompt.offset_top = -106.0
	interaction_prompt.offset_right = 190.0
	interaction_prompt.offset_bottom = -58.0
	interaction_prompt.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	interaction_prompt.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	interaction_prompt.add_theme_font_size_override("font_size", 22)
	interaction_prompt.add_theme_color_override("font_color", Color("e9feff"))
	interaction_prompt.visible = false
	layer.add_child(interaction_prompt)
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
	var interact_button := Button.new()
	interact_button.text = "Use"
	interact_button.custom_minimum_size = Vector2(88.0, 72.0)
	interact_button.pressed.connect(_request_interaction)
	controls.add_child(interact_button)
	var craft_touch_button := Button.new()
	craft_touch_button.text = "Craft"
	craft_touch_button.custom_minimum_size = Vector2(88.0, 72.0)
	craft_touch_button.pressed.connect(_request_craft)
	controls.add_child(craft_touch_button)
	var attack_touch_button := Button.new()
	attack_touch_button.text = "Attack"
	attack_touch_button.custom_minimum_size = Vector2(88.0, 72.0)
	attack_touch_button.pressed.connect(_request_attack)
	controls.add_child(attack_touch_button)
	var camera_touch_button := Button.new()
	camera_touch_button.text = "View"
	camera_touch_button.custom_minimum_size = Vector2(88.0, 72.0)
	camera_touch_button.pressed.connect(_toggle_camera_mode)
	controls.add_child(camera_touch_button)


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


func _request_interaction() -> void:
	if client_connected:
		request_interaction.rpc_id(1)


func _request_craft() -> void:
	if client_connected:
		request_craft_repair_kit.rpc_id(1)


func _request_attack() -> void:
	if client_connected:
		request_attack.rpc_id(1)


func _update_combat_interface(snapshot: Dictionary, creature_defeated: bool) -> void:
	var health := int(snapshot.get("player_health", {}).get(local_token, WorldStateModel.PLAYER_MAX_HEALTH))
	var is_downed := bool(snapshot.get("downed_players", {}).get(local_token, false))
	var creature_text := "defeated" if creature_defeated else "%d/%d" % [int(snapshot.get("creature_health", 0)), WorldStateModel.CREATURE_MAX_HEALTH]
	var guardian_defeated := bool(snapshot.get("ruin_guardian_defeated", false))
	var guardian_text := "defeated" if guardian_defeated else "%d/%d" % [
		int(snapshot.get("ruin_guardian_health", WorldStateModel.RUIN_GUARDIAN_MAX_HEALTH)),
		WorldStateModel.RUIN_GUARDIAN_MAX_HEALTH,
	]
	combat_label.text = "Health: %d/%d%s  Forest creature: %s  Ruin guardian: %s" % [
		health,
		WorldStateModel.PLAYER_MAX_HEALTH,
		" — DOWNED: E returns home; a friend can revive nearby" if is_downed else "",
		creature_text,
		guardian_text,
	]


func _update_quest_interface(
	quest_stage: String,
	materials: Dictionary,
	repairs: Dictionary,
	event_stage: String,
	lit_lanterns: Dictionary,
	exploration_stage: String,
	discoveries: Dictionary,
	route_activated: bool
) -> void:
	var wood_count := int(materials.get("wood", 0))
	var herb_count := int(materials.get("herb", 0))
	var kit_count := int(materials.get("repair_kit", 0))
	inventory_label.text = "Project bag — Wood: %d  Herb: %d  Repair kit: %d" % [wood_count, herb_count, kit_count]
	craft_button.visible = quest_stage == "repair_cottage" and kit_count == 0
	craft_button.disabled = wood_count < 2 or herb_count < 1
	progress_label.visible = false
	quest_title_label.text = "A NEW HOME"
	match quest_stage:
		"meet_mara":
			objective_label.text = "Meet Mara beside the cottage"
			dialogue_label.text = "Walk to Mara and press E to talk."
		"recover_supplies":
			objective_label.text = "Gather materials in the forest"
			progress_label.visible = true
			progress_label.text = "Wood %d/2  ·  Herb %d/1" % [mini(wood_count, 2), mini(herb_count, 1)]
			dialogue_label.text = "Press E beside wood and herbs. Recover the lost supplies too."
		"return_to_mara":
			objective_label.text = "Return the supplies to Mara"
			dialogue_label.text = "Meet Mara beside the cottage and press E."
		"repair_cottage":
			var repair_count := 0
			for repaired: bool in repairs.values():
				if repaired:
					repair_count += 1
			progress_label.visible = true
			progress_label.text = "Cottage repairs  %d / 3" % repair_count
			if kit_count == 0:
				objective_label.text = "Craft the cottage repair kit"
				dialogue_label.text = "You need 2 wood and 1 herb. Press C or use the button."
			else:
				objective_label.text = "Repair the cottage"
				dialogue_label.text = "Use E at each bright blue REPAIR marker in front of the cottage."
		"home_repaired":
			if event_stage != "complete":
				quest_title_label.text = "WELCOME LIGHTS"
			match event_stage:
				"invitation":
					objective_label.text = "Talk to Mara about the neighborhood gathering"
					dialogue_label.text = "Your repaired home has drawn attention. Mara is waiting by the cottage."
				"lighting":
					var lit_count := 0
					for is_lit: bool in lit_lanterns.values():
						if is_lit:
							lit_count += 1
					objective_label.text = "Light the neighborhood welcome lanterns"
					progress_label.visible = true
					progress_label.text = "Welcome lanterns  %d / 3" % lit_count
					dialogue_label.text = "Mara moved to the gathering place. Use E at each amber marker."
				"complete":
					quest_title_label.text = "BEYOND THE ROAD"
					match exploration_stage:
						"follow_rumor":
							objective_label.text = "Follow the northern road beyond the forest"
							dialogue_label.text = "The shared map holds a rumor of the Old Stone Ruins."
						"find_ruins":
							objective_label.text = "Explore Northwood and find the Old Stone Ruins"
							dialogue_label.text = "Northwood is now revealed for everyone in the room."
						"defeat_guardian":
							objective_label.text = "Overcome the guardian at the Old Stone Ruins"
							progress_label.visible = true
							progress_label.text = "Old Stone Ruins discovered · Guardian blocks the waystone"
							dialogue_label.text = "Use Space or Attack nearby. Position together and revive fallen friends."
						"restore_waystone":
							objective_label.text = "Restore the ruin waystone"
							dialogue_label.text = "Use E at the bright blue marker inside the ruins."
						"complete":
							objective_label.text = "The route to the Old Stone Ruins is restored"
							progress_label.visible = true
							progress_label.text = "Northwood and ruins mapped · Waystone route active"
							dialogue_label.text = "Use E at either glowing waystone to travel between home and the ruins."
						_:
							objective_label.text = "The neighborhood remembers you"
							dialogue_label.text = "Mara: This place feels different because you chose to stay."
				_:
					objective_label.text = "Cottage repaired — welcome home!"
					dialogue_label.text = "Mara: Welcome home."


func _update_interaction_prompt(
	quest_stage: String,
	has_repair_kit: bool,
	repairs: Dictionary,
	event_stage: String,
	lit_lanterns: Dictionary,
	player_position: Vector3
) -> void:
	interaction_prompt.visible = false
	if not player_position.is_finite():
		return
	var action_name := "USE" if OS.has_feature("mobile") else "E"
	var is_downed := bool(latest_snapshot.get("downed_players", {}).get(local_token, false))
	if is_downed:
		interaction_prompt.text = "%s  ·  Return to the cottage" % action_name
		interaction_prompt.visible = true
		return
	var guardian_defeated := bool(latest_snapshot.get("ruin_guardian_defeated", false))
	var route_activated := bool(latest_snapshot.get("ruin_waystone_activated", false))
	if guardian_defeated and player_position.distance_to(WorldStateModel.RUIN_WAYSTONE_POSITION) <= WorldStateModel.INTERACTION_RADIUS + 0.35:
		interaction_prompt.text = "%s  ·  %s" % [action_name, "Travel home" if route_activated else "Restore waystone"]
		interaction_prompt.visible = true
		return
	if route_activated and player_position.distance_to(WorldStateModel.HOME_WAYSTONE_POSITION) <= WorldStateModel.INTERACTION_RADIUS + 0.35:
		interaction_prompt.text = "%s  ·  Travel to Old Stone Ruins" % action_name
		interaction_prompt.visible = true
		return
	if quest_stage == "repair_cottage" and has_repair_kit:
		for part_id: String in WorldStateModel.REPAIR_POSITIONS:
			if bool(repairs.get(part_id, false)):
				continue
			if player_position.distance_to(WorldStateModel.REPAIR_POSITIONS[part_id]) <= WorldStateModel.INTERACTION_RADIUS + 0.35:
				interaction_prompt.text = "%s  ·  Repair %s" % [action_name, WorldStateModel.REPAIR_LABELS[part_id].capitalize()]
				interaction_prompt.visible = true
				return
	if event_stage == "lighting":
		for lantern_id: String in WorldStateModel.WELCOME_LANTERN_POSITIONS:
			if bool(lit_lanterns.get(lantern_id, false)):
				continue
			if player_position.distance_to(WorldStateModel.WELCOME_LANTERN_POSITIONS[lantern_id]) <= WorldStateModel.INTERACTION_RADIUS + 0.35:
				interaction_prompt.text = "%s  ·  Light %s" % [action_name, WorldStateModel.WELCOME_LANTERN_LABELS[lantern_id].capitalize()]
				interaction_prompt.visible = true
				return


func _shared_map_text(discoveries: Dictionary, route_activated: bool) -> String:
	var northwood := "charted" if bool(discoveries.get("northwood", false)) else "unexplored"
	var ruins := "charted" if bool(discoveries.get("old_stone_ruins", false)) else "rumored"
	var route := "waystone route active" if route_activated else "first journey required"
	return "SHARED MAP\n• Arrival Ward — home\n• Northwood — %s\n• Old Stone Ruins — %s\n• Route — %s" % [northwood, ruins, route]


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
	player_mesh.visible = player_token != local_token or camera_mode == CAMERA_THIRD_PERSON
	add_child(player_mesh)
	player_nodes[player_token] = player_mesh
	return player_mesh


func _status(message: String) -> void:
	status_label.text = message
	print(message)
