extends SceneTree

const MainScene = preload("res://main.tscn")
const WorldStateModel = preload("res://scripts/world_state.gd")
const STEP_SECONDS := 0.05
const TIMEOUT_SECONDS := 25.0

var main
var token := ""


func _init() -> void:
	token = _argument("--player-token=")
	assert(token in ["moonwell-a", "moonwell-b"], "Use a Moonwell probe identity.")
	main = MainScene.instantiate()
	root.add_child(main)
	main.local_input_enabled = false
	assert(await _wait_until(_is_connected, "connect to Moonwell's room"))
	assert(await _wait_until(_both_players_visible, "see both Moonwell participants"))
	if token == "moonwell-a":
		main._request_interaction()
	assert(await _wait_until(
		func() -> bool: return _story_stage() in ["find_glade", "attune_stones", "complete"],
		"share Nima's map lead"
	))
	assert(await _wait_until(
		func() -> bool: return _story_stage() in ["attune_stones", "complete"],
		"share the Moonwell discovery"
	))
	if token == "moonwell-b":
		for stone_id: String in ["bough", "brook", "path"]:
			assert(await _move_to(WorldStateModel.MOONSTONE_POSITIONS[stone_id]))
			main._request_interaction()
			assert(await _wait_until(
				func() -> bool: return bool(main.latest_snapshot.get("attuned_moonstones", {}).get(stone_id, false)),
				"attune the %s moonstone" % stone_id
			))
	assert(await _wait_until(func() -> bool: return _story_stage() == "complete", "complete the shared sanctuary"))
	assert(_exploration_mastery("moonwell-a") == 0)
	assert(_exploration_mastery("moonwell-b") == 4, "The discoverer and stone tender keep their own Exploration credit.")
	assert(int(main.latest_snapshot.get("reputation", 0)) == 5)
	assert(int(main.latest_snapshot.get("neighborhood_morale", 0)) == 3)
	assert(main.latest_snapshot.get("chronicle", []).size() == 5)
	assert(main.moonwell_spring_glow.visible)
	if token == "moonwell-b":
		assert(await _move_to(WorldStateModel.MOONWELL_CENTER))
		main._request_interaction()
		assert(await _wait_until(
			func() -> bool: return int(main.latest_snapshot.get("player_health", {}).get(token, 0)) == WorldStateModel.PLAYER_MAX_HEALTH,
			"recover at the restored Moonwell"
		))
	print("PASS: Moonwell probe %s — reveal, fieldwork, consequence, and sanctuary stayed cooperative" % token)
	await create_timer(0.5).timeout
	quit()


func _move_to(target: Vector3) -> bool:
	var deadline := Time.get_ticks_msec() + int(TIMEOUT_SECONDS * 1000.0)
	while Time.get_ticks_msec() < deadline:
		var current: Vector3 = main.latest_snapshot.get("positions", {}).get(token, Vector3.INF)
		if current.is_finite() and current.distance_to(target) <= 0.7:
			main.submit_input.rpc_id(1, Vector2.ZERO)
			return true
		var offset := target - current
		main.submit_input.rpc_id(1, Vector2(offset.x, offset.z).normalized())
		await create_timer(STEP_SECONDS).timeout
	main.submit_input.rpc_id(1, Vector2.ZERO)
	push_error("Timed out moving to %s." % target)
	return false


func _wait_until(check: Callable, description: String) -> bool:
	var deadline := Time.get_ticks_msec() + int(TIMEOUT_SECONDS * 1000.0)
	while Time.get_ticks_msec() < deadline:
		if check.call():
			return true
		await create_timer(STEP_SECONDS).timeout
	push_error("Timed out waiting to %s." % description)
	return false


func _is_connected() -> bool:
	return main.client_connected and not main.latest_snapshot.is_empty()


func _both_players_visible() -> bool:
	var positions: Dictionary = main.latest_snapshot.get("positions", {})
	return positions.has("moonwell-a") and positions.has("moonwell-b")


func _story_stage() -> String:
	return str(main.latest_snapshot.get("moonwell_story_stage", "locked"))


func _exploration_mastery(player_token: String) -> int:
	return int(main.latest_snapshot.get("player_mastery", {}).get(player_token, {}).get("exploration", -1))


func _argument(prefix: String) -> String:
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with(prefix):
			return argument.trim_prefix(prefix)
	return ""
