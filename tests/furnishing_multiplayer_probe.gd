extends SceneTree

const MainScene = preload("res://main.tscn")
var main
var token := ""
var first_kind := "bench"
var second_kind := "flower_box"


func _init() -> void:
	if "--keepsakes" in OS.get_cmdline_user_args():
		first_kind = "watch_lantern"
		second_kind = "gathering_table"
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with("--player-token="):
			token = argument.trim_prefix("--player-token=")
	assert(token in ["builder-a", "builder-b"])
	main = MainScene.instantiate()
	root.add_child(main)
	main.local_input_enabled = false
	if not await _wait(func() -> bool: return main.latest_snapshot.get("positions", {}).size() == 2):
		return
	main._request_furnishing(Vector2i.ZERO, first_kind, 1, false)
	if not await _wait(func() -> bool: return main.latest_snapshot.get("furnishings", {}).has("0,0")):
		return
	assert(int(main.latest_snapshot["materials"]["wood"]) == 2)
	assert(main.latest_snapshot["furnishings"].size() == 1)
	assert(int(main.latest_snapshot["furnishings"]["0,0"]["rotation"]) == 1)
	if token == "builder-b":
		await create_timer(0.6).timeout
		main._request_furnishing(Vector2i.ZERO, "", 0, true)
		main._request_furnishing(Vector2i(1, 0), second_kind, 3, false)
	if not await _wait(func() -> bool: return main.latest_snapshot.get("furnishings", {}).has("1,0")):
		return
	assert(not main.latest_snapshot["furnishings"].has("0,0"))
	assert(int(main.latest_snapshot["materials"]["wood"]) == 2)
	assert(main.latest_snapshot["furnishings"]["1,0"]["kind"] == second_kind)
	assert(int(main.latest_snapshot["furnishings"]["1,0"]["rotation"]) == 3)
	print("PASS: furnishing probe %s — contested placement and companion rearrangement conserved wood" % token)
	await create_timer(0.5).timeout
	quit()


func _wait(check: Callable) -> bool:
	var deadline := Time.get_ticks_msec() + 15000
	while Time.get_ticks_msec() < deadline:
		if check.call():
			return true
		await create_timer(0.05).timeout
	push_error("Furnishing multiplayer probe timed out")
	quit(1)
	return false
