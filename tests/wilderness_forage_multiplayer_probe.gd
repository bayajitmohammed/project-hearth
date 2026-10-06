extends SceneTree

const Scene = preload("res://main.tscn")
const Layout = preload("res://scripts/wilderness_layout.gd")
var main
var token := ""


func _init() -> void:
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with("--player-token="):
			token = argument.trim_prefix("--player-token=")
	assert(token in ["forage-a", "forage-b"])
	main = Scene.instantiate()
	root.add_child(main)
	main.local_input_enabled = false
	assert(await _wait(func() -> bool: return main.latest_snapshot.get("positions", {}).size() == 2))
	main._request_interaction()
	assert(await _wait(func() -> bool: return main.latest_snapshot.get("wilderness_forage_days", {}).has("2,2/0")))
	assert(main.latest_snapshot["materials"]["wood"] == 1)
	if token == "forage-b":
		var sources := Layout.forage_nodes(112358, Vector2i(2, 2))
		assert(await _move_to(sources[2]["position"]))
		main._request_interaction()
	assert(await _wait(func() -> bool: return main.latest_snapshot.get("wilderness_forage_days", {}).has("2,2/2")))
	assert(main.latest_snapshot["materials"]["wood"] == 1 and main.latest_snapshot["materials"]["herb"] == 1)
	assert(not main.wilderness.forage["2,2/0"]["growth"].visible)
	assert(not main.wilderness.forage["2,2/2"]["growth"].visible)
	print("PASS: contested wilderness harvest grants once and companion herb gathering updates both clients — %s" % token)
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
