extends SceneTree

const MainScene = preload("res://main.tscn")
const STEP_SECONDS := 0.05
const TIMEOUT_SECONDS := 20.0

var main
var token := ""


func _init() -> void:
	token = _argument("--player-token=")
	assert(token in ["chronicle-a", "chronicle-b"], "Use a Chronicle Board probe identity.")
	main = MainScene.instantiate()
	root.add_child(main)
	main.local_input_enabled = false
	assert(await _wait_until(_is_connected, "connect to the Chronicle Board room"))
	assert(await _wait_until(_both_players_visible, "see both chronicle readers"))
	if token == "chronicle-a":
		await create_timer(0.5).timeout
		assert(_read_count("chronicle-a") == 0 and _read_count("chronicle-b") == 0)
		main._request_interaction()
	else:
		assert(_read_count("chronicle-b") == 0)
	assert(await _wait_until(func() -> bool: return _read_count("chronicle-a") == 2, "share the first personal acknowledgement"))
	assert(_read_count("chronicle-b") == 0, "One player reading must not clear another player's updates.")
	if token == "chronicle-b":
		await create_timer(0.5).timeout
		main._request_interaction()
	assert(await _wait_until(func() -> bool: return _read_count("chronicle-b") == 2, "share the second personal acknowledgement"))
	assert(_read_count("chronicle-a") == 2 and _read_count("chronicle-b") == 2)
	print("PASS: Chronicle Board probe %s — read positions remained independent" % token)
	await create_timer(1.0).timeout
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
	return positions.has("chronicle-a") and positions.has("chronicle-b")


func _read_count(player_token: String) -> int:
	return int(main.latest_snapshot.get("player_chronicle_read_count", {}).get(player_token, -1))


func _argument(prefix: String) -> String:
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with(prefix):
			return argument.trim_prefix(prefix)
	return ""
