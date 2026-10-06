extends SceneTree

const Scene = preload("res://main.tscn")
const Layout = preload("res://scripts/wilderness_layout.gd")
var main
var token := ""


func _init() -> void:
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with("--player-token="):
			token = argument.trim_prefix("--player-token=")
	assert(token in ["wild-a", "wild-b"])
	main = Scene.instantiate()
	root.add_child(main)
	main.local_input_enabled = false
	assert(await _wait(func() -> bool: return main.latest_snapshot.get("positions", {}).size() == 2))
	assert(await _move_to(Layout.cache_position(112358, Vector2i(2, 2))))
	main._request_interaction()
	assert(await _wait(func() -> bool: return main.latest_snapshot.get("player_wilderness_caches", {}).get("wild-a", {}).has("2,2") and main.latest_snapshot.get("player_wilderness_caches", {}).get("wild-b", {}).has("2,2")))
	assert(main.latest_snapshot["player_provisions"]["wild-a"] == 1)
	assert(main.latest_snapshot["player_provisions"]["wild-b"] == 1)
	if token == "wild-b":
		assert(await _move_to(Layout.cache_position(112358, Vector2i(0, 2))))
		main._request_interaction()
	assert(await _wait(func() -> bool: return main.latest_snapshot.get("player_wilderness_caches", {}).get("wild-b", {}).has("0,2")))
	assert(main.latest_snapshot["wilderness_discoveries"].has("0,2"))
	assert(main.latest_snapshot["player_provisions"]["wild-b"] == 2)
	assert(main.wilderness.sections.has("2,2") == (token == "wild-a"))
	assert(main.wilderness.sections.has("0,2") == (token == "wild-b"))
	print("PASS: independent terrain streaming, shared discovery and personal cache claims — %s" % token)
	await create_timer(1).timeout
	quit()


func _wait(check: Callable) -> bool:
	for step in range(1200):
		if check.call():
			return true
		await create_timer(0.05).timeout
	return false


func _move_to(target: Vector3) -> bool:
	for step in range(1200):
		var current: Vector3 = main.latest_snapshot.get("positions", {}).get(token, Vector3.INF)
		if current.distance_to(target) <= 0.6:
			main.submit_input.rpc_id(1, Vector2.ZERO)
			return true
		var offset := target - current
		main.submit_input.rpc_id(1, Vector2(offset.x, offset.z).normalized())
		await create_timer(0.05).timeout
	return false
