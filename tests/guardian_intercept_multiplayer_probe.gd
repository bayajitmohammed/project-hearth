extends SceneTree

const MainScene = preload("res://main.tscn")
const WorldStateModel = preload("res://scripts/world_state.gd")
const STEP_SECONDS := 0.05
const TIMEOUT_SECONDS := 20.0
const TARGET_TOKEN := "intercept-target"
const GUARDIAN_TOKEN := "intercept-guardian"

var main
var token := ""


func _init() -> void:
	token = _argument("--player-token=")
	assert(token in [TARGET_TOKEN, GUARDIAN_TOKEN], "Use an intercept-target or intercept-guardian identity.")
	main = MainScene.instantiate()
	root.add_child(main)
	main.local_input_enabled = false
	assert(await _wait_until(_is_connected, "connect to the Guardian-intercept room"))
	assert(await _wait_until(_both_players_visible, "see both combat players"))
	assert(_kit(TARGET_TOKEN) == WorldStateModel.OUTING_KIT_VANGUARD)
	assert(_kit(GUARDIAN_TOKEN) == WorldStateModel.OUTING_KIT_GUARDIAN)

	if _argument("--probe-role=") == "browser-companion":
		assert(token == GUARDIAN_TOKEN, "Only the Guardian companion uses browser-target coordination.")
		assert(await _wait_until(_browser_target_has_approached, "see the browser target approach"))
		main.submit_input.rpc_id(1, Vector2(0.0, -1.0))
		assert(await _wait_until(_guardian_is_near_target, "join the browser target's formation"))
		main.submit_input.rpc_id(1, Vector2.ZERO)
	else:
		main.submit_input.rpc_id(1, Vector2(0.0, -1.0))
	assert(await _wait_until(_targeted_windup_started, "begin a telegraphed hit against the Vanguard"))
	main.submit_input.rpc_id(1, Vector2.ZERO)
	if token == GUARDIAN_TOKEN:
		main._request_brace()
	assert(await _wait_until(_guardian_is_braced, "synchronize the Guardian brace"))
	assert(await _wait_until(_intercept_resolved, "resolve the Guardian interception"))
	assert(int(main.latest_snapshot.get("player_health", {}).get(TARGET_TOKEN, 0)) == WorldStateModel.PLAYER_MAX_HEALTH)
	assert(is_zero_approx(float(main.latest_snapshot.get("player_brace_time", {}).get(GUARDIAN_TOKEN, -1.0))))
	assert(str(main.latest_snapshot.get("guardian_intercept_player", "")) == GUARDIAN_TOKEN)
	assert(str(main.latest_snapshot.get("guardian_intercept_target", "")) == TARGET_TOKEN)
	print("PASS: Guardian-intercept multiplayer probe %s — synchronized cooperative block" % token)
	quit()


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
	return positions.has(TARGET_TOKEN) and positions.has(GUARDIAN_TOKEN)


func _targeted_windup_started() -> bool:
	return (
		float(main.latest_snapshot.get("creature_attack_windup", 0.0)) > 0.0
		and str(main.latest_snapshot.get("creature_attack_target", "")) == TARGET_TOKEN
	)


func _browser_target_has_approached() -> bool:
	var positions: Dictionary = main.latest_snapshot.get("positions", {})
	return positions.has(TARGET_TOKEN) and float(positions[TARGET_TOKEN].z) < 0.0


func _guardian_is_near_target() -> bool:
	var positions: Dictionary = main.latest_snapshot.get("positions", {})
	return (
		positions.has(TARGET_TOKEN)
		and positions.has(GUARDIAN_TOKEN)
		and positions[GUARDIAN_TOKEN].distance_to(positions[TARGET_TOKEN]) <= 1.05
	)


func _guardian_is_braced() -> bool:
	return float(main.latest_snapshot.get("player_brace_time", {}).get(GUARDIAN_TOKEN, 0.0)) > 0.0


func _intercept_resolved() -> bool:
	return (
		float(main.latest_snapshot.get("guardian_intercept_time", 0.0)) > 0.0
		and str(main.latest_snapshot.get("guardian_intercept_player", "")) == GUARDIAN_TOKEN
		and str(main.latest_snapshot.get("guardian_intercept_target", "")) == TARGET_TOKEN
	)


func _kit(player_token: String) -> String:
	return str(
		main.latest_snapshot.get("player_outing_kits", {}).get(
			player_token, WorldStateModel.OUTING_KIT_VANGUARD
		)
	)


func _argument(prefix: String) -> String:
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with(prefix):
			return argument.trim_prefix(prefix)
	return ""
