extends SceneTree

const MainScene = preload("res://main.tscn")
const STEP_SECONDS := 0.05
const TIMEOUT_SECONDS := 20.0

var main
var token := ""


func _init() -> void:
	token = _argument("--player-token=")
	assert(token in ["project-a", "project-b"], "Use a project-a or project-b identity.")
	main = MainScene.instantiate()
	root.add_child(main)
	main.local_input_enabled = false
	assert(await _wait_until(_is_connected, "connect to the server"))
	assert(await _wait_until(_both_contributors_visible, "see both project contributors"))
	assert(int(main.latest_snapshot.get("player_coins", {}).get(token, -1)) == 2)

	for remaining_coins: int in [1, 0]:
		main._request_interaction()
		assert(await _wait_until(
			func() -> bool:
				return int(main.latest_snapshot.get("player_coins", {}).get(token, -1)) == remaining_coins,
			"contribute coin with %s" % token
		))

	assert(await _wait_until(
		func() -> bool: return bool(main.latest_snapshot.get("hearthbloom_complete", false)),
		"complete the shared Hearthbloom project"
	))
	assert(int(main.latest_snapshot.get("hearthbloom_contributions", 0)) == 4)
	assert(int(main.latest_snapshot.get("player_coins", {}).get("project-a", -1)) == 0)
	assert(int(main.latest_snapshot.get("player_coins", {}).get("project-b", -1)) == 0)
	assert(int(main.latest_snapshot.get("neighborhood_morale", 0)) == 3)
	assert(int(main.latest_snapshot.get("reputation", 0)) == 5)
	assert(main.latest_snapshot.get("chronicle", []).size() == 5)
	print("PASS: Hearthbloom multiplayer probe %s — pooled coin, one shared completion" % token)
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


func _both_contributors_visible() -> bool:
	var positions: Dictionary = main.latest_snapshot.get("positions", {})
	return positions.has("project-a") and positions.has("project-b")


func _argument(prefix: String) -> String:
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with(prefix):
			return argument.trim_prefix(prefix)
	return ""
