extends SceneTree

const Scene = preload("res://main.tscn")
var main
var token := ""


func _init() -> void:
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with("--player-token="):
			token = argument.trim_prefix("--player-token=")
	assert(token in ["kitchen-a", "kitchen-b"])
	main = Scene.instantiate()
	root.add_child(main)
	main.local_input_enabled = false
	assert(await _wait(func() -> bool: return main.latest_snapshot.get("positions", {}).size() == 2))
	if token == "kitchen-a":
		main._request_interaction()
	assert(await _wait(func() -> bool: return main.latest_snapshot["materials"]["sunwheat"] == 2))
	if token == "kitchen-b":
		main._request_interaction()
		assert(await _wait(func() -> bool: return main.latest_snapshot["materials"]["flour"] == 1))
		main.submit_input.rpc_id(1, Vector2.RIGHT)
		await create_timer(0.75).timeout
		main.submit_input.rpc_id(1, Vector2.ZERO)
		await create_timer(0.15).timeout
		main._request_interaction()
	assert(await _wait(func() -> bool: return main.latest_snapshot.get("player_provisions", {}).get("kitchen-b", 0) == 2))
	assert(main.latest_snapshot["materials"]["sunwheat"] == 0 and main.latest_snapshot["materials"]["flour"] == 0 and main.latest_snapshot["materials"]["herb"] == 0)
	assert(main.latest_snapshot["player_mastery"]["kitchen-a"]["farming"] == 1)
	assert(main.latest_snapshot["player_mastery"]["kitchen-b"]["cooking"] == 1)
	assert(main.latest_snapshot["player_provisions"]["kitchen-a"] == 0)
	assert(main.homestead_builder.station_markers.size() == 4)
	print("PASS: player-built farm-to-mill-to-oven handoff conserves ingredients and personal credit — %s" % token)
	await create_timer(0.5).timeout
	quit()


func _wait(check: Callable) -> bool:
	for step in range(600):
		if check.call():
			return true
		await create_timer(0.05).timeout
	return false
