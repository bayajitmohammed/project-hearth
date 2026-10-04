extends Node3D

const DEFAULT_PORT := 9080
const SAVE_PATH := "user://slice_zero_world.json"
const OFFLINE_SAVE_PATH := "user://offline_world.json"
const HOSTED_SAVE_PATH := "user://hosted_world.json"
const DEFAULT_ROOM_CODE := "HEARTH"
const MAX_PLAYERS := 8
const CAMERA_FIRST_PERSON := "first_person"
const CAMERA_THIRD_PERSON := "third_person"
const CAMERA_MIN_DISTANCE := 3.0
const CAMERA_MAX_DISTANCE := 8.0
const CAMERA_MOUSE_SENSITIVITY := 0.004
const CAMERA_TOUCH_SENSITIVITY := 0.006
const MOBILE_TAP_DRAG_THRESHOLD := 18.0
const MOBILE_AIM_RADIUS := 64.0
const MOBILE_TAP_RADIUS := 92.0
const CAMERA_CONTROLLER_SPEED := 2.2
const CAMERA_MIN_PITCH := deg_to_rad(-65.0)
const CAMERA_MAX_PITCH := deg_to_rad(65.0)
const FIRST_PERSON_EYE_OFFSET := Vector3(0.0, 0.62, 0.0)
const THIRD_PERSON_SHOULDER_HEIGHT := 0.35
const THIRD_PERSON_SHOULDER_OFFSET := 0.75
const PLAYER_POSITION_SMOOTHING_SPEED := 18.0
const WorldStateModel = preload("res://scripts/world_state.gd")
const GrayboxWorldBuilder = preload("res://scripts/graybox_world.gd")
const TouchJoystick = preload("res://scripts/touch_joystick.gd")

var world_state := WorldStateModel.new()
var peer_to_token: Dictionary = {}
var peer_inputs: Dictionary = {}
var player_nodes: Dictionary = {}
var player_target_positions: Dictionary = {}
var touch_movement := Vector2.ZERO
var local_token := ""
var is_server := false
var client_connected := false
var local_authority_player := false
var broadcasts_to_clients := false
var snapshot_accumulator := 0.0
var save_path := SAVE_PATH
var server_room_code := DEFAULT_ROOM_CODE
var server_port := DEFAULT_PORT
var save_recovered_from_backup := false
var latest_snapshot: Dictionary = {}
var camera_yaw := 0.0
var camera_pitch := 0.0
var camera_distance := 5.5
var camera_mode := CAMERA_FIRST_PERSON
var camera_touch_index := -1
var camera_touch_start_position := Vector2.ZERO
var camera_touch_drag_distance := 0.0
var local_input_enabled := true
var mobile_context_target: Dictionary = {}

var status_label: Label
var quest_title_label: Label
var objective_label: Label
var dialogue_label: Label
var relationship_label: Label
var progress_label: Label
var interaction_prompt: Label
var combat_warning_label: Label
var inventory_label: Label
var combat_label: Label
var world_change_label: Label
var mastery_label: Label
var address_input: LineEdit
var room_code_input: LineEdit
var connect_button: Button
var offline_button: Button
var host_button: Button
var session_status_label: Label
var world_time_label: Label
var touch_controls: Control
var mobile_crosshair: Label
var mobile_context_button: Button
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
var world_environment: WorldEnvironment
var sun_light: DirectionalLight3D
var rain_particles: CPUParticles3D
var mara_node: Node3D
var resource_nodes: Dictionary = {}
var repair_nodes: Dictionary = {}
var repair_result_nodes: Dictionary = {}
var outing_kit_rack: Node3D
var outing_kit_marker: Node3D
var cottage_rest_marker: Node3D
var welcome_lantern_markers: Dictionary = {}
var welcome_lantern_lights: Dictionary = {}
var creature_node: MeshInstance3D
var rumor_marker: MeshInstance3D
var ruin_guardian_node: MeshInstance3D
var waystone_marker: Node3D
var home_waystone: Node3D
var ruin_waystone: Node3D
var waystone_glows: Dictionary = {}
var garden_plants: Dictionary = {}
var garden_markers: Dictionary = {}
var cookfire_marker: Node3D
var market_marker: Node3D
var produce_stall: Node3D
var supply_marker: Node3D
var hearthbloom_project: Node3D
var hearthbloom_marker: Node3D
var hearthbloom_blooms: Node3D
var recovery_pack_nodes: Dictionary = {}
var festival_arch: Node3D
var festival_decorations: Node3D
var festival_checkpoint_nodes: Dictionary = {}


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
		if "--offline" in OS.get_cmdline_user_args():
			_start_local_world(false, _read_save_path_argument(OFFLINE_SAVE_PATH))
		elif "--host" in OS.get_cmdline_user_args():
			_start_local_world(true, _read_save_path_argument(HOSTED_SAVE_PATH), _read_port_argument())
		elif not connect_address.is_empty():
			address_input.text = connect_address
			_connect_to_server.call_deferred()


func _physics_process(delta: float) -> void:
	if is_server:
		if local_authority_player and local_input_enabled:
			_update_local_authority_input()
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
	if Input.is_action_just_pressed("power_strike"):
		_request_power_strike()
	if Input.is_action_just_pressed("brace"):
		_request_brace()
	if Input.is_action_just_pressed("use_provision"):
		_request_use_provision()
	if Input.is_action_just_pressed("toggle_debug"):
		debug_panel.visible = not debug_panel.visible
	if Input.is_action_just_pressed("toggle_camera"):
		_toggle_camera_mode()


func _update_local_authority_input() -> void:
	var input_vector := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	input_vector = (input_vector + _touch_input_vector()).limit_length(1.0)
	peer_inputs[1] = input_vector.rotated(-camera_yaw)
	if Input.is_action_just_pressed("interact"):
		_try_interaction(local_token)
	if Input.is_action_just_pressed("craft"):
		_try_craft_repair_kit()
	if Input.is_action_just_pressed("attack"):
		_try_attack(local_token)
	if Input.is_action_just_pressed("power_strike"):
		_try_power_strike(local_token)
	if Input.is_action_just_pressed("brace"):
		_try_brace(local_token)
	if Input.is_action_just_pressed("use_provision"):
		_try_use_trail_provision(local_token)
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
	if _uses_android_touch_controls():
		_update_mobile_targeting()


func _interpolate_player_positions(delta: float) -> void:
	var smoothing_weight := 1.0 - exp(-PLAYER_POSITION_SMOOTHING_SPEED * delta)
	for token: String in player_target_positions:
		if not player_nodes.has(token):
			continue
		var player_node: MeshInstance3D = player_nodes[token]
		player_node.position = player_node.position.lerp(player_target_positions[token], smoothing_weight)


func _unhandled_input(event: InputEvent) -> void:
	if is_server and not local_authority_player:
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
		if event.pressed and event.position.x >= get_viewport().get_visible_rect().size.x * 0.5:
			camera_touch_index = event.index
			camera_touch_start_position = event.position
			camera_touch_drag_distance = 0.0
		elif not event.pressed and event.index == camera_touch_index:
			if _uses_android_touch_controls() and camera_touch_drag_distance <= MOBILE_TAP_DRAG_THRESHOLD:
				_handle_mobile_world_tap(event.position)
			camera_touch_index = -1
	elif event is InputEventScreenDrag and event.index == camera_touch_index:
		camera_touch_drag_distance += event.relative.length()
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
	if not peer_to_token.is_empty() and world_state.simulate_world_clock(delta):
		_save_world()
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
		_publish_snapshot()


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
	var existing_peer = peer_to_token.find_key(player_token)
	if existing_peer != null and int(existing_peer) != sender_id:
		registration_rejected.rpc_id(sender_id, "That player is already active in this room")
		return
	var room_was_empty := peer_to_token.is_empty()
	if room_was_empty:
		world_state.apply_offline_catch_up(int(Time.get_unix_time_from_system()))
	peer_to_token[sender_id] = player_token
	peer_inputs[sender_id] = Vector2.ZERO
	world_state.register_player(player_token)
	world_state.reset_player_combat_timers(player_token)
	_save_world()
	_publish_snapshot()


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
	_try_interaction(peer_to_token[sender_id])


@rpc("any_peer", "call_remote", "reliable")
func request_collect() -> void:
	if not is_server:
		return
	var sender_id := multiplayer.get_remote_sender_id()
	if not peer_to_token.has(sender_id):
		return
	_try_collect(peer_to_token[sender_id])


@rpc("any_peer", "call_remote", "reliable")
func request_craft_repair_kit() -> void:
	if not is_server:
		return
	var sender_id := multiplayer.get_remote_sender_id()
	if not peer_to_token.has(sender_id):
		return
	_try_craft_repair_kit()


@rpc("any_peer", "call_remote", "reliable")
func request_attack() -> void:
	if not is_server:
		return
	var sender_id := multiplayer.get_remote_sender_id()
	if not peer_to_token.has(sender_id):
		return
	_try_attack(peer_to_token[sender_id])


@rpc("any_peer", "call_remote", "reliable")
func request_power_strike() -> void:
	if not is_server:
		return
	var sender_id := multiplayer.get_remote_sender_id()
	if not peer_to_token.has(sender_id):
		return
	_try_power_strike(peer_to_token[sender_id])


@rpc("any_peer", "call_remote", "reliable")
func request_brace() -> void:
	if not is_server:
		return
	var sender_id := multiplayer.get_remote_sender_id()
	if not peer_to_token.has(sender_id):
		return
	_try_brace(peer_to_token[sender_id])


@rpc("any_peer", "call_remote", "reliable")
func request_use_trail_provision() -> void:
	if not is_server:
		return
	var sender_id := multiplayer.get_remote_sender_id()
	if not peer_to_token.has(sender_id):
		return
	_try_use_trail_provision(peer_to_token[sender_id])


func _try_interaction(player_token: String) -> void:
	if world_state.interact(player_token):
		_save_world()
		_publish_snapshot()


func _try_collect(player_token: String) -> void:
	if world_state.try_collect(player_token):
		_save_world()
		_publish_snapshot()


func _try_craft_repair_kit() -> void:
	if world_state.craft_repair_kit():
		_save_world()
		_publish_snapshot()


func _try_attack(player_token: String) -> void:
	if world_state.attack_creature(player_token):
		_save_world()
		_publish_snapshot()


func _try_power_strike(player_token: String) -> void:
	if world_state.power_strike_creature(player_token):
		_save_world()
		_publish_snapshot()


func _try_brace(player_token: String) -> void:
	if world_state.try_brace(player_token):
		_publish_snapshot()


func _try_use_trail_provision(player_token: String) -> void:
	if world_state.try_use_trail_provision(player_token):
		_save_world()
		_publish_snapshot()


func _publish_snapshot() -> void:
	var snapshot := _snapshot_for_clients()
	if local_authority_player:
		receive_snapshot(snapshot)
	if broadcasts_to_clients:
		receive_snapshot.rpc(snapshot)


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
	outing_kit_rack.visible = quest_stage == "home_repaired"
	outing_kit_marker.visible = quest_stage == "home_repaired"
	var local_health := int(snapshot.get("player_health", {}).get(local_token, WorldStateModel.PLAYER_MAX_HEALTH))
	var local_downed := bool(snapshot.get("downed_players", {}).get(local_token, false))
	cottage_rest_marker.visible = (
		quest_stage == "home_repaired"
		and not local_downed
		and local_health < WorldStateModel.PLAYER_MAX_HEALTH
	)
	var lit_lanterns: Dictionary = snapshot.get("lit_welcome_lanterns", {})
	for lantern_id: String in welcome_lantern_markers:
		var is_lit := bool(lit_lanterns.get(lantern_id, false))
		welcome_lantern_markers[lantern_id].visible = event_stage == "lighting" and not is_lit
		welcome_lantern_lights[lantern_id].visible = is_lit
	mara_node.position = snapshot.get("mara_position", WorldStateModel.MARA_POSITION)
	var world_minute := int(snapshot.get("world_minute", WorldStateModel.WORLD_START_MINUTE))
	var weather := str(snapshot.get("world_weather", "clear"))
	world_time_label.text = _world_time_text(
		int(snapshot.get("world_day", 1)),
		world_minute,
		str(snapshot.get("world_time_period", "Afternoon")),
		str(snapshot.get("world_weather_label", "Clear skies")),
		str(snapshot.get("mara_activity", "waiting by the cottage"))
	)
	world_time_label.visible = true
	_apply_world_atmosphere(world_minute, weather)
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
		bool(snapshot.get("ruin_waystone_activated", false)),
		str(snapshot.get("livelihood_stage", "locked")),
		snapshot.get("harvested_garden_plots", {}),
		int(snapshot.get("stews_delivered", 0)),
		snapshot.get("player_mastery", {}).get(local_token, {}),
		int(snapshot.get("active_player_count", 0)),
		int(snapshot.get("max_players", MAX_PLAYERS)),
		int(snapshot.get("pantry_stock", 0)),
		int(snapshot.get("player_provisions", {}).get(local_token, 0)),
		int(snapshot.get("player_coins", {}).get(local_token, 0)),
		int(snapshot.get("last_catch_up_units", 0)),
		str(snapshot.get("festival_stage", "locked")),
		snapshot.get("festival_participants", {}),
		snapshot.get("festival_finishers", []),
		str(snapshot.get("festival_last_winner", "")),
		int(snapshot.get("festival_ribbons", {}).get(local_token, 0))
	)
	_update_relationship_interface(snapshot)
	_sync_recovery_packs(snapshot.get("recovery_packs", {}))
	var creature_defeated := bool(snapshot.get("creature_defeated", false))
	creature_node.visible = not creature_defeated
	creature_node.position = snapshot.get("creature_position", WorldStateModel.CREATURE_SPAWN)
	creature_node.scale = Vector3.ONE * (
		1.12 if float(snapshot.get("creature_attack_windup", 0.0)) > 0.0
		else (0.94 if bool(snapshot.get("creature_returning", false)) else 1.0)
	)
	_update_combat_interface(snapshot, creature_defeated)
	var rumor_unlocked := bool(snapshot.get("map_rumor_unlocked", false))
	var discoveries: Dictionary = snapshot.get("shared_map_discoveries", {})
	var exploration_stage := str(snapshot.get("exploration_stage", "locked"))
	var guardian_defeated := bool(snapshot.get("ruin_guardian_defeated", false))
	var route_activated := bool(snapshot.get("ruin_waystone_activated", false))
	var livelihood_stage := str(snapshot.get("livelihood_stage", "locked"))
	var daily_food_order_active := bool(snapshot.get("daily_food_order_active", false))
	var daily_food_order_kind := str(snapshot.get("daily_food_order_kind", ""))
	var food_order_active := livelihood_stage == "food_need" or daily_food_order_active
	var harvested_garden: Dictionary = snapshot.get("harvested_garden_plots", {})
	rumor_marker.visible = rumor_unlocked and not bool(discoveries.get("northwood", false))
	ruin_guardian_node.visible = exploration_stage == "defeat_guardian" and not guardian_defeated
	ruin_guardian_node.position = snapshot.get("ruin_guardian_position", WorldStateModel.RUIN_GUARDIAN_SPAWN)
	ruin_guardian_node.scale = Vector3.ONE * (
		1.12 if float(snapshot.get("ruin_guardian_attack_windup", 0.0)) > 0.0
		else (0.94 if bool(snapshot.get("ruin_guardian_returning", false)) else 1.0)
	)
	waystone_marker.visible = exploration_stage == "restore_waystone" and not route_activated
	home_waystone.visible = route_activated
	ruin_waystone.visible = bool(discoveries.get("old_stone_ruins", false))
	for glow: MeshInstance3D in waystone_glows.values():
		glow.visible = route_activated
	for plot_id: String in garden_plants:
		var harvested := bool(harvested_garden.get(plot_id, false))
		garden_plants[plot_id].visible = food_order_active and not harvested
		garden_markers[plot_id].visible = food_order_active and not harvested
	var moonroot_count := int(materials.get("moonroot", 0))
	var stew_count := int(materials.get("hearth_stew", 0))
	var stews_delivered := int(snapshot.get("stews_delivered", 0))
	var active_stew_deliveries := (
		int(snapshot.get("daily_food_deliveries", 0)) if daily_food_order_active else stews_delivered
	)
	cookfire_marker.visible = (
		food_order_active
		and (livelihood_stage == "food_need" or daily_food_order_kind == WorldStateModel.DAILY_ORDER_HEARTH_STEW)
		and moonroot_count >= 2
		and stew_count + active_stew_deliveries < WorldStateModel.REQUIRED_STEW_DELIVERIES
	)
	market_marker.visible = (
		(livelihood_stage == "food_need" and stew_count > 0)
		or (
			daily_food_order_active
			and daily_food_order_kind == WorldStateModel.DAILY_ORDER_HEARTH_STEW
			and stew_count > 0
		)
		or (
			daily_food_order_active
			and daily_food_order_kind == WorldStateModel.DAILY_ORDER_FRESH_MOONROOT
			and moonroot_count > 0
		)
	)
	var produce_stall_open := bool(snapshot.get("produce_stall_open", false))
	var hearthbloom_complete := bool(snapshot.get("hearthbloom_complete", false))
	produce_stall.visible = produce_stall_open
	supply_marker.visible = produce_stall_open
	hearthbloom_project.visible = produce_stall_open
	hearthbloom_marker.visible = produce_stall_open and not hearthbloom_complete
	hearthbloom_blooms.visible = hearthbloom_complete
	var festival_stage := str(snapshot.get("festival_stage", "locked"))
	festival_arch.visible = festival_stage != "locked"
	festival_decorations.visible = bool(snapshot.get("festival_completed", false))
	for checkpoint_id: String in festival_checkpoint_nodes:
		festival_checkpoint_nodes[checkpoint_id].visible = festival_stage == "racing"
	map_panel.visible = rumor_unlocked
	map_label.text = _shared_map_text(discoveries, route_activated)
	var chronicle: Array = snapshot.get("chronicle", [])
	chronicle_panel.visible = not chronicle.is_empty()
	var chronicle_lines := PackedStringArray()
	for entry in chronicle:
		chronicle_lines.append(str(entry))
	chronicle_label.text = "CHRONICLE (%d)\n• %s" % [chronicle.size(), "\n• ".join(chronicle_lines)] if not chronicle.is_empty() else ""
	var food_status := "Food need %d/%d" % [stews_delivered, WorldStateModel.REQUIRED_STEW_DELIVERIES]
	if livelihood_stage == "complete":
		food_status = "Daily request D%d · %s %d/%d · %s" % [
			int(snapshot.get("daily_food_order_day", 0)),
			str(snapshot.get("daily_food_order_label", "Hearth stew")),
			int(snapshot.get("daily_food_deliveries", 0)),
			int(snapshot.get("daily_food_order_required", WorldStateModel.REQUIRED_STEW_DELIVERIES)),
			str(snapshot.get("daily_food_order_reason", "Shared daily need")),
		] if food_order_active else (
			"Daily request begins next day"
			if int(snapshot.get("daily_food_order_day", 0)) == 0
			else "Daily request complete — next day"
		)
	var world_status_parts := PackedStringArray([
		"Reputation: %d" % int(snapshot.get("reputation", 0)),
		"Morale: %d" % int(snapshot.get("neighborhood_morale", 0)),
		food_status,
	])
	if produce_stall_open:
		world_status_parts.append(
			"Hearthbloom complete"
			if hearthbloom_complete
			else "Hearthbloom %d/%d" % [
				int(snapshot.get("hearthbloom_contributions", 0)),
				WorldStateModel.HEARTHBLOOM_REQUIRED_COINS,
			]
		)
	world_status_parts.append("Chronicle entries: %d" % chronicle.size())
	world_change_label.text = "  ".join(world_status_parts)
	var mastery: Dictionary = snapshot.get("player_mastery", {}).get(local_token, {})
	mastery_label.text = _mastery_text(mastery)
	connection_panel.visible = false
	if touch_controls != null:
		touch_controls.visible = true


@rpc("authority", "call_remote", "reliable")
func registration_rejected(reason: String) -> void:
	client_connected = false
	if touch_controls != null:
		touch_controls.visible = false
	_release_mouse()
	multiplayer.multiplayer_peer = OfflineMultiplayerPeer.new()
	connect_button.disabled = false
	room_code_input.editable = true
	connection_panel.visible = true
	_status(reason)


func _start_server(port: int, bind_address: String = "*") -> void:
	is_server = true
	broadcasts_to_clients = true
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


func _start_offline_world() -> void:
	_start_local_world(false, OFFLINE_SAVE_PATH)


func _start_lan_world() -> void:
	_start_local_world(true, HOSTED_SAVE_PATH)


func _start_local_world(
	allow_lan_connections: bool, world_save_path: String, requested_port: int = DEFAULT_PORT
) -> void:
	server_room_code = room_code_input.text.strip_edges().to_upper()
	if server_room_code.is_empty():
		server_room_code = DEFAULT_ROOM_CODE
		room_code_input.text = server_room_code
	save_path = world_save_path
	server_port = requested_port
	is_server = true
	local_authority_player = true
	broadcasts_to_clients = false
	peer_to_token.clear()
	peer_inputs.clear()
	latest_snapshot.clear()
	world_state = WorldStateModel.new()
	_load_world()
	if allow_lan_connections:
		if OS.has_feature("web"):
			is_server = false
			local_authority_player = false
			_status("Browser builds can play offline or join a room, but cannot host one")
			return
		var web_socket_peer := WebSocketMultiplayerPeer.new()
		var error := web_socket_peer.create_server(server_port, "*")
		if error != OK:
			is_server = false
			local_authority_player = false
			_status("LAN host failed: %s" % error_string(error))
			return
		multiplayer.multiplayer_peer = web_socket_peer
		broadcasts_to_clients = true
	else:
		multiplayer.multiplayer_peer = OfflineMultiplayerPeer.new()
		broadcasts_to_clients = false
	var now := int(Time.get_unix_time_from_system())
	world_state.apply_offline_catch_up(now)
	peer_to_token[1] = local_token
	peer_inputs[1] = Vector2.ZERO
	world_state.register_player(local_token)
	client_connected = true
	_save_world()
	connection_panel.visible = false
	if touch_controls != null:
		touch_controls.visible = true
	_capture_mouse()
	var mode_status := _local_world_status(allow_lan_connections)
	_status(mode_status)
	session_status_label.text = mode_status
	session_status_label.visible = true
	receive_snapshot(_snapshot_for_clients())


func _local_world_status(allow_lan_connections: bool) -> String:
	if not allow_lan_connections:
		return "Playing offline — this world stays on this device"
	var address := _preferred_lan_address()
	return "Hosting LAN room %s at ws://%s:%d" % [server_room_code, address, server_port]


func _preferred_lan_address() -> String:
	var ten_address := ""
	var seventeen_address := ""
	for address: String in IP.get_local_addresses():
		if address.begins_with("192.168."):
			return address
		if address.begins_with("10.") and ten_address.is_empty():
			ten_address = address
		if address.begins_with("172."):
			var parts := address.split(".")
			if (
				parts.size() == 4
				and int(parts[1]) >= 16
				and int(parts[1]) <= 31
				and seventeen_address.is_empty()
			):
				seventeen_address = address
	if not ten_address.is_empty():
		return ten_address
	if not seventeen_address.is_empty():
		return seventeen_address
	return "127.0.0.1"


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
	if touch_controls != null:
		touch_controls.visible = false
	_release_mouse()
	_status("Could not connect")
	connect_button.disabled = false
	connection_panel.visible = true


func _on_server_disconnected() -> void:
	client_connected = false
	if touch_controls != null:
		touch_controls.visible = false
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
	if peer_to_token.has(peer_id):
		world_state.remove_festival_participant(peer_to_token[peer_id])
	peer_inputs.erase(peer_id)
	peer_to_token.erase(peer_id)
	if peer_to_token.is_empty():
		world_state.mark_world_empty(int(Time.get_unix_time_from_system()))
	_save_world()


func _exit_tree() -> void:
	if is_server and local_authority_player:
		world_state.remove_festival_participant(local_token)
		world_state.mark_world_empty(int(Time.get_unix_time_from_system()))
		_save_world()


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
		"player_attack_recovery": world_state.player_attack_recovery.duplicate(),
		"player_brace_time": world_state.player_brace_time.duplicate(),
		"player_brace_cooldown": world_state.player_brace_cooldown.duplicate(),
		"creature_position": world_state.creature_position,
		"creature_health": world_state.creature_health,
		"creature_defeated": world_state.creature_defeated,
		"creature_attack_windup": world_state.creature_attack_windup,
		"creature_attack_target": world_state.creature_attack_target,
		"creature_returning": world_state.creature_returning,
		"reputation": world_state.reputation,
		"map_rumor_unlocked": world_state.map_rumor_unlocked,
		"mara_position": world_state.mara_position,
		"mara_activity": world_state.mara_activity,
		"world_day": world_state.world_day,
		"world_minute": world_state.world_minute,
		"world_time_period": world_state.world_time_period(),
		"world_weather": world_state.world_weather(),
		"world_weather_label": world_state.world_weather_label(),
		"neighborhood_event_stage": world_state.neighborhood_event_stage,
		"lit_welcome_lanterns": world_state.lit_welcome_lanterns.duplicate(),
		"neighborhood_morale": world_state.neighborhood_morale,
		"chronicle": world_state.chronicle.duplicate(),
		"shared_map_discoveries": world_state.shared_map_discoveries.duplicate(),
		"exploration_stage": world_state.exploration_stage,
		"ruin_guardian_position": world_state.ruin_guardian_position,
		"ruin_guardian_health": world_state.ruin_guardian_health,
		"ruin_guardian_defeated": world_state.ruin_guardian_defeated,
		"ruin_guardian_attack_windup": world_state.ruin_guardian_attack_windup,
		"ruin_guardian_attack_target": world_state.ruin_guardian_attack_target,
		"ruin_guardian_returning": world_state.ruin_guardian_returning,
		"ruin_waystone_activated": world_state.ruin_waystone_activated,
		"livelihood_stage": world_state.livelihood_stage,
		"harvested_garden_plots": world_state.harvested_garden_plots.duplicate(),
		"stews_delivered": world_state.stews_delivered,
		"produce_stall_open": world_state.produce_stall_open,
		"daily_food_order_active": world_state.daily_food_order_active,
		"daily_food_order_day": world_state.daily_food_order_day,
		"daily_food_order_kind": world_state.daily_food_order_kind,
		"daily_food_deliveries": world_state.daily_food_deliveries,
		"daily_food_order_label": world_state.daily_food_order_label(),
		"daily_food_order_required": world_state.daily_food_order_required(),
		"daily_food_order_reason": world_state.daily_food_order_reason(),
		"player_mastery": world_state.player_mastery.duplicate(true),
		"player_relationships": world_state.player_relationships.duplicate(true),
		"player_npc_check_in_day": world_state.player_npc_check_in_day.duplicate(true),
		"player_outing_kits": world_state.player_outing_kits.duplicate(),
		"pantry_stock": world_state.pantry_stock,
		"last_catch_up_units": world_state.last_catch_up_units,
		"player_provisions": world_state.player_provisions.duplicate(),
		"player_coins": world_state.player_coins.duplicate(),
		"recovery_packs": world_state.recovery_packs.duplicate(true),
		"hearthbloom_contributions": world_state.hearthbloom_contributions,
		"hearthbloom_complete": world_state.hearthbloom_complete,
		"festival_stage": world_state.festival_stage,
		"festival_completed": world_state.festival_completed,
		"festival_ribbons": world_state.festival_ribbons.duplicate(),
		"festival_last_winner": world_state.festival_last_winner,
		"festival_participants": world_state.festival_participants.duplicate(),
		"festival_finishers": world_state.festival_finishers.duplicate(),
		"active_player_count": peer_to_token.size(),
		"max_players": MAX_PLAYERS,
		"room_code": server_room_code,
	}


func _save_world() -> void:
	var temporary_path := save_path + ".tmp"
	var backup_path := save_path + ".bak"
	var file := FileAccess.open(temporary_path, FileAccess.WRITE)
	if file == null:
		return
	file.store_string(JSON.stringify(world_state.to_dictionary()))
	file.flush()
	file.close()

	var absolute_save_path := ProjectSettings.globalize_path(save_path)
	var absolute_temporary_path := ProjectSettings.globalize_path(temporary_path)
	var absolute_backup_path := ProjectSettings.globalize_path(backup_path)
	if FileAccess.file_exists(save_path):
		if save_recovered_from_backup:
			DirAccess.remove_absolute(absolute_save_path)
		else:
			if FileAccess.file_exists(backup_path):
				DirAccess.remove_absolute(absolute_backup_path)
			if DirAccess.rename_absolute(absolute_save_path, absolute_backup_path) != OK:
				DirAccess.remove_absolute(absolute_temporary_path)
				return
	if DirAccess.rename_absolute(absolute_temporary_path, absolute_save_path) != OK:
		if not FileAccess.file_exists(save_path) and FileAccess.file_exists(backup_path):
			DirAccess.rename_absolute(absolute_backup_path, absolute_save_path)
		return
	save_recovered_from_backup = false


func _load_world() -> void:
	var parsed: Variant = _read_world_dictionary(save_path)
	if parsed is Dictionary:
		world_state.load_dictionary(parsed)
		save_recovered_from_backup = false
		return
	var backup_path := save_path + ".bak"
	var backup: Variant = _read_world_dictionary(backup_path)
	if backup is Dictionary:
		world_state.load_dictionary(backup)
		save_recovered_from_backup = true
		_status("Recovered world from the previous valid save")


func _read_world_dictionary(path: String) -> Variant:
	if not FileAccess.file_exists(path):
		return null
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return null
	var json := JSON.new()
	if json.parse(file.get_as_text()) != OK:
		return null
	return json.data


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


func _read_save_path_argument(default_path: String = SAVE_PATH) -> String:
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with("--save-file="):
			var requested := argument.trim_prefix("--save-file=").strip_edges()
			if not requested.is_empty():
				return requested
	return default_path


func _build_world() -> void:
	var world_nodes := GrayboxWorldBuilder.build(self)
	world_environment = world_nodes["world_environment"]
	sun_light = world_nodes["sun_light"]
	rain_particles = world_nodes["rain_particles"]
	collectible_mesh = world_nodes["collectible"]
	game_camera = world_nodes["camera"]
	mara_node = world_nodes["mara"]
	resource_nodes = world_nodes["resources"]
	repair_nodes = world_nodes["repairs"]
	repair_result_nodes = world_nodes["repair_results"]
	outing_kit_rack = world_nodes["outing_kit_rack"]
	outing_kit_marker = world_nodes["outing_kit_marker"]
	cottage_rest_marker = world_nodes["cottage_rest_marker"]
	welcome_lantern_markers = world_nodes["welcome_lantern_markers"]
	welcome_lantern_lights = world_nodes["welcome_lantern_lights"]
	creature_node = world_nodes["creature"]
	rumor_marker = world_nodes["rumor_marker"]
	ruin_guardian_node = world_nodes["ruin_guardian"]
	waystone_marker = world_nodes["waystone_marker"]
	home_waystone = world_nodes["home_waystone"]
	ruin_waystone = world_nodes["ruin_waystone"]
	waystone_glows = world_nodes["waystone_glows"]
	garden_plants = world_nodes["garden_plants"]
	garden_markers = world_nodes["garden_markers"]
	cookfire_marker = world_nodes["cookfire_marker"]
	market_marker = world_nodes["market_marker"]
	produce_stall = world_nodes["produce_stall"]
	supply_marker = world_nodes["supply_marker"]
	hearthbloom_project = world_nodes["hearthbloom_project"]
	hearthbloom_marker = world_nodes["hearthbloom_marker"]
	hearthbloom_blooms = world_nodes["hearthbloom_blooms"]
	festival_arch = world_nodes["festival_arch"]
	festival_decorations = world_nodes["festival_decorations"]
	festival_checkpoint_nodes = world_nodes["festival_checkpoints"]


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
	relationship_label = Label.new()
	relationship_label.name = "MaraRelationship"
	relationship_label.text = "MARA REMEMBERS YOU · New face · 0"
	relationship_label.add_theme_color_override("font_color", Color("e7c98b"))
	relationship_label.add_theme_font_size_override("font_size", 14)
	quest_content.add_child(relationship_label)
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
	var chronicle_scroll := ScrollContainer.new()
	chronicle_scroll.custom_minimum_size = Vector2(330.0, 150.0)
	chronicle_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	chronicle_panel.add_child(chronicle_scroll)
	chronicle_label = Label.new()
	chronicle_label.custom_minimum_size.x = 330.0
	chronicle_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	chronicle_label.add_theme_color_override("font_color", Color("f4dfae"))
	chronicle_scroll.add_child(chronicle_label)

	connection_panel = PanelContainer.new()
	connection_panel.name = "ConnectionPanel"
	top_stack.add_child(connection_panel)
	var connection_content := VBoxContainer.new()
	connection_content.add_theme_constant_override("separation", 8)
	connection_panel.add_child(connection_content)
	var play_mode_label := Label.new()
	play_mode_label.text = "Choose how to play"
	play_mode_label.add_theme_font_size_override("font_size", 20)
	connection_content.add_child(play_mode_label)
	offline_button = Button.new()
	offline_button.name = "PlayOfflineButton"
	offline_button.text = "Play Offline"
	offline_button.custom_minimum_size.y = 46.0
	offline_button.pressed.connect(_start_offline_world)
	connection_content.add_child(offline_button)
	host_button = Button.new()
	host_button.name = "HostLanButton"
	host_button.text = "Host LAN Game"
	host_button.custom_minimum_size.y = 46.0
	host_button.disabled = OS.has_feature("web")
	host_button.tooltip_text = "Browser builds cannot host a WebSocket room" if OS.has_feature("web") else "Friends on this network can join your room"
	host_button.pressed.connect(_start_lan_world)
	connection_content.add_child(host_button)
	var join_label := Label.new()
	join_label.text = "Join a LAN or online room"
	connection_content.add_child(join_label)
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
	connect_button.text = "Join Room"
	connect_button.custom_minimum_size.y = 46.0
	connect_button.pressed.connect(_connect_to_server)
	connection_content.add_child(connect_button)
	status_label = Label.new()
	status_label.text = "Offline play needs no internet. LAN hosting keeps authority on this device."
	status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	connection_content.add_child(status_label)
	session_status_label = Label.new()
	session_status_label.name = "SessionStatus"
	session_status_label.visible = false
	session_status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	session_status_label.add_theme_color_override("font_color", Color("a8edf0"))
	top_stack.add_child(session_status_label)
	world_time_label = Label.new()
	world_time_label.name = "WorldTime"
	world_time_label.visible = false
	world_time_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	world_time_label.add_theme_color_override("font_color", Color("f4dfae"))
	top_stack.add_child(world_time_label)

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
	combat_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	debug_content.add_child(combat_label)
	world_change_label = Label.new()
	world_change_label.text = "Reputation: 0  Map rumor: Locked"
	world_change_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	debug_content.add_child(world_change_label)
	mastery_label = Label.new()
	mastery_label.text = "Mastery — Farming: 0  Cooking: 0  Trade: 0\nBuilding: 0  Combat: 0  Exploration: 0"
	mastery_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	debug_content.add_child(mastery_label)
	var controls_hint := Label.new()
	controls_hint.text = "F3 closes debug · V view · E use · Space attack · R power · F brace · C craft · mouse look · Esc cursor"
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
	combat_warning_label = Label.new()
	combat_warning_label.name = "CombatWarning"
	combat_warning_label.set_anchors_preset(Control.PRESET_CENTER_TOP)
	combat_warning_label.offset_left = -300.0
	combat_warning_label.offset_top = 24.0
	combat_warning_label.offset_right = 300.0
	combat_warning_label.offset_bottom = 84.0
	combat_warning_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	combat_warning_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	combat_warning_label.add_theme_font_size_override("font_size", 21)
	combat_warning_label.add_theme_color_override("font_color", Color("ffe08a"))
	combat_warning_label.add_theme_color_override("font_outline_color", Color(0.08, 0.04, 0.01, 0.95))
	combat_warning_label.add_theme_constant_override("outline_size", 7)
	combat_warning_label.visible = false
	layer.add_child(combat_warning_label)
	if _uses_android_touch_controls():
		_build_touch_controls(layer)


func _build_touch_controls(layer: CanvasLayer) -> void:
	var safe_insets := _touch_safe_insets()
	var control_scale := _touch_control_scale()
	touch_controls = Control.new()
	touch_controls.name = "TouchControls"
	touch_controls.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	touch_controls.mouse_filter = Control.MOUSE_FILTER_IGNORE
	touch_controls.visible = client_connected
	layer.add_child(touch_controls)

	var joystick := TouchJoystick.new()
	joystick.name = "MovementJoystick"
	joystick.anchor_left = 0.0
	joystick.anchor_top = 0.0
	joystick.anchor_right = 0.5
	joystick.anchor_bottom = 1.0
	joystick.offset_left = 0.0
	joystick.offset_top = 0.0
	joystick.offset_right = 0.0
	joystick.offset_bottom = 0.0
	joystick.visual_diameter = 168.0 * control_scale
	joystick.horizontal_inset = 28.0 * control_scale + safe_insets.x
	joystick.value_changed.connect(_set_touch_movement)
	touch_controls.add_child(joystick)

	mobile_crosshair = Label.new()
	mobile_crosshair.name = "MobileCrosshair"
	mobile_crosshair.text = "+"
	mobile_crosshair.set_anchors_preset(Control.PRESET_CENTER)
	mobile_crosshair.offset_left = -22.0 * control_scale
	mobile_crosshair.offset_top = -24.0 * control_scale
	mobile_crosshair.offset_right = 22.0 * control_scale
	mobile_crosshair.offset_bottom = 24.0 * control_scale
	mobile_crosshair.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	mobile_crosshair.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	mobile_crosshair.mouse_filter = Control.MOUSE_FILTER_IGNORE
	mobile_crosshair.add_theme_font_size_override("font_size", roundi(30.0 * control_scale))
	mobile_crosshair.add_theme_color_override("font_color", Color(0.92, 1.0, 1.0, 0.72))
	touch_controls.add_child(mobile_crosshair)

	mobile_context_button = _create_touch_action_button(
		"Use", "ContextAction", Vector2(150.0, 58.0) * control_scale, roundi(19.0 * control_scale)
	)
	mobile_context_button.visible = false
	mobile_context_button.pressed.connect(_activate_mobile_context_target)
	touch_controls.add_child(mobile_context_button)


func _create_touch_action_button(label: String, node_name: String, minimum_size: Vector2, font_size: int) -> Button:
	var button := Button.new()
	button.name = node_name
	button.text = label
	button.custom_minimum_size = minimum_size
	button.focus_mode = Control.FOCUS_NONE
	button.add_theme_font_size_override("font_size", font_size)
	button.add_theme_color_override("font_color", Color(0.92, 1.0, 1.0, 0.9))
	button.add_theme_color_override("font_hover_color", Color.WHITE)
	button.add_theme_color_override("font_pressed_color", Color.WHITE)
	button.add_theme_stylebox_override("normal", _touch_button_style(0.2, 0.42))
	button.add_theme_stylebox_override("hover", _touch_button_style(0.28, 0.58))
	button.add_theme_stylebox_override("pressed", _touch_button_style(0.44, 0.78))
	return button


func _touch_button_style(background_alpha: float, border_alpha: float) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.035, 0.08, 0.1, background_alpha)
	style.border_color = Color(0.72, 0.96, 0.98, border_alpha)
	style.set_border_width_all(2)
	style.set_corner_radius_all(40)
	style.set_content_margin_all(8)
	return style


func _touch_control_scale() -> float:
	var viewport_size := get_viewport().get_visible_rect().size
	var short_side := minf(viewport_size.x, viewport_size.y)
	return clampf(short_side / 720.0, 0.85, 1.25) * 1.16


func _uses_android_touch_controls() -> bool:
	return OS.get_name() == "Android"


func _touch_safe_insets() -> Vector4:
	var screen_size := Vector2(DisplayServer.screen_get_size())
	var safe_area := Rect2(DisplayServer.get_display_safe_area())
	var viewport_size := get_viewport().get_visible_rect().size
	if screen_size.x <= 0.0 or screen_size.y <= 0.0 or safe_area.size.x <= 0.0 or safe_area.size.y <= 0.0:
		return Vector4.ZERO
	var scale := viewport_size / screen_size
	return Vector4(
		safe_area.position.x * scale.x,
		safe_area.position.y * scale.y,
		maxf(screen_size.x - safe_area.end.x, 0.0) * scale.x,
		maxf(screen_size.y - safe_area.end.y, 0.0) * scale.y
	)


func _set_touch_movement(value: Vector2) -> void:
	touch_movement = value


func _touch_input_vector() -> Vector2:
	return touch_movement


func _update_mobile_targeting() -> void:
	if mobile_context_button == null or mobile_crosshair == null:
		return
	if touch_controls == null or not touch_controls.visible or not client_connected:
		mobile_context_target = {}
		mobile_context_button.visible = false
		return
	var center := get_viewport().get_visible_rect().size * 0.5
	mobile_context_target = _select_mobile_target(
		_mobile_target_candidates(), center, MOBILE_AIM_RADIUS * _touch_control_scale()
	)
	if mobile_context_target.is_empty() and _local_can_use_trail_provision():
		mobile_context_target = {
			"kind": "provision",
			"label": "Use provision",
			"screen_position": center,
		}
	if mobile_context_target.is_empty():
		mobile_crosshair.add_theme_color_override("font_color", Color(0.92, 1.0, 1.0, 0.72))
		mobile_context_button.visible = false
		return
	var is_attack := str(mobile_context_target.get("kind", "")) == "attack"
	mobile_crosshair.add_theme_color_override(
		"font_color", Color(1.0, 0.72, 0.48, 0.92) if is_attack else Color(0.65, 1.0, 0.9, 0.92)
	)
	if is_attack:
		if _local_is_targeted_by_attack() and _local_can_brace():
			mobile_context_target = {
				"kind": "brace",
				"label": "Brace",
				"screen_position": mobile_context_target.get("screen_position", center),
			}
		elif _local_can_attack():
			mobile_context_target = {
				"kind": "power_strike",
				"label": "Power strike",
				"screen_position": mobile_context_target.get("screen_position", center),
			}
		else:
			mobile_context_button.visible = false
			return
	mobile_context_button.text = str(mobile_context_target.get("label", "Use"))
	mobile_context_button.visible = true
	var viewport_size := get_viewport().get_visible_rect().size
	var target_position: Vector2 = mobile_context_target.get("screen_position", center)
	var button_size := mobile_context_button.custom_minimum_size
	var desired_position := target_position - Vector2(button_size.x * 0.5, button_size.y + 34.0 * _touch_control_scale())
	mobile_context_button.position = Vector2(
		clampf(desired_position.x, 12.0, viewport_size.x - button_size.x - 12.0),
		clampf(desired_position.y, 12.0, viewport_size.y - button_size.y - 12.0)
	)


func _mobile_target_candidates() -> Array[Dictionary]:
	var candidates: Array[Dictionary] = []
	if game_camera == null or latest_snapshot.is_empty():
		return candidates
	var player_position: Vector3 = latest_snapshot.get("positions", {}).get(local_token, Vector3.INF)
	if not player_position.is_finite():
		return candidates
	var is_downed := bool(latest_snapshot.get("downed_players", {}).get(local_token, false))
	if is_downed:
		candidates.append({
			"kind": "interact",
			"label": "Return home",
			"screen_position": get_viewport().get_visible_rect().size * 0.5,
		})
		return candidates

	var quest_stage := str(latest_snapshot.get("quest_stage", "meet_mara"))
	var event_stage := str(latest_snapshot.get("neighborhood_event_stage", "locked"))
	if quest_stage in ["meet_mara", "return_to_mara"] or (quest_stage == "home_repaired" and event_stage == "invitation"):
		_append_mobile_target(candidates, mara_node, "Talk", "interact", WorldStateModel.INTERACTION_RADIUS)
	if quest_stage not in ["meet_mara", "home_repaired"]:
		for resource_node: Node3D in resource_nodes.values():
			_append_mobile_target(candidates, resource_node, "Pick up", "interact", WorldStateModel.INTERACTION_RADIUS)
	if collectible_mesh != null and collectible_mesh.visible:
		_append_mobile_target(candidates, collectible_mesh, "Pick up", "collect", WorldStateModel.PICKUP_RADIUS)
	for repair_node: Node3D in repair_nodes.values():
		_append_mobile_target(candidates, repair_node, "Repair", "interact", WorldStateModel.INTERACTION_RADIUS)
	_append_mobile_target(candidates, outing_kit_marker, "Switch kit", "interact", WorldStateModel.INTERACTION_RADIUS)
	_append_mobile_target(candidates, cottage_rest_marker, "Rest", "interact", WorldStateModel.INTERACTION_RADIUS)
	for lantern_node: Node3D in welcome_lantern_markers.values():
		_append_mobile_target(candidates, lantern_node, "Light", "interact", WorldStateModel.INTERACTION_RADIUS)
	_append_mobile_target(candidates, waystone_marker, "Restore", "interact", WorldStateModel.INTERACTION_RADIUS)
	if bool(latest_snapshot.get("ruin_waystone_activated", false)):
		_append_mobile_target(candidates, home_waystone, "Travel", "interact", WorldStateModel.INTERACTION_RADIUS)
		_append_mobile_target(candidates, ruin_waystone, "Travel", "interact", WorldStateModel.INTERACTION_RADIUS)
	for garden_node: Node3D in garden_plants.values():
		_append_mobile_target(candidates, garden_node, "Harvest", "interact", WorldStateModel.INTERACTION_RADIUS)
	_append_mobile_target(candidates, cookfire_marker, "Cook", "interact", WorldStateModel.INTERACTION_RADIUS)
	_append_mobile_target(candidates, market_marker, "Deliver", "interact", WorldStateModel.INTERACTION_RADIUS)
	if int(latest_snapshot.get("pantry_stock", 0)) > 0:
		_append_mobile_target(candidates, produce_stall, "Take", "interact", WorldStateModel.INTERACTION_RADIUS)
	if (
		bool(latest_snapshot.get("produce_stall_open", false))
		and int(latest_snapshot.get("player_coins", {}).get(local_token, 0)) >= WorldStateModel.TRAIL_PROVISION_PRICE
	):
		_append_mobile_target(candidates, supply_marker, "Buy", "interact", WorldStateModel.INTERACTION_RADIUS)
	if (
		bool(latest_snapshot.get("produce_stall_open", false))
		and not bool(latest_snapshot.get("hearthbloom_complete", false))
		and int(latest_snapshot.get("player_coins", {}).get(local_token, 0)) > 0
	):
		_append_mobile_target(candidates, hearthbloom_marker, "Contribute", "interact", WorldStateModel.INTERACTION_RADIUS)
	var festival_stage := str(latest_snapshot.get("festival_stage", "locked"))
	if festival_stage in ["available", "signup", "results"]:
		var festival_label := "Start" if festival_stage == "signup" else "Join"
		_append_mobile_target(candidates, festival_arch, festival_label, "interact", WorldStateModel.INTERACTION_RADIUS)
	for checkpoint_node: Node3D in festival_checkpoint_nodes.values():
		_append_mobile_target(candidates, checkpoint_node, "Claim", "interact", WorldStateModel.INTERACTION_RADIUS)
	for pack_node: Node3D in recovery_pack_nodes.values():
		_append_mobile_target(candidates, pack_node, "Recover", "interact", WorldStateModel.INTERACTION_RADIUS)
	var downed_players: Dictionary = latest_snapshot.get("downed_players", {})
	var player_health: Dictionary = latest_snapshot.get("player_health", {})
	var can_offer_field_aid := int(latest_snapshot.get("player_provisions", {}).get(local_token, 0)) > 0
	for player_token: String in player_nodes:
		if player_token == local_token:
			continue
		if bool(downed_players.get(player_token, false)):
			_append_mobile_target(candidates, player_nodes[player_token], "Revive", "interact", WorldStateModel.INTERACTION_RADIUS)
		elif can_offer_field_aid and int(player_health.get(player_token, WorldStateModel.PLAYER_MAX_HEALTH)) < WorldStateModel.PLAYER_MAX_HEALTH:
			_append_mobile_target(candidates, player_nodes[player_token], "Aid friend", "interact", WorldStateModel.INTERACTION_RADIUS)
	_append_mobile_target(candidates, creature_node, "", "attack", 2.0)
	_append_mobile_target(candidates, ruin_guardian_node, "", "attack", 2.0)
	return candidates


func _append_mobile_target(
	candidates: Array[Dictionary], node: Node3D, label: String, kind: String, maximum_distance: float
) -> void:
	if node == null or not is_instance_valid(node) or not node.is_visible_in_tree():
		return
	var player_position: Vector3 = latest_snapshot.get("positions", {}).get(local_token, Vector3.INF)
	var target_position := node.global_position + Vector3.UP * 0.65
	if player_position.distance_to(node.global_position) > maximum_distance + 0.35:
		return
	if game_camera.is_position_behind(target_position):
		return
	candidates.append({
		"kind": kind,
		"label": label,
		"screen_position": game_camera.unproject_position(target_position),
	})


func _select_mobile_target(
	candidates: Array[Dictionary], screen_position: Vector2, selection_radius: float
) -> Dictionary:
	var selected: Dictionary = {}
	var nearest_distance := selection_radius
	for candidate: Dictionary in candidates:
		var candidate_position: Vector2 = candidate.get("screen_position", Vector2.INF)
		var distance := candidate_position.distance_to(screen_position)
		if distance <= nearest_distance:
			nearest_distance = distance
			selected = candidate
	return selected


func _handle_mobile_world_tap(screen_position: Vector2) -> void:
	var target := _select_mobile_target(
		_mobile_target_candidates(), screen_position, MOBILE_TAP_RADIUS * _touch_control_scale()
	)
	if target.is_empty():
		return
	match str(target.get("kind", "")):
		"attack":
			_request_attack()
		"collect":
			_request_collect()
		_:
			_request_interaction()


func _activate_mobile_context_target() -> void:
	if mobile_context_target.is_empty():
		return
	match str(mobile_context_target.get("kind", "")):
		"brace":
			_request_brace()
		"power_strike":
			_request_power_strike()
		"collect":
			_request_collect()
		"provision":
			_request_use_provision()
		_:
			_request_interaction()


func _request_interaction() -> void:
	if local_authority_player:
		_try_interaction(local_token)
	elif client_connected:
		request_interaction.rpc_id(1)


func _request_collect() -> void:
	if local_authority_player:
		_try_collect(local_token)
	elif client_connected:
		request_collect.rpc_id(1)


func _request_craft() -> void:
	if local_authority_player:
		_try_craft_repair_kit()
	elif client_connected:
		request_craft_repair_kit.rpc_id(1)


func _request_attack() -> void:
	if local_authority_player:
		_try_attack(local_token)
	elif client_connected:
		request_attack.rpc_id(1)


func _request_power_strike() -> void:
	if local_authority_player:
		_try_power_strike(local_token)
	elif client_connected:
		request_power_strike.rpc_id(1)


func _request_brace() -> void:
	if local_authority_player:
		_try_brace(local_token)
	elif client_connected:
		request_brace.rpc_id(1)


func _request_use_provision() -> void:
	if local_authority_player:
		_try_use_trail_provision(local_token)
	elif client_connected:
		request_use_trail_provision.rpc_id(1)


func _local_can_use_trail_provision() -> bool:
	var is_downed := bool(latest_snapshot.get("downed_players", {}).get(local_token, false))
	var health := int(latest_snapshot.get("player_health", {}).get(local_token, WorldStateModel.PLAYER_MAX_HEALTH))
	var provisions := int(latest_snapshot.get("player_provisions", {}).get(local_token, 0))
	return not is_downed and health < WorldStateModel.PLAYER_MAX_HEALTH and provisions > 0


func _local_can_brace() -> bool:
	var is_downed := bool(latest_snapshot.get("downed_players", {}).get(local_token, false))
	var brace_time := float(latest_snapshot.get("player_brace_time", {}).get(local_token, 0.0))
	var brace_cooldown := float(latest_snapshot.get("player_brace_cooldown", {}).get(local_token, 0.0))
	return not is_downed and brace_time <= 0.0 and brace_cooldown <= 0.0


func _local_can_attack() -> bool:
	var is_downed := bool(latest_snapshot.get("downed_players", {}).get(local_token, false))
	var attack_recovery := float(latest_snapshot.get("player_attack_recovery", {}).get(local_token, 0.0))
	return not is_downed and attack_recovery <= 0.0


func _local_is_targeted_by_attack() -> bool:
	return (
		float(latest_snapshot.get("creature_attack_windup", 0.0)) > 0.0
		and str(latest_snapshot.get("creature_attack_target", "")) == local_token
	) or (
		float(latest_snapshot.get("ruin_guardian_attack_windup", 0.0)) > 0.0
		and str(latest_snapshot.get("ruin_guardian_attack_target", "")) == local_token
	)


func _update_combat_interface(snapshot: Dictionary, creature_defeated: bool) -> void:
	var health := int(snapshot.get("player_health", {}).get(local_token, WorldStateModel.PLAYER_MAX_HEALTH))
	var is_downed := bool(snapshot.get("downed_players", {}).get(local_token, false))
	var attack_recovery := float(snapshot.get("player_attack_recovery", {}).get(local_token, 0.0))
	var attack_text := "ready" if attack_recovery <= 0.0 else "recovering"
	var brace_time := float(snapshot.get("player_brace_time", {}).get(local_token, 0.0))
	var brace_cooldown := float(snapshot.get("player_brace_cooldown", {}).get(local_token, 0.0))
	var brace_text := "braced" if brace_time > 0.0 else ("recovering" if brace_cooldown > 0.0 else "ready")
	var outing_kit := str(
		snapshot.get("player_outing_kits", {}).get(local_token, WorldStateModel.OUTING_KIT_VANGUARD)
	)
	var outing_kit_text := "Guardian" if outing_kit == WorldStateModel.OUTING_KIT_GUARDIAN else "Vanguard"
	var creature_health := int(snapshot.get("creature_health", 0))
	var creature_text := "defeated" if creature_defeated else (
		"returning home (%d/%d)" % [creature_health, WorldStateModel.CREATURE_MAX_HEALTH]
		if bool(snapshot.get("creature_returning", false))
		else "%d/%d" % [creature_health, WorldStateModel.CREATURE_MAX_HEALTH]
	)
	var guardian_defeated := bool(snapshot.get("ruin_guardian_defeated", false))
	var guardian_health := int(snapshot.get("ruin_guardian_health", WorldStateModel.RUIN_GUARDIAN_MAX_HEALTH))
	var guardian_text := "defeated" if guardian_defeated else (
		"returning home (%d/%d)" % [guardian_health, WorldStateModel.RUIN_GUARDIAN_MAX_HEALTH]
		if bool(snapshot.get("ruin_guardian_returning", false))
		else "%d/%d" % [guardian_health, WorldStateModel.RUIN_GUARDIAN_MAX_HEALTH]
	)
	var provision_hint := ""
	if not is_downed and health < WorldStateModel.PLAYER_MAX_HEALTH and int(snapshot.get("player_provisions", {}).get(local_token, 0)) > 0:
		provision_hint = " — Q / controller B uses a trail provision"
	var threat_text := ""
	var local_warnings: Array[String] = []
	if float(snapshot.get("creature_attack_windup", 0.0)) > 0.0:
		var creature_target := str(snapshot.get("creature_attack_target", ""))
		threat_text += "\nWARNING: forest creature targets %s" % _combat_player_name(creature_target)
		if creature_target == local_token:
			local_warnings.append("FOREST CREATURE ATTACK — BRACE OR MOVE")
	if float(snapshot.get("ruin_guardian_attack_windup", 0.0)) > 0.0:
		var guardian_target := str(snapshot.get("ruin_guardian_attack_target", ""))
		threat_text += "\nWARNING: ruin guardian targets %s" % _combat_player_name(guardian_target)
		if guardian_target == local_token:
			local_warnings.append("RUIN GUARDIAN ATTACK — BRACE OR MOVE")
	combat_warning_label.text = "\n".join(local_warnings)
	combat_warning_label.visible = not local_warnings.is_empty()
	combat_label.text = "Health: %d/%d%s%s  Kit: %s  Attack: %s  Brace: %s  Forest creature: %s  Ruin guardian: %s%s" % [
		health,
		WorldStateModel.PLAYER_MAX_HEALTH,
		" — DOWNED: E returns home; a friend can revive nearby" if is_downed else "",
		provision_hint,
		outing_kit_text,
		attack_text,
		brace_text,
		creature_text,
		guardian_text,
		threat_text,
	]


func _combat_player_name(player_token: String) -> String:
	if player_token == local_token:
		return "YOU — brace or move"
	if player_token.is_empty():
		return "—"
	return "friend " + player_token.left(6)


func _update_quest_interface(
	quest_stage: String,
	materials: Dictionary,
	repairs: Dictionary,
	event_stage: String,
	lit_lanterns: Dictionary,
	exploration_stage: String,
	discoveries: Dictionary,
	route_activated: bool,
	livelihood_stage: String,
	harvested_garden: Dictionary,
	stews_delivered: int,
	mastery: Dictionary,
	active_player_count: int,
	max_players: int,
	pantry_stock: int,
	carried_provisions: int,
	coins: int,
	catch_up_units: int,
	festival_stage: String,
	festival_participants: Dictionary,
	festival_finishers: Array,
	festival_last_winner: String,
	festival_ribbon_count: int
) -> void:
	var wood_count := int(materials.get("wood", 0))
	var herb_count := int(materials.get("herb", 0))
	var kit_count := int(materials.get("repair_kit", 0))
	var moonroot_count := int(materials.get("moonroot", 0))
	var stew_count := int(materials.get("hearth_stew", 0))
	inventory_label.text = "Project bag — Wood: %d  Herb: %d  Repair kit: %d  Moonroot: %d  Stew: %d" % [
		wood_count, herb_count, kit_count, moonroot_count, stew_count
	]
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
	if route_activated and livelihood_stage in ["food_need", "complete"]:
		quest_title_label.text = "CHOOSE A LIFE"
		progress_label.visible = true
		if livelihood_stage == "complete":
			quest_title_label.text = "OUR SHARED WORLD"
			objective_label.text = "The shared world is ready for friends"
			progress_label.text = "Players %d/%d · Pantry %d/%d · Your provisions %d · Coin %d" % [
				active_player_count,
				max_players,
				pantry_stock,
				WorldStateModel.PANTRY_MAX_STOCK,
				carried_provisions,
				coins,
			]
			if catch_up_units > 0:
				dialogue_label.text = "While the empty world slept, the produce stall prepared %d safe catch-up provision%s." % [
					catch_up_units,
					"" if catch_up_units == 1 else "s",
				]
			elif pantry_stock > 0:
				dialogue_label.text = "Use E at the produce stall to take one personal trail provision. Friends can recover it if you fall."
			else:
				dialogue_label.text = "Players may come and go without resetting the world. An empty room sleeps safely."
		else:
			var harvest_count := 0
			for is_harvested: bool in harvested_garden.values():
				if is_harvested:
					harvest_count += 1
			if harvest_count < WorldStateModel.GARDEN_PLOT_POSITIONS.size():
				objective_label.text = "Harvest moonroot for the neighborhood food need"
				progress_label.text = "Garden plots %d/%d · Stew delivered %d/%d" % [
					harvest_count,
					WorldStateModel.GARDEN_PLOT_POSITIONS.size(),
					stews_delivered,
					WorldStateModel.REQUIRED_STEW_DELIVERIES,
				]
				dialogue_label.text = "Use E at the purple moonroot plots beside the cottage."
			elif stew_count + stews_delivered < WorldStateModel.REQUIRED_STEW_DELIVERIES:
				objective_label.text = "Cook hearth stew at the cottage fire"
				progress_label.text = "Moonroot %d · Stew ready %d · Delivered %d/%d" % [
					moonroot_count, stew_count, stews_delivered, WorldStateModel.REQUIRED_STEW_DELIVERIES
				]
				dialogue_label.text = "Two moonroot make one stew. Use E at the orange cookfire marker."
			else:
				objective_label.text = "Deliver hearth stew to the market crate"
				progress_label.text = "Stew ready %d · Delivered %d/%d" % [
					stew_count, stews_delivered, WorldStateModel.REQUIRED_STEW_DELIVERIES
				]
				dialogue_label.text = "Use E at the green market marker to supply the neighborhood."
	if livelihood_stage == "complete" and festival_stage != "locked":
		_update_festival_interface(
			festival_stage,
			festival_participants,
			festival_finishers,
			festival_last_winner,
			festival_ribbon_count,
			active_player_count,
			max_players,
			pantry_stock,
			coins
		)


func _update_festival_interface(
	festival_stage: String,
	participants: Dictionary,
	finishers: Array,
	last_winner: String,
	ribbon_count: int,
	active_player_count: int,
	max_players: int,
	pantry_stock: int,
	coins: int
) -> void:
	quest_title_label.text = "GATHER AND CELEBRATE"
	progress_label.visible = true
	var shared_status := "Players %d/%d · Pantry %d/%d · Your ribbons %d · Coin %d" % [
		active_player_count,
		max_players,
		pantry_stock,
		WorldStateModel.PANTRY_MAX_STOCK,
		ribbon_count,
		coins,
	]
	match festival_stage:
		"available":
			objective_label.text = "Join the Hearthlight Circuit at the festival arch"
			progress_label.text = shared_status
			dialogue_label.text = "The festival is open. Use E at the gold arch to opt into a fair checkpoint race."
		"signup":
			progress_label.text = "Entrants %d · %s" % [participants.size(), shared_status]
			if participants.has(local_token):
				objective_label.text = "Start the Hearthlight Circuit when your friends are ready"
				dialogue_label.text = "Use E at the arch again to start. Standard movement is the same for every entrant."
			else:
				objective_label.text = "Join the Hearthlight Circuit before it starts"
				dialogue_label.text = "Use E at the festival arch to opt in."
		"racing":
			if participants.has(local_token):
				var checkpoint := int(participants.get(local_token, 0))
				if checkpoint >= WorldStateModel.FESTIVAL_CHECKPOINT_ORDER.size():
					objective_label.text = "Cheer on the remaining Hearthlight runners"
				else:
					objective_label.text = "Reach festival checkpoint %d of %d" % [
						checkpoint + 1, WorldStateModel.FESTIVAL_CHECKPOINT_ORDER.size()
					]
				progress_label.text = "Checkpoint %d/%d · Finishers %d/%d · Your ribbons %d" % [
					mini(checkpoint, WorldStateModel.FESTIVAL_CHECKPOINT_ORDER.size()),
					WorldStateModel.FESTIVAL_CHECKPOINT_ORDER.size(),
					finishers.size(),
					participants.size(),
					ribbon_count,
				]
				dialogue_label.text = "Use E at the next gold checkpoint. Gear, mastery, and provisions grant no advantage."
			else:
				objective_label.text = "The Hearthlight Circuit is underway"
				progress_label.text = "Finishers %d/%d · %s" % [finishers.size(), participants.size(), shared_status]
				dialogue_label.text = "Only players who opted in can advance the circuit."
		"results":
			objective_label.text = "Celebrate the Hearthlight Circuit"
			progress_label.text = "Winner %s · %s" % [_festival_player_name(last_winner), shared_status]
			dialogue_label.text = "Each finisher earned a cosmetic ribbon. Use E at the arch to gather for another run."
		_:
			objective_label.text = "The Hearthlight Festival is preparing"
			progress_label.text = shared_status
			dialogue_label.text = "The neighborhood gathering place is changing for the celebration."


func _update_interaction_prompt(
	quest_stage: String,
	has_repair_kit: bool,
	repairs: Dictionary,
	event_stage: String,
	lit_lanterns: Dictionary,
	player_position: Vector3
) -> void:
	interaction_prompt.visible = false
	if _uses_android_touch_controls():
		return
	if not player_position.is_finite():
		return
	var action_name := "USE" if OS.has_feature("mobile") else "E"
	var is_downed := bool(latest_snapshot.get("downed_players", {}).get(local_token, false))
	if is_downed:
		interaction_prompt.text = "%s  ·  Return to the cottage" % action_name
		interaction_prompt.visible = true
		return
	var player_positions: Dictionary = latest_snapshot.get("positions", {})
	var player_health: Dictionary = latest_snapshot.get("player_health", {})
	var downed_players: Dictionary = latest_snapshot.get("downed_players", {})
	if int(latest_snapshot.get("player_provisions", {}).get(local_token, 0)) > 0:
		for target_token: String in player_positions:
			if target_token == local_token or bool(downed_players.get(target_token, false)):
				continue
			if int(player_health.get(target_token, WorldStateModel.PLAYER_MAX_HEALTH)) >= WorldStateModel.PLAYER_MAX_HEALTH:
				continue
			if player_position.distance_to(player_positions[target_token]) <= WorldStateModel.INTERACTION_RADIUS + 0.35:
				interaction_prompt.text = "%s  ·  Aid %s with a trail provision" % [
					action_name, _festival_player_name(target_token)
				]
				interaction_prompt.visible = true
				return
	var local_health := int(latest_snapshot.get("player_health", {}).get(local_token, WorldStateModel.PLAYER_MAX_HEALTH))
	if (
		quest_stage == "home_repaired"
		and local_health < WorldStateModel.PLAYER_MAX_HEALTH
		and player_position.distance_to(WorldStateModel.COTTAGE_REST_POSITION) <= WorldStateModel.INTERACTION_RADIUS + 0.35
	):
		interaction_prompt.text = "%s  ·  Rest and recover" % action_name
		interaction_prompt.visible = true
		return
	if (
		quest_stage == "home_repaired"
		and player_position.distance_to(WorldStateModel.GEAR_RACK_POSITION) <= WorldStateModel.INTERACTION_RADIUS + 0.35
	):
		var current_kit := str(
			latest_snapshot.get("player_outing_kits", {}).get(
				local_token, WorldStateModel.OUTING_KIT_VANGUARD
			)
		)
		var next_kit := "Guardian" if current_kit == WorldStateModel.OUTING_KIT_VANGUARD else "Vanguard"
		interaction_prompt.text = "%s  ·  Equip %s kit" % [action_name, next_kit]
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
	var livelihood_stage := str(latest_snapshot.get("livelihood_stage", "locked"))
	var daily_food_order_active := bool(latest_snapshot.get("daily_food_order_active", false))
	var daily_food_order_kind := str(latest_snapshot.get("daily_food_order_kind", ""))
	var food_order_active := livelihood_stage == "food_need" or daily_food_order_active
	var local_mastery: Dictionary = latest_snapshot.get("player_mastery", {}).get(local_token, {})
	var festival_stage := str(latest_snapshot.get("festival_stage", "locked"))
	var festival_participants: Dictionary = latest_snapshot.get("festival_participants", {})
	if festival_stage in ["available", "results"] and player_position.distance_to(WorldStateModel.FESTIVAL_ARCH_POSITION) <= WorldStateModel.INTERACTION_RADIUS + 0.35:
		interaction_prompt.text = "%s  ·  Join the Hearthlight Circuit" % action_name
		interaction_prompt.visible = true
		return
	if festival_stage == "signup" and player_position.distance_to(WorldStateModel.FESTIVAL_ARCH_POSITION) <= WorldStateModel.INTERACTION_RADIUS + 0.35:
		interaction_prompt.text = "%s  ·  %s" % [
			action_name,
			"Start the circuit" if festival_participants.has(local_token) else "Join the circuit",
		]
		interaction_prompt.visible = true
		return
	if festival_stage == "racing" and festival_participants.has(local_token):
		var checkpoint_index := int(festival_participants.get(local_token, 0))
		if checkpoint_index < WorldStateModel.FESTIVAL_CHECKPOINT_ORDER.size():
			var checkpoint_id: String = WorldStateModel.FESTIVAL_CHECKPOINT_ORDER[checkpoint_index]
			var checkpoint_position: Vector3 = WorldStateModel.FESTIVAL_CHECKPOINT_POSITIONS[checkpoint_id]
			if player_position.distance_to(checkpoint_position) <= WorldStateModel.INTERACTION_RADIUS + 0.35:
				interaction_prompt.text = "%s  ·  Claim checkpoint %d/%d" % [
					action_name, checkpoint_index + 1, WorldStateModel.FESTIVAL_CHECKPOINT_ORDER.size()
				]
				interaction_prompt.visible = true
				return
	var recovery_packs: Dictionary = latest_snapshot.get("recovery_packs", {})
	for owner_token: String in recovery_packs:
		var pack: Dictionary = recovery_packs[owner_token]
		var pack_position: Vector3 = pack.get("position", Vector3.INF)
		if player_position.distance_to(pack_position) <= WorldStateModel.INTERACTION_RADIUS + 0.35:
			var owner_label := "your" if owner_token == local_token else "a friend's"
			interaction_prompt.text = "%s  ·  Recover %s trail pack" % [action_name, owner_label]
			interaction_prompt.visible = true
			return
	if food_order_active:
		var harvested_garden: Dictionary = latest_snapshot.get("harvested_garden_plots", {})
		for plot_id: String in WorldStateModel.GARDEN_PLOT_POSITIONS:
			if bool(harvested_garden.get(plot_id, false)):
				continue
			if player_position.distance_to(WorldStateModel.GARDEN_PLOT_POSITIONS[plot_id]) <= WorldStateModel.INTERACTION_RADIUS + 0.35:
				interaction_prompt.text = "%s  ·  %s" % [
					action_name,
					"Carefully tend moonroot pair"
					if int(local_mastery.get("farming", 0)) >= WorldStateModel.FARMING_TIER_TWO_MASTERY
					else "Harvest moonroot",
				]
				interaction_prompt.visible = true
				return
		var livelihood_materials: Dictionary = latest_snapshot.get("materials", {})
		if (
			int(livelihood_materials.get("moonroot", 0)) >= 2
			and (
				livelihood_stage == "food_need"
				or daily_food_order_kind == WorldStateModel.DAILY_ORDER_HEARTH_STEW
			)
			and player_position.distance_to(WorldStateModel.COOKFIRE_POSITION) <= WorldStateModel.INTERACTION_RADIUS + 0.35
		):
			interaction_prompt.text = "%s  ·  %s" % [
				action_name,
				"Batch cook hearth stew"
				if int(local_mastery.get("cooking", 0)) >= WorldStateModel.COOKING_TIER_TWO_MASTERY
				else "Cook hearth stew",
			]
			interaction_prompt.visible = true
			return
		if (
			daily_food_order_active
			and daily_food_order_kind == WorldStateModel.DAILY_ORDER_FRESH_MOONROOT
			and int(livelihood_materials.get("moonroot", 0)) > 0
			and player_position.distance_to(WorldStateModel.MARKET_CRATE_POSITION) <= WorldStateModel.INTERACTION_RADIUS + 0.35
		):
			interaction_prompt.text = "%s  ·  %s" % [
				action_name,
				"Bulk deliver fresh moonroot"
				if int(local_mastery.get("trade", 0)) >= WorldStateModel.TRADE_TIER_TWO_MASTERY
				else "Deliver fresh moonroot",
			]
			interaction_prompt.visible = true
			return
		if (
			int(livelihood_materials.get("hearth_stew", 0)) > 0
			and (
				livelihood_stage == "food_need"
				or daily_food_order_kind == WorldStateModel.DAILY_ORDER_HEARTH_STEW
			)
			and player_position.distance_to(WorldStateModel.MARKET_CRATE_POSITION) <= WorldStateModel.INTERACTION_RADIUS + 0.35
		):
			interaction_prompt.text = "%s  ·  %s" % [
				action_name,
				"Bulk deliver hearth stew"
				if int(local_mastery.get("trade", 0)) >= WorldStateModel.TRADE_TIER_TWO_MASTERY
				else "Deliver hearth stew",
			]
			interaction_prompt.visible = true
			return
	if (
		livelihood_stage == "complete"
		and int(latest_snapshot.get("pantry_stock", 0)) > 0
		and player_position.distance_to(WorldStateModel.MARKET_CRATE_POSITION) <= WorldStateModel.INTERACTION_RADIUS + 0.35
	):
		interaction_prompt.text = "%s  ·  Take a trail provision" % action_name
		interaction_prompt.visible = true
		return
	if (
		livelihood_stage == "complete"
		and int(latest_snapshot.get("player_coins", {}).get(local_token, 0)) >= WorldStateModel.TRAIL_PROVISION_PRICE
		and player_position.distance_to(WorldStateModel.SUPPLY_BASKET_POSITION) <= WorldStateModel.INTERACTION_RADIUS + 0.35
	):
		interaction_prompt.text = "%s  ·  Buy trail provision (%d coin)" % [
			action_name, WorldStateModel.TRAIL_PROVISION_PRICE
		]
		interaction_prompt.visible = true
		return
	if (
		livelihood_stage == "complete"
		and not bool(latest_snapshot.get("hearthbloom_complete", false))
		and int(latest_snapshot.get("player_coins", {}).get(local_token, 0)) > 0
		and player_position.distance_to(WorldStateModel.HEARTHBLOOM_POSITION) <= WorldStateModel.INTERACTION_RADIUS + 0.35
	):
		interaction_prompt.text = "%s  ·  Contribute 1 coin to Hearthbloom (%d/%d)" % [
			action_name,
			int(latest_snapshot.get("hearthbloom_contributions", 0)),
			WorldStateModel.HEARTHBLOOM_REQUIRED_COINS,
		]
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
	if (
		event_stage == "complete"
		and player_position.distance_to(mara_node.position) <= WorldStateModel.INTERACTION_RADIUS + 0.35
		and int(latest_snapshot.get("player_npc_check_in_day", {}).get(local_token, {}).get("mara", 0)) < int(latest_snapshot.get("world_day", 1))
	):
		interaction_prompt.text = "%s  ·  Check in with Mara" % action_name
		interaction_prompt.visible = true
		return
	if _local_can_use_trail_provision():
		interaction_prompt.text = "Q  ·  Use a trail provision"
		interaction_prompt.visible = true


func _shared_map_text(discoveries: Dictionary, route_activated: bool) -> String:
	var northwood := "charted" if bool(discoveries.get("northwood", false)) else "unexplored"
	var ruins := "charted" if bool(discoveries.get("old_stone_ruins", false)) else "rumored"
	var route := "waystone route active" if route_activated else "first journey required"
	return "SHARED MAP\n• Arrival Ward — home\n• Northwood — %s\n• Old Stone Ruins — %s\n• Route — %s" % [northwood, ruins, route]


func _update_relationship_interface(snapshot: Dictionary) -> void:
	var rapport := int(snapshot.get("player_relationships", {}).get(local_token, {}).get("mara", 0))
	var recognition := "New face"
	if rapport >= 5:
		recognition = "Trusted friend"
	elif rapport >= 3:
		recognition = "Familiar neighbor"
	elif rapport >= 1:
		recognition = "Acquainted"
	var checked_in_today := (
		int(snapshot.get("player_npc_check_in_day", {}).get(local_token, {}).get("mara", 0))
		>= int(snapshot.get("world_day", 1))
	)
	relationship_label.text = "MARA REMEMBERS YOU · %s · %d%s" % [
		recognition,
		rapport,
		" · checked in today" if checked_in_today else "",
	]


func _festival_player_name(player_token: String) -> String:
	if player_token.is_empty():
		return "—"
	if player_token == local_token:
		return "you"
	return "friend " + player_token.left(6)


func _mastery_text(mastery: Dictionary) -> String:
	var farming := int(mastery.get("farming", 0))
	var cooking := int(mastery.get("cooking", 0))
	var trade := int(mastery.get("trade", 0))
	var building := int(mastery.get("building", 0))
	var combat := int(mastery.get("combat", 0))
	var exploration := int(mastery.get("exploration", 0))
	var farming_title := ""
	if farming >= WorldStateModel.FARMING_TIER_TWO_MASTERY:
		farming_title = " (Gardener II · Careful Tending)"
	elif farming > 0:
		farming_title = " (Gardener I)"
	var cooking_title := ""
	if cooking >= WorldStateModel.COOKING_TIER_TWO_MASTERY:
		cooking_title = " (Cook II · Batch Cooking)"
	elif cooking > 0:
		cooking_title = " (Cook I)"
	var trade_title := ""
	if trade >= WorldStateModel.TRADE_TIER_TWO_MASTERY:
		trade_title = " (Trader II · Bulk Delivery)"
	elif trade > 0:
		trade_title = " (Trader I)"
	var building_title := " (Builder I)" if building > 0 else ""
	var combat_title := " (Warden I)" if combat > 0 else ""
	var exploration_title := " (Pathfinder I)" if exploration > 0 else ""
	return "Mastery — Farming: %d%s  Cooking: %d%s  Trade: %d%s\nBuilding: %d%s  Combat: %d%s  Exploration: %d%s" % [
		farming, farming_title,
		cooking, cooking_title,
		trade, trade_title,
		building, building_title,
		combat, combat_title,
		exploration, exploration_title,
	]


func _world_time_text(day: int, minute_of_day: int, period: String, weather: String, activity: String) -> String:
	var hour := floori(float(minute_of_day) / 60.0)
	var minute := minute_of_day % 60
	return "Day %d · %s %02d:%02d · %s · Mara: %s" % [day, period, hour, minute, weather, activity]


func _apply_world_atmosphere(minute_of_day: int, weather: String) -> void:
	if world_environment == null or world_environment.environment == null or sun_light == null:
		return
	var daylight := clampf(
		(sin((float(minute_of_day) - 360.0) / float(WorldStateModel.WORLD_MINUTES_PER_DAY) * TAU) + 0.25) / 1.25,
		0.0,
		1.0
	)
	var night_sky := Color("17263f")
	var day_sky := Color("91c8dd")
	var day_ambient := Color("fff4dc")
	var weather_energy := 1.0
	match weather:
		"overcast":
			day_sky = Color("7895a3")
			day_ambient = Color("dce4df")
			weather_energy = 0.78
		"gentle_rain":
			day_sky = Color("617b8e")
			day_ambient = Color("c5d4d6")
			weather_energy = 0.62
	world_environment.environment.background_color = night_sky.lerp(day_sky, daylight)
	world_environment.environment.ambient_light_color = Color("7686a5").lerp(day_ambient, daylight)
	world_environment.environment.ambient_light_energy = lerpf(0.38, 0.74 * weather_energy, daylight)
	sun_light.light_color = Color("9eb8df").lerp(Color("fff1cf"), daylight)
	sun_light.light_energy = lerpf(0.12, 1.0 * weather_energy, daylight)
	sun_light.rotation_degrees = Vector3(lerpf(-18.0, -58.0, daylight), -25.0, 0.0)
	if rain_particles != null:
		rain_particles.emitting = weather == "gentle_rain"


func _sync_recovery_packs(packs: Dictionary) -> void:
	for owner_token: String in recovery_pack_nodes.keys():
		if packs.has(owner_token):
			continue
		recovery_pack_nodes[owner_token].queue_free()
		recovery_pack_nodes.erase(owner_token)
	for owner_token: String in packs:
		var pack: Dictionary = packs[owner_token]
		var pack_node: Node3D
		if recovery_pack_nodes.has(owner_token):
			pack_node = recovery_pack_nodes[owner_token]
		else:
			pack_node = _create_recovery_pack_node(owner_token)
			recovery_pack_nodes[owner_token] = pack_node
		pack_node.position = pack.get("position", WorldStateModel.SPAWN_POINT)
		var label: Label3D = pack_node.get_node("Label")
		label.text = "TRAIL PACK · %d" % int(pack.get("count", 0))


func _create_recovery_pack_node(owner_token: String) -> Node3D:
	var pack_node := Node3D.new()
	pack_node.name = "RecoveryPack_%s" % owner_token.validate_node_name()
	var mesh_instance := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = Vector3(0.7, 0.45, 0.55)
	mesh_instance.mesh = box
	var material := StandardMaterial3D.new()
	material.albedo_color = Color("d7a94b")
	material.emission_enabled = true
	material.emission = Color("755516")
	mesh_instance.material_override = material
	pack_node.add_child(mesh_instance)
	var label := Label3D.new()
	label.name = "Label"
	label.position = Vector3(0.0, 0.75, 0.0)
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.font_size = 34
	label.outline_size = 8
	label.modulate = Color("ffe6a6")
	pack_node.add_child(label)
	add_child(pack_node)
	return pack_node


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
