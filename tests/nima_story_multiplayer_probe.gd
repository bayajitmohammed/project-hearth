extends SceneTree

const MainScene = preload("res://main.tscn")
const STEP_SECONDS := 0.05
const TIMEOUT_SECONDS := 20.0

var main
var token := ""


func _init() -> void:
	token = _argument("--player-token=")
	assert(token in ["nima-a", "nima-b"], "Use a Nima-story probe identity.")
	main = MainScene.instantiate()
	root.add_child(main)
	main.local_input_enabled = false
	assert(await _wait_until(_is_connected, "connect to Nima's story room"))
	assert(await _wait_until(_both_players_visible, "see both story participants"))
	if token == "nima-a":
		await create_timer(0.35).timeout
		main._request_interaction()
	assert(await _wait_until(func() -> bool: return _story_stage() == "find_case", "share Nima's request"))
	if token == "nima-b":
		await create_timer(0.5).timeout
		main._request_interaction()
	assert(await _wait_until(func() -> bool: return _story_stage() == "return_case", "share the recovered field case"))
	assert(_exploration_mastery("nima-a") == 0)
	assert(_exploration_mastery("nima-b") == 1, "Only the field-case finder earns Exploration mastery.")
	if token == "nima-a":
		await create_timer(0.5).timeout
		main._request_interaction()
	assert(await _wait_until(func() -> bool: return _story_stage() == "complete", "complete Nima's shared story"))
	assert(_rapport("nima-a") == 2)
	assert(_rapport("nima-b") == 0)
	assert(int(main.latest_snapshot.get("reputation", 0)) == 4)
	assert(int(main.latest_snapshot.get("neighborhood_morale", 0)) == 2)
	assert(main.nima_map_table.visible)
	assert(main.latest_snapshot.get("chronicle", []).size() == 4)
	print("PASS: Nima story probe %s — conversation, fieldwork, and consequence stayed cooperative" % token)
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
	return positions.has("nima-a") and positions.has("nima-b")


func _story_stage() -> String:
	return str(main.latest_snapshot.get("nima_story_stage", "locked"))


func _exploration_mastery(player_token: String) -> int:
	return int(main.latest_snapshot.get("player_mastery", {}).get(player_token, {}).get("exploration", -1))


func _rapport(player_token: String) -> int:
	return int(main.latest_snapshot.get("player_relationships", {}).get(player_token, {}).get("nima", -1))


func _argument(prefix: String) -> String:
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with(prefix):
			return argument.trim_prefix(prefix)
	return ""
