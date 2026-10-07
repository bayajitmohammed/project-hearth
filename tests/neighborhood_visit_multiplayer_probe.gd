extends SceneTree

const Scene = preload("res://main.tscn")
var main
var token := ""


func _init() -> void:
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with("--player-token="):
			token = argument.trim_prefix("--player-token=")
	assert(token in ["visit-a", "visit-b"])
	main = Scene.instantiate()
	root.add_child(main)
	main.local_input_enabled = false
	assert(await _wait(func() -> bool: return main.latest_snapshot.get("positions", {}).size() == 2 and main.latest_snapshot.get("neighborhood_visits", {}).get("active", "") == "travelers"))
	for index in range(2):
		main._request_interaction()
		await create_timer(0.2).timeout
	assert(await _wait(func() -> bool: return main.latest_snapshot["neighborhood_visits"]["completed"].get("travelers", 0) == 1))
	assert(main.latest_snapshot["materials"]["wood"] == 0)
	assert(main.latest_snapshot["player_provisions"]["visit-b"] == 0)
	assert(main.latest_snapshot["pantry_stock"] == 3 and main.latest_snapshot["chronicle"].size() == 1)
	assert(main.neighborhood_visit_view.canopy.visible and not main.neighborhood_visit_view.visitors.visible)
	main._request_interaction()
	await create_timer(0.2).timeout
	assert(main.latest_snapshot["neighborhood_visits"]["completed"]["travelers"] == 1)
	print("PASS: two-client split visit jobs, conserved goods, one shared completion and permanent canopy — %s" % token)
	await create_timer(0.5).timeout
	quit()


func _wait(check: Callable) -> bool:
	for step in range(600):
		if check.call():
			return true
		await create_timer(0.05).timeout
	return false
