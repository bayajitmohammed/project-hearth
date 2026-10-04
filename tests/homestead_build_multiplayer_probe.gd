extends SceneTree

const MainScene = preload("res://main.tscn")
const WorldStateModel = preload("res://scripts/world_state.gd")
const STEP_SECONDS := 0.05
const TIMEOUT_SECONDS := 20.0

var main
var token := ""


func _init() -> void:
	token = _argument("--player-token=")
	assert(token in ["builder-a", "builder-b"], "Use a homestead-building probe identity.")
	main = MainScene.instantiate()
	root.add_child(main)
	main.local_input_enabled = false
	assert(await _wait_until(_is_connected, "connect to the homestead-building room"))
	assert(await _wait_until(_both_players_visible, "see both homestead builders"))
	main._request_interaction()
	assert(await _wait_until(_one_lantern_built, "resolve the shared final-wood placement"))
	assert(_built_lantern_count() == 1)
	assert(_building_mastery("builder-a") + _building_mastery("builder-b") == 1)
	assert(int(main.latest_snapshot.get("materials", {}).get("wood", -1)) == 0)
	print("PASS: Homestead build probe %s — one shared wood produced one persistent placement" % token)
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
	return positions.has("builder-a") and positions.has("builder-b")


func _one_lantern_built() -> bool:
	return _built_lantern_count() == 1 and int(main.latest_snapshot.get("materials", {}).get("wood", -1)) == 0


func _built_lantern_count() -> int:
	var count := 0
	var lanterns: Dictionary = main.latest_snapshot.get("built_homestead_lanterns", {})
	for socket_id: String in WorldStateModel.HOMESTEAD_LANTERN_POSITIONS:
		if bool(lanterns.get(socket_id, false)):
			count += 1
	return count


func _building_mastery(player_token: String) -> int:
	return int(main.latest_snapshot.get("player_mastery", {}).get(player_token, {}).get("building", -1))


func _argument(prefix: String) -> String:
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with(prefix):
			return argument.trim_prefix(prefix)
	return ""
