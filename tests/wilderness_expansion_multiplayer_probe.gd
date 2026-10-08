extends SceneTree

const Scene = preload("res://main.tscn")
const Layout = preload("res://scripts/wilderness_layout.gd")
var main
var token := ""


func _init() -> void:
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with("--player-token="):
			token = argument.trim_prefix("--player-token=")
	assert(token in ["outer-a", "outer-b"])
	main = Scene.instantiate()
	root.add_child(main)
	main.local_input_enabled = false
	assert(await _wait(func() -> bool: return main.latest_snapshot.get("active_player_count", 0) == 2))
	var cell := Vector2i(-1, -1) if token == "outer-a" else Vector2i(1, -1)
	assert(await _move_to(Layout.cache_position(112358, cell)))
	main._request_interaction()
	assert(await _wait(func() -> bool: return main.latest_snapshot.get("player_wilderness_caches", {}).get("outer-a", {}).has("-1,-1") and main.latest_snapshot.get("player_wilderness_caches", {}).get("outer-b", {}).has("1,-1")))
	assert(main.latest_snapshot["player_provisions"]["outer-a"] == 1)
	assert(main.latest_snapshot["player_provisions"]["outer-b"] == 1)
	assert(main.latest_snapshot["wilderness_discoveries"].has("-1,-1"))
	assert(main.latest_snapshot["wilderness_discoveries"].has("1,-1"))
	assert(main.wilderness.sections.size() == 9)
	assert(main.wilderness.sections.has("-1,-1") == (token == "outer-a"))
	assert(main.wilderness.sections.has("1,-1") == (token == "outer-b"))
	print("PASS: outer-region independent streams, shared charting and personal cache claims — ", token)
	await create_timer(1).timeout
	quit()


func _wait(check: Callable) -> bool:
	for step in range(400):
		if check.call():
			return true
		await create_timer(0.05).timeout
	return false


func _move_to(target: Vector3) -> bool:
	for step in range(400):
		var current: Vector3 = main.latest_snapshot.get("positions", {}).get(token, Vector3.INF)
		if current.distance_to(target) <= 0.6:
			main.submit_input.rpc_id(1, Vector2.ZERO)
			return true
		var offset := target - current
		main.submit_input.rpc_id(1, Vector2(offset.x, offset.z).normalized())
		await create_timer(0.05).timeout
	return false
