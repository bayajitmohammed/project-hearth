extends SceneTree

const MainScene = preload("res://main.tscn")
const STEP_SECONDS := 0.05
const TIMEOUT_SECONDS := 20.0

var main
var token := ""
var role := ""


func _init() -> void:
	token = _argument("--player-token=")
	role = _argument("--probe-role=")
	assert(token in ["handoff-giver", "handoff-recipient"], "Use a handoff probe identity.")
	main = MainScene.instantiate()
	root.add_child(main)
	main.local_input_enabled = false
	assert(await _wait_until(_is_connected, "connect to the handoff room"))
	if role == "browser-partner":
		assert(token == "handoff-giver")
		assert(await _wait_until(func() -> bool: return _active_other_token() != "", "see the browser partner"))
		var browser_token := _active_other_token()
		assert(_provisions("handoff-giver") == 3)
		main._request_interaction()
		assert(await _wait_until(
			func() -> bool: return _provisions("handoff-giver") == 2 and _provisions(browser_token) == 1,
			"give one provision to the browser partner"
		))
		assert(await _wait_until(
			func() -> bool: return _provisions("handoff-giver") == 3 and _provisions(browser_token) == 0,
			"receive the browser partner's return handoff"
		))
		print("PASS: Browser provision handoff partner — received and returned")
		quit()
		return
	assert(await _wait_until(_both_players_visible, "see both handoff players"))
	if token == "handoff-giver":
		assert(_provisions("handoff-giver") == 3)
		assert(_provisions("handoff-recipient") == 0)
		main._request_interaction()
	assert(await _wait_until(
		func() -> bool:
			return _provisions("handoff-giver") == 2 and _provisions("handoff-recipient") == 1,
		"observe one conserved provision handoff"
	))
	assert(_provisions("handoff-giver") + _provisions("handoff-recipient") == 3)
	print("PASS: Provision handoff probe %s — synchronized and conserved" % token)
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
	return positions.has("handoff-giver") and positions.has("handoff-recipient")


func _active_other_token() -> String:
	var positions: Dictionary = main.latest_snapshot.get("positions", {})
	for player_token: String in positions:
		if player_token != token:
			return player_token
	return ""


func _provisions(player_token: String) -> int:
	return int(main.latest_snapshot.get("player_provisions", {}).get(player_token, -1))


func _argument(prefix: String) -> String:
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with(prefix):
			return argument.trim_prefix(prefix)
	return ""
