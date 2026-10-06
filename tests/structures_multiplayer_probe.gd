extends SceneTree

const Scene = preload("res://main.tscn")
var main
var token := ""


func _init() -> void:
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with("--player-token="):
			token = argument.trim_prefix("--player-token=")
	assert(token in ["structure-a", "structure-b"])
	main = Scene.instantiate()
	root.add_child(main)
	main.local_input_enabled = false
	assert(await _wait(func() -> bool: return main.latest_snapshot.get("positions", {}).size() == 2))
	main._request_furnishing(Vector2i.ZERO, "foundation", 0, false)
	assert(await _wait(func() -> bool: return _pieces().has("0,0/foundation")))
	if token == "structure-a":
		main._request_furnishing(Vector2i.ZERO, "wall", 0, false)
	else:
		main._request_furnishing(Vector2i.ZERO, "doorway", 2, false)
	assert(await _wait(func() -> bool: return _pieces().size() >= 3))
	if token == "structure-a":
		main._request_furnishing(Vector2i.ZERO, "roof", 0, false)
	assert(await _wait(func() -> bool: return _pieces().size() == 4))
	assert(main.latest_snapshot["materials"]["wood"] == 2)
	if token == "structure-a":
		await _move(Vector2.UP, 1.2)
		assert(absf(main.latest_snapshot["positions"][token].z - 14.98) < 0.03)
		await _move(Vector2.DOWN, 1.2)
		assert(main.latest_snapshot["positions"][token].z > 18)
	else:
		assert(await _wait(func() -> bool: return main.latest_snapshot["positions"]["structure-a"].z > 18))
		main._request_furnishing(Vector2i.ZERO, "wall", 0, true)
		await create_timer(0.3).timeout
		assert(_pieces().has("0,0/side0"), "Roof supports cannot be removed first.")
		main._request_furnishing(Vector2i.ZERO, "roof", 0, true)
		main._request_furnishing(Vector2i.ZERO, "wall", 0, true)
	assert(await _wait(func() -> bool: return _pieces().size() == 2))
	assert(main.latest_snapshot["materials"]["wood"] == 6)
	if token == "structure-a":
		await _move(Vector2.UP, 1.7)
		assert(main.latest_snapshot["positions"][token].z < 14)
	else:
		assert(await _wait(func() -> bool: return main.latest_snapshot["positions"]["structure-a"].z < 14))
	print("PASS: shared structural build, conserved wood, support-safe removal, wall collision and doorway passage — %s" % token)
	await create_timer(0.5).timeout
	quit()


func _pieces() -> Dictionary:
	return main.latest_snapshot.get("structures", {})


func _wait(check: Callable) -> bool:
	for step in range(600):
		if check.call():
			return true
		await create_timer(0.05).timeout
	return false


func _move(direction: Vector2, duration: float) -> void:
	main.submit_input.rpc_id(1, direction)
	await create_timer(duration).timeout
	main.submit_input.rpc_id(1, Vector2.ZERO)
	await create_timer(0.15).timeout
