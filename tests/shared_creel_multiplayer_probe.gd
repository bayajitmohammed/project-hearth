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
	assert(token in ["creel-a", "creel-b"], "Use a shared-creel probe identity.")
	main = MainScene.instantiate()
	root.add_child(main)
	main.local_input_enabled = false
	assert(await _wait_until(_is_connected, "connect to the shared-creel room"))
	if role == "browser-observer":
		assert(token == "creel-a")
		assert(await _wait_until(func() -> bool: return _active_player_count() >= 2, "see the browser observer"))
		assert(_stock() == 1)
		main._request_interaction()
		assert(await _wait_until(func() -> bool: return _stock() == 0, "cook the final shared fish"))
		print("PASS: Browser shared-creel partner — final fish cooked")
		quit()
		return
	assert(await _wait_until(_both_players_visible, "see both shared-creel cooks"))
	main._request_interaction()
	assert(await _wait_until(_shared_fish_resolved, "resolve the shared fish once"))
	assert(_stock() == 0)
	assert(_provisions("creel-a") + _provisions("creel-b") == 1)
	assert(_cooking_mastery("creel-a") + _cooking_mastery("creel-b") == 1)
	print("PASS: Shared creel probe %s — one shared fish cooked once" % token)
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
	return positions.has("creel-a") and positions.has("creel-b")


func _active_player_count() -> int:
	return main.latest_snapshot.get("positions", {}).size()


func _shared_fish_resolved() -> bool:
	return (
		_stock() == 0
		and _provisions("creel-a") + _provisions("creel-b") == 1
		and _cooking_mastery("creel-a") + _cooking_mastery("creel-b") == 1
	)


func _stock() -> int:
	return int(main.latest_snapshot.get("shared_riverfish_stock", -1))


func _provisions(player_token: String) -> int:
	return int(main.latest_snapshot.get("player_provisions", {}).get(player_token, -1))


func _cooking_mastery(player_token: String) -> int:
	return int(
		main.latest_snapshot.get("player_mastery", {}).get(player_token, {}).get("cooking", -1)
	)


func _argument(prefix: String) -> String:
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with(prefix):
			return argument.trim_prefix(prefix)
	return ""
