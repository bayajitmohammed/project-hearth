extends SceneTree

const Scene = preload("res://main.tscn")
var main
var token := ""


func _init() -> void:
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with("--player-token="):
			token = argument.trim_prefix("--player-token=")
	assert(token in ["guest-a", "guest-b"])
	main = Scene.instantiate()
	root.add_child(main)
	main.local_input_enabled = false
	assert(await _wait(func() -> bool: return main.latest_snapshot.get("positions", {}).size() == 2))
	assert(main.latest_snapshot["homestead_guest"]["plot"] == "2,2")
	if token == "guest-a":
		main._request_interaction()
	assert(await _wait(func() -> bool: return main.latest_snapshot["homestead_guest"]["met"]))
	main._request_interaction()
	assert(await _wait(func() -> bool: return main.latest_snapshot["homestead_guest"]["meals"] == 2))
	assert(main.latest_snapshot["player_provisions"]["guest-a"] == 0 and main.latest_snapshot["player_provisions"]["guest-b"] == 0)
	assert(main.latest_snapshot["chronicle"].size() == 1)
	assert(main.wilderness.guest_awning.visible)
	main._request_interaction()
	assert(await _wait(func() -> bool: return main.latest_snapshot["player_relationships"].get(token, {}).get("sera", 0) == (2 if token == "guest-a" else 1)))
	main._request_interaction()
	await create_timer(0.3).timeout
	assert(main.latest_snapshot["chronicle"].size() == 1)
	print("PASS: shared Sera welcome, two conserved contributions, persistent camp and independent daily rapport — %s" % token)
	await create_timer(0.5).timeout
	quit()


func _wait(check: Callable) -> bool:
	for step in range(600):
		if check.call():
			return true
		await create_timer(0.05).timeout
	return false
