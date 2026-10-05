extends SceneTree

const Scene = preload("res://main.tscn")
const State = preload("res://scripts/world_state.gd")
var main
var token := ""


func _init() -> void:
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with("--player-token="):
			token = argument.trim_prefix("--player-token=")
	assert(token in ["reedbank-a", "reedbank-b"])
	main = Scene.instantiate()
	root.add_child(main)
	main.local_input_enabled = false
	assert(await _wait(func() -> bool: return main.latest_snapshot.get("positions", {}).size() == 2))
	if token == "reedbank-a":
		main._request_interaction()
		assert(await _wait(func() -> bool: return _stage() == "recover_sail"))
		assert(await _move_to(State.REEDBANK_SAIL_POSITION))
		main._request_interaction()
	assert(await _wait(func() -> bool: return _stage() == "repair_mill"))
	if token == "reedbank-b":
		await create_timer(0.4).timeout
		main._request_interaction()
	assert(await _wait(func() -> bool: return _stage() == "return_oren"))
	if token == "reedbank-b":
		assert(await _move_to(State.OREN_MILL_POSITION))
		main._request_interaction()
	assert(await _wait(func() -> bool: return _stage() == "complete"))
	assert(main.latest_snapshot["materials"]["wood"] == 0)
	assert(main.latest_snapshot["player_mastery"]["reedbank-a"]["exploration"] == 1)
	assert(main.latest_snapshot["player_mastery"]["reedbank-b"]["building"] == 1)
	assert(main.latest_snapshot["chronicle"].size() == 1)
	assert(main.reedbank.turning and main.reedbank.shelter_light.visible)
	print("PASS: Reedbank two-client handoff, conserved wood, personal credit, shared mill — %s" % token)
	await create_timer(0.5).timeout
	quit()


func _stage() -> String:
	return str(main.latest_snapshot.get("reedbank_stage", ""))


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
