extends SceneTree

const Scene = preload("res://main.tscn")
const Layout = preload("res://scripts/wilderness_layout.gd")
var main
var token := ""


func _init() -> void:
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with("--player-token="):
			token = argument.trim_prefix("--player-token=")
	assert(token in ["plot-a", "plot-b"])
	main = Scene.instantiate()
	root.add_child(main)
	main.local_input_enabled = false
	assert(await _wait(func() -> bool: return main.latest_snapshot.get("positions", {}).size() == 2))
	assert(await _move_to(Layout.claim_post(112358, Vector2i(2, 2))))
	main._request_interaction()
	assert(await _wait(func() -> bool: return main.latest_snapshot.get("wilderness_plots", {}).has("2,2")))
	var origin := Layout.plot_origin(112358, Vector2i(2, 2))
	assert(await _move_to(origin + Vector3(0, 0.6, 1)))
	main._request_furnishing(Vector2i.ZERO, "foundation", 0, false, "2,2")
	assert(await _wait(func() -> bool: return _plot()["structures"].has("0,0/foundation")))
	main._request_furnishing(Vector2i.ZERO, "wall" if token == "plot-a" else "bench", 0, false, "2,2")
	assert(await _wait(func() -> bool: return _plot()["structures"].size() == 2 and _plot()["furnishings"].size() == 1))
	assert(main.latest_snapshot["materials"]["wood"] == 12)
	assert(main.latest_snapshot["furnishings"].is_empty() and main.latest_snapshot["structures"].is_empty())
	if token == "plot-a":
		main.submit_input.rpc_id(1, Vector2.UP)
		await create_timer(1).timeout
		main.submit_input.rpc_id(1, Vector2.ZERO)
		await create_timer(0.15).timeout
		assert(absf(main.latest_snapshot["positions"][token].z - (origin.z - 1.02)) < 0.04)
	else:
		assert(await _move_to(Layout.claim_post(112358, Vector2i(1, 2))))
		main._request_interaction()
	assert(await _wait(func() -> bool: return main.latest_snapshot.get("wilderness_plots", {}).size() == 2))
	assert(main.latest_snapshot["materials"]["wood"] == 10)
	assert(main.latest_snapshot["wilderness_plots"]["1,2"]["structures"].is_empty())
	assert(main.homestead_builder.remote_roots["2,2"].get_child_count() == 3)
	print("PASS: competing shared claim, cooperative remote building, solid walls and independent second claim — %s" % token)
	await create_timer(0.5).timeout
	quit()


func _plot() -> Dictionary:
	return main.latest_snapshot["wilderness_plots"]["2,2"]


func _wait(check: Callable) -> bool:
	for step in range(900):
		if check.call():
			return true
		await create_timer(0.05).timeout
	return false


func _move_to(target: Vector3) -> bool:
	for step in range(900):
		var current: Vector3 = main.latest_snapshot.get("positions", {}).get(token, Vector3.INF)
		if current.distance_to(target) <= 0.35:
			main.submit_input.rpc_id(1, Vector2.ZERO)
			return true
		var offset := target - current
		main.submit_input.rpc_id(1, Vector2(offset.x, offset.z).normalized())
		await create_timer(0.05).timeout
	return false
