extends SceneTree

const MainScene = preload("res://main.tscn")
const WorldStateModel = preload("res://scripts/world_state.gd")
const STEP_SECONDS := 0.05
const TIMEOUT_SECONDS := 25.0

var main
var role := ""
var token := ""
var other_token := ""


func _init() -> void:
	role = _argument("--probe-role=")
	token = _argument("--player-token=")
	assert(role in ["leader", "helper"], "Use --probe-role=leader or helper.")
	assert(not token.is_empty(), "A unique --player-token is required.")
	other_token = "festival-helper" if role == "leader" else "festival-leader"

	main = MainScene.instantiate()
	root.add_child(main)
	main.local_input_enabled = false
	assert(await _wait_until(_is_connected, "connect to the festival room"))
	assert(await _wait_until(_both_players_visible, "see both festival entrants"))
	assert(await _move_to(WorldStateModel.FESTIVAL_ARCH_POSITION), "Could not reach the festival arch.")

	if role == "leader":
		main._request_interaction()
		assert(await _wait_until(
			func() -> bool: return _festival_stage() == "signup" and _participants().has(token),
			"open festival signup"
		))
		assert(await _wait_until(func() -> bool: return _participants().size() == 2, "enroll both players"))
		main._request_interaction()
	else:
		assert(await _wait_until(func() -> bool: return _festival_stage() == "signup", "see festival signup"))
		main._request_interaction()
		assert(await _wait_until(func() -> bool: return _participants().has(token), "join festival signup"))

	assert(await _wait_until(func() -> bool: return _festival_stage() == "racing", "start the circuit"))
	if role == "leader":
		assert(await _wait_until(
			func() -> bool: return str(main.latest_snapshot.get("festival_last_winner", "")) == other_token,
			"observe the helper win"
		))
	else:
		assert(await _finish_circuit(), "Helper could not finish the circuit.")

	if role == "leader":
		assert(await _finish_circuit(), "Leader could not finish the circuit.")
	assert(await _wait_until(func() -> bool: return _festival_stage() == "results", "finish the shared circuit"))
	assert(str(main.latest_snapshot.get("festival_last_winner", "")) == "festival-helper")
	assert(int(main.latest_snapshot.get("festival_ribbons", {}).get("festival-leader", 0)) == 1)
	assert(int(main.latest_snapshot.get("festival_ribbons", {}).get("festival-helper", 0)) == 1)
	assert(bool(main.latest_snapshot.get("festival_completed", false)))
	print("PASS: Multiplayer Hearthlight Circuit %s — opt-in, fair winner, shared results" % role)
	quit()


func _finish_circuit() -> bool:
	for checkpoint_index: int in WorldStateModel.FESTIVAL_CHECKPOINT_ORDER.size():
		var checkpoint_id: String = WorldStateModel.FESTIVAL_CHECKPOINT_ORDER[checkpoint_index]
		assert(await _move_to(WorldStateModel.FESTIVAL_CHECKPOINT_POSITIONS[checkpoint_id]))
		main._request_interaction()
		if not await _wait_until(
			func() -> bool: return int(_participants().get(token, 0)) >= checkpoint_index + 1,
			"claim checkpoint %d" % (checkpoint_index + 1)
		):
			return false
	return true


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


func _festival_stage() -> String:
	return str(main.latest_snapshot.get("festival_stage", ""))


func _participants() -> Dictionary:
	return main.latest_snapshot.get("festival_participants", {})


func _argument(prefix: String) -> String:
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with(prefix):
			return argument.trim_prefix(prefix)
	return ""
