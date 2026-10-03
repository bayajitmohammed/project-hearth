extends SceneTree

const MainScene = preload("res://main.tscn")
const WorldStateModel = preload("res://scripts/world_state.gd")
const STEP_SECONDS := 0.05
const TIMEOUT_SECONDS := 20.0

var main
var role := ""
var token := ""
var other_token := ""


func _init() -> void:
	role = _argument("--probe-role=")
	token = _argument("--player-token=")
	other_token = "probe-helper" if token == "probe-leader" else "probe-leader"
	assert(role in ["leader", "helper"], "Use --probe-role=leader or helper.")
	assert(not token.is_empty(), "A unique --player-token is required.")

	main = MainScene.instantiate()
	root.add_child(main)
	main.local_input_enabled = false
	assert(await _wait_until(_is_connected, "connect to the server"))
	assert(await _wait_until(_both_players_visible, "see both players"))

	if role == "leader":
		assert(await _move_to(WorldStateModel.MARA_POSITION), "Leader could not reach Mara.")
		main._request_interaction()
	assert(await _wait_until(func() -> bool: return _quest_stage() == "recover_supplies", "share quest progress"))
	assert(await _wait_until(_relationship_credit_visible, "share personal Mara rapport"))
	assert(_mara_rapport("probe-leader") == 1, "The player who spoke with Mara must receive personal rapport.")
	assert(_mara_rapport("probe-helper") == 0, "Shared quest progress must not duplicate personal rapport.")

	assert(await _move_to(WorldStateModel.RESOURCE_POSITIONS["wood_1"]), "Could not reach shared wood.")
	assert(await _wait_until(_both_players_at_wood, "bring both players to the same resource"))
	main._request_interaction()
	assert(await _wait_until(_first_wood_gathered, "gather the shared resource"))
	main._request_interaction()
	await create_timer(0.4).timeout
	assert(int(main.latest_snapshot.get("materials", {}).get("wood", 0)) == 1, "One resource was duplicated by simultaneous clients.")

	if role == "leader":
		assert(await _move_to(WorldStateModel.CREATURE_SPAWN), "Leader could not reach the creature.")
		assert(await _wait_until(func() -> bool: return _is_downed("probe-leader"), "have the creature down the leader"))
		assert(await _wait_until(_leader_revived, "receive a revive from the helper"))
	else:
		assert(await _move_to(WorldStateModel.CREATURE_SPAWN + Vector3(3.0, 0.0, 0.0)), "Helper could not reach the creature area.")
		assert(await _wait_until(func() -> bool: return _is_downed("probe-leader"), "observe the downed leader"))
		var leader_position: Vector3 = main.latest_snapshot.get("positions", {}).get("probe-leader", Vector3.INF)
		assert(await _move_to(leader_position), "Helper could not reach the downed leader.")
		main._request_interaction()
		assert(await _wait_until(_leader_revived, "revive the leader"))

	assert(int(main.latest_snapshot.get("player_health", {}).get("probe-leader", 0)) == 2)
	print("PASS: Multiplayer probe %s — shared quest, no duplication, revival" % role)
	quit()


func _move_to(target: Vector3) -> bool:
	var deadline := Time.get_ticks_msec() + int(TIMEOUT_SECONDS * 1000.0)
	while Time.get_ticks_msec() < deadline:
		var position: Vector3 = main.latest_snapshot.get("positions", {}).get(token, Vector3.INF)
		if position.is_finite():
			var difference := target - position
			var planar := Vector2(difference.x, difference.z)
			if planar.length() <= 0.3:
				main.submit_input.rpc_id(1, Vector2.ZERO)
				return true
			main.submit_input.rpc_id(1, planar.normalized())
		await create_timer(STEP_SECONDS).timeout
	main.submit_input.rpc_id(1, Vector2.ZERO)
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
	return positions.has(token) and positions.has(other_token)


func _both_players_at_wood() -> bool:
	var positions: Dictionary = main.latest_snapshot.get("positions", {})
	var target: Vector3 = WorldStateModel.RESOURCE_POSITIONS["wood_1"]
	return (
		positions.get(token, Vector3.INF).distance_to(target) < 0.65
		and positions.get(other_token, Vector3.INF).distance_to(target) < 0.65
	)


func _first_wood_gathered() -> bool:
	return (
		bool(main.latest_snapshot.get("gathered_resources", {}).get("wood_1", false))
		and int(main.latest_snapshot.get("materials", {}).get("wood", 0)) == 1
	)


func _leader_revived() -> bool:
	return not _is_downed("probe-leader") and int(main.latest_snapshot.get("player_health", {}).get("probe-leader", 0)) == 2


func _is_downed(player_token: String) -> bool:
	return bool(main.latest_snapshot.get("downed_players", {}).get(player_token, false))


func _quest_stage() -> String:
	return str(main.latest_snapshot.get("quest_stage", ""))


func _relationship_credit_visible() -> bool:
	return _mara_rapport("probe-leader") == 1 and _mara_rapport("probe-helper") == 0


func _mara_rapport(player_token: String) -> int:
	return int(main.latest_snapshot.get("player_relationships", {}).get(player_token, {}).get("mara", -1))


func _argument(prefix: String) -> String:
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with(prefix):
			return argument.trim_prefix(prefix)
	return ""
