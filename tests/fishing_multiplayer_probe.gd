extends SceneTree

const MainScene = preload("res://main.tscn")
const STEP_SECONDS := 0.05
const TIMEOUT_SECONDS := 20.0

var main
var token := ""


func _init() -> void:
	token = _argument("--player-token=")
	assert(token in ["fishing-a", "fishing-b"], "Use a fishing-a or fishing-b identity.")
	main = MainScene.instantiate()
	root.add_child(main)
	main.local_input_enabled = false
	assert(await _wait_until(_is_connected, "connect to the fishing room"))
	assert(await _wait_until(_both_players_visible, "see both anglers"))

	main._request_interaction()
	assert(await _wait_until(
		func() -> bool: return _phase(token) == "waiting",
		"start %s's independent cast" % token
	))
	if token == "fishing-b":
		main._request_interaction()
		assert(await _wait_until(
			func() -> bool: return _phase("fishing-b") == "idle",
			"end fishing-b's early reel"
		))
	else:
		assert(await _wait_until(
			func() -> bool: return _phase("fishing-a") == "bite",
			"reach fishing-a's bite window"
		))
		main._request_interaction()
		assert(await _wait_until(
			func() -> bool: return _fish("fishing-a") == 1,
			"award fishing-a's personal catch"
		))

	assert(await _wait_until(
		func() -> bool: return _fish("fishing-a") == 1 and _phase("fishing-b") == "idle",
		"observe the independent results"
	))
	assert(_fish("fishing-b") == 0, "An early reel must not grant or consume another player's catch.")
	assert(_mastery("fishing-a") == 1)
	assert(_mastery("fishing-b") == 0)
	print("PASS: Fishing multiplayer probe %s — independent cast timing and personal catch" % token)
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
	return positions.has("fishing-a") and positions.has("fishing-b")


func _phase(player_token: String) -> String:
	return str(main.latest_snapshot.get("player_fishing_phase", {}).get(player_token, "idle"))


func _fish(player_token: String) -> int:
	return int(main.latest_snapshot.get("player_riverfish", {}).get(player_token, 0))


func _mastery(player_token: String) -> int:
	return int(main.latest_snapshot.get("player_mastery", {}).get(player_token, {}).get("fishing", 0))


func _argument(prefix: String) -> String:
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with(prefix):
			return argument.trim_prefix(prefix)
	return ""
