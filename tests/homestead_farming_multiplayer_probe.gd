extends SceneTree

const Scene = preload("res://main.tscn")
var main
var token := ""


func _init() -> void:
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with("--player-token="):
			token = argument.trim_prefix("--player-token=")
	assert(token in ["farmer-a", "farmer-b"])
	main = Scene.instantiate()
	root.add_child(main)
	main.local_input_enabled = false
	assert(await _wait(func() -> bool: return main.latest_snapshot.get("positions", {}).size() == 2))
	main._request_interaction()
	assert(await _wait(func() -> bool: return main.latest_snapshot.get("materials", {}).get("moonroot", 0) == 1))
	await create_timer(0.4).timeout
	var state: Dictionary = main.latest_snapshot
	assert(state["player_mastery"]["farmer-a"]["farming"] + state["player_mastery"]["farmer-b"]["farming"] == 1)
	assert(state["materials"]["wood"] == 6)
	assert(state["homestead_planted_at"].has("/0,0"), "Second action replants instead of duplicating ripe produce.")
	assert("growing" in main.homestead_builder.station_markers["/0,0"].get_node("Label").text)
	main._request_interaction()
	await create_timer(0.4).timeout
	assert(main.latest_snapshot["materials"]["moonroot"] == 1)
	print("PASS: concurrent shared-bed harvest yields once, credits one farmer and synchronizes replant — %s" % token)
	quit()


func _wait(check: Callable) -> bool:
	for step in range(600):
		if check.call():
			return true
		await create_timer(0.05).timeout
	return false
