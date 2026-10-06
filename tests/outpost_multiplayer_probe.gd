extends SceneTree

const Scene = preload("res://main.tscn")
const Layout = preload("res://scripts/wilderness_layout.gd")
var main
var token := ""


func _init() -> void:
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with("--player-token="):
			token = argument.trim_prefix("--player-token=")
	assert(token in ["outpost-a", "outpost-b"])
	main = Scene.instantiate()
	root.add_child(main)
	main.local_input_enabled = false
	assert(await _wait(func() -> bool: return main.latest_snapshot.get("positions", {}).size() == 2))
	var initial_reputation: int = main.latest_snapshot["reputation"]
	var jobs: Array = ["shelter", "remedies"] if token == "outpost-a" else ["meal"]
	for job: String in jobs:
		assert(await _move_to(Layout.outpost_station(112358, job)))
		main._request_interaction()
		assert(await _wait(func() -> bool: return main.latest_snapshot.get("outpost_parts", {}).has(job)))
	assert(await _wait(func() -> bool: return main.latest_snapshot.get("outpost_parts", {}).size() == 3))
	assert(main.latest_snapshot["materials"]["wood"] == 1 and main.latest_snapshot["materials"]["herb"] == 1)
	assert(main.latest_snapshot["shared_riverfish_stock"] == 0)
	assert(main.latest_snapshot["player_mastery"]["outpost-a"]["building"] == 1)
	assert(main.latest_snapshot["player_mastery"]["outpost-b"]["cooking"] == 2)
	assert(main.latest_snapshot["reputation"] == initial_reputation + 1 and main.latest_snapshot["chronicle"].size() == 1)
	assert(main.wilderness.outpost_markers["rest"].visible)
	print("PASS: split Fartrail jobs, conserved shared stock, individual mastery and one permanent outcome — %s" % token)
	await create_timer(1).timeout
	quit()


func _wait(check: Callable) -> bool:
	for step in range(600):
		if check.call():
			return true
		await create_timer(0.05).timeout
	return false


func _move_to(target: Vector3) -> bool:
	for step in range(600):
		var current: Vector3 = main.latest_snapshot.get("positions", {}).get(token, Vector3.INF)
		if current.distance_to(target) <= 0.6:
			main.submit_input.rpc_id(1, Vector2.ZERO)
			return true
		var offset := target - current
		main.submit_input.rpc_id(1, Vector2(offset.x, offset.z).normalized())
		await create_timer(0.05).timeout
	return false
