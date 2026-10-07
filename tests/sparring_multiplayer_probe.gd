extends SceneTree

const Scene = preload("res://main.tscn")
const Rules = preload("res://scripts/sparring_rules.gd")
var main
var token := ""


func _init() -> void:
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with("--player-token="):
			token = argument.trim_prefix("--player-token=")
	assert(token in ["spar-a", "spar-b"])
	main = Scene.instantiate()
	root.add_child(main)
	main.local_input_enabled = false
	if "--browser-companion" in OS.get_cmdline_user_args():
		assert(await _wait(func() -> bool: return main.latest_snapshot.get("sparring", {}).get("stage", "") == "waiting"))
		main._request_interaction()
		assert(await _wait(func() -> bool: return main.latest_snapshot.get("sparring", {}).get("stage", "") == "results"))
		await create_timer(10).timeout
		quit()
		return
	assert(await _wait(func() -> bool: return main.latest_snapshot.get("positions", {}).size() == 2))
	main._request_interaction()
	assert(await _wait(func() -> bool: return _match().get("stage", "") == "active"))
	assert(main.sparring_circle.status.visible)
	if token == "spar-a":
		var point: Vector3 = main.latest_snapshot["positions"][token]
		main.submit_input.rpc_id(1, Vector2.RIGHT if point.x < Rules.CENTER.x else Vector2.LEFT)
		await create_timer(0.35).timeout
		main.submit_input.rpc_id(1, Vector2.ZERO)
		await create_timer(0.15).timeout
		for hit in range(3):
			main._request_power_strike()
			await create_timer(0.8).timeout
	assert(await _wait(func() -> bool: return _match().get("stage", "") == "results"))
	assert(_match()["last_winner"] == "spar-a" and _match()["ribbons"] == {"spar-a": 1, "spar-b": 1})
	assert(main.latest_snapshot["player_health"]["spar-a"] == 3 and main.latest_snapshot["player_health"]["spar-b"] == 3)
	assert(main.latest_snapshot["player_mastery"][token]["combat"] == 0)
	print("PASS: two explicit volunteers, normalized match result, persistent cosmetic ribbons and unchanged world health — %s" % token)
	await create_timer(0.5).timeout
	quit()


func _match() -> Dictionary:
	return main.latest_snapshot.get("sparring", {})


func _wait(check: Callable) -> bool:
	for step in range(1800):
		if check.call():
			return true
		await create_timer(0.05).timeout
	return false
