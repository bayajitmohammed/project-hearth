extends SceneTree

const MainScene = preload("res://main.tscn")
const WorldStateModel = preload("res://scripts/world_state.gd")
const STEP_SECONDS := 0.05
const TIMEOUT_SECONDS := 20.0

var main
var token := ""


func _init() -> void:
	token = _argument("--player-token=")
	assert(token in ["supper-a", "supper-b"], "Use a Moonwell Supper probe identity.")
	main = MainScene.instantiate()
	root.add_child(main)
	main.local_input_enabled = false
	assert(await _wait_until(_is_connected, "connect to the Moonwell Supper room"))
	assert(await _wait_until(_both_players_visible, "see both supper cooks"))
	if token == "supper-a":
		main._request_interaction()
		assert(await _wait_until(func() -> bool: return _courses() >= 1, "prepare the first personal-fish course"))
		main._request_interaction()
	assert(await _wait_until(func() -> bool: return _courses() >= 2, "share two prepared courses"))
	assert(int(main.latest_snapshot.get("player_riverfish", {}).get("supper-a", -1)) == 0)
	assert(int(main.latest_snapshot.get("shared_riverfish_stock", -1)) == 1, "Personal fish must be consumed before creel stock.")
	if token == "supper-b":
		await create_timer(0.6).timeout
		main._request_interaction()
	assert(await _wait_until(func() -> bool: return _stage() == "complete", "complete the shared Moonwell Supper"))
	assert(_cooking_mastery("supper-a") == 2)
	assert(_cooking_mastery("supper-b") == 1)
	assert(int(main.latest_snapshot.get("materials", {}).get("moonroot", -1)) == 0)
	assert(int(main.latest_snapshot.get("shared_riverfish_stock", -1)) == 0)
	assert(int(main.latest_snapshot.get("reputation", 0)) == 7)
	assert(int(main.latest_snapshot.get("neighborhood_morale", 0)) == 5)
	assert(main.latest_snapshot.get("chronicle", []).size() == 7)
	assert(main.moonwell_supper_decorations.visible)
	print("PASS: Moonwell Supper probe %s — ingredients, cook credit, and shared consequence stayed conserved" % token)
	await create_timer(0.5).timeout
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
	return positions.has("supper-a") and positions.has("supper-b")


func _stage() -> String:
	return str(main.latest_snapshot.get("moonwell_supper_stage", "locked"))


func _courses() -> int:
	return int(main.latest_snapshot.get("moonwell_supper_courses", -1))


func _cooking_mastery(player_token: String) -> int:
	return int(main.latest_snapshot.get("player_mastery", {}).get(player_token, {}).get("cooking", -1))


func _argument(prefix: String) -> String:
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with(prefix):
			return argument.trim_prefix(prefix)
	return ""
