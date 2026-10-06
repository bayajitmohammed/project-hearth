extends SceneTree

const Scene = preload("res://main.tscn")
const State = preload("res://scripts/world_state.gd")
var main
var token := ""


func _init() -> void:
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with("--player-token="):
			token = argument.trim_prefix("--player-token=")
	assert(token in ["briar-a", "briar-b"])
	main = Scene.instantiate()
	root.add_child(main)
	main.local_input_enabled = false
	assert(await _wait(func() -> bool: return main.latest_snapshot.get("positions", {}).size() == 2))
	if token == "briar-a":
		main._request_interaction()
	assert(await _wait(func() -> bool: return _stage() == "bindings"))
	if token == "briar-b":
		main._request_interaction()
		assert(await _wait(func() -> bool: return main.latest_snapshot.get("broken_briarwatch_bindings", {}).has("west")))
		assert(await _move_to(Vector3(-8, 0.6, -53))) # Withdraw after contributing; the outing persists.
	else:
		for binding_id in ["east", "north"]:
			assert(await _move_to(State.BRIARWATCH_BINDINGS[binding_id]))
			main._request_interaction()
			assert(await _wait(func() -> bool: return main.latest_snapshot.get("broken_briarwatch_bindings", {}).has(binding_id)))
		assert(await _move_to(State.BRIARWATCH_BEACON))
		main._request_interaction()
	assert(await _wait(func() -> bool: return _stage() == "complete"))
	assert(main.latest_snapshot["player_mastery"]["briar-a"]["exploration"] == 2)
	assert(main.latest_snapshot["player_mastery"]["briar-b"]["exploration"] == 1)
	assert(main.latest_snapshot["reputation"] == 1)
	assert(main.latest_snapshot["chronicle"].size() == 1)
	assert(main.briarwatch.beacon_beam.visible and not main.briarwatch.spirit.visible)
	print("PASS: shared Briarwatch outing, split bindings, retreat, personal credit, and safe beacon — %s" % token)
	await create_timer(0.5).timeout
	quit()


func _stage() -> String:
	return str(main.latest_snapshot.get("briarwatch_stage", ""))


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
	main.submit_input.rpc_id(1, Vector2.ZERO)
	return false
