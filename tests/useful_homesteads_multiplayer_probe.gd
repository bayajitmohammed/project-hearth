extends SceneTree

const Scene = preload("res://main.tscn")
var main
var token := ""


func _init() -> void:
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with("--player-token="):
			token = argument.trim_prefix("--player-token=")
	assert(token in ["station-a", "station-b"])
	main = Scene.instantiate()
	root.add_child(main)
	main.local_input_enabled = false
	assert(await _wait(func() -> bool: return main.latest_snapshot.get("positions", {}).size() == 2))
	main._request_interaction()
	assert(await _wait(func() -> bool: return main.latest_snapshot["player_health"]["station-a"] == 3 and main.latest_snapshot["player_provisions"]["station-b"] == 1))
	assert(main.latest_snapshot["player_health"]["station-b"] == 3)
	assert(main.latest_snapshot["materials"]["wood"] == 0 and main.latest_snapshot["materials"]["herb"] == 0)
	assert(main.latest_snapshot["player_provisions"]["station-a"] == 0)
	assert(main.homestead_builder.station_markers.size() == 2)
	main._request_interaction()
	await create_timer(0.5).timeout
	assert(main.latest_snapshot["player_provisions"]["station-b"] == 1)
	print("PASS: shared homestead stations recover one companion and craft conserved personal supplies — %s" % token)
	quit()


func _wait(check: Callable) -> bool:
	for step in range(600):
		if check.call():
			return true
		await create_timer(0.05).timeout
	return false
