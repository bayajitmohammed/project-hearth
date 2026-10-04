extends SceneTree

const MainScene = preload("res://main.tscn")
const STEP_SECONDS := 0.05
const TIMEOUT_SECONDS := 20.0

var main
var token := ""


func _init() -> void:
	token = _argument("--player-token=")
	assert(token in ["trailcraft-a", "trailcraft-b"], "Use a trailcraft probe identity.")
	main = MainScene.instantiate()
	root.add_child(main)
	main.local_input_enabled = false
	assert(await _wait_until(_is_connected, "connect to the trailcraft room"))
	assert(await _wait_until(_both_players_visible, "see both trail crafters"))
	main._request_craft()
	assert(await _wait_until(_both_provisions_crafted, "craft both personal provisions"))
	var materials: Dictionary = main.latest_snapshot.get("materials", {})
	assert(int(materials.get("wood", -1)) == 0)
	assert(int(materials.get("herb", -1)) == 0)
	assert(_provisions("trailcraft-a") + _provisions("trailcraft-b") == 2)
	print("PASS: Trailcraft probe %s — shared inputs conserved across both personal outputs" % token)
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
	return positions.has("trailcraft-a") and positions.has("trailcraft-b")


func _both_provisions_crafted() -> bool:
	return _provisions("trailcraft-a") == 1 and _provisions("trailcraft-b") == 1


func _provisions(player_token: String) -> int:
	return int(main.latest_snapshot.get("player_provisions", {}).get(player_token, -1))


func _argument(prefix: String) -> String:
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with(prefix):
			return argument.trim_prefix(prefix)
	return ""
