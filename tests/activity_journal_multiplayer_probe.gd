extends SceneTree

const Scene = preload("res://main.tscn")
var main
var token := ""


func _init() -> void:
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with("--player-token="):
			token = argument.trim_prefix("--player-token=")
	assert(token in ["journal-a", "journal-b"])
	main = Scene.instantiate()
	root.add_child(main)
	main.local_input_enabled = false
	assert(await _wait(func() -> bool: return main.latest_snapshot.get("positions", {}).size() == 2))
	main._request_activity_pin("fishing" if token == "journal-a" else "sunwheat")
	assert(await _wait(func() -> bool: return _pin("journal-a") == "fishing" and _pin("journal-b") == "sunwheat"))
	assert(main.quest_title_label.text.contains("PINNED"))
	assert(main.activity_journal.selected == ("fishing" if token == "journal-a" else "sunwheat"))
	if token == "journal-a":
		await create_timer(0.5).timeout
		main._request_activity_pin("invented")
		await create_timer(0.3).timeout
		assert(_pin(token) == "fishing")
		main._request_activity_pin("automatic")
	assert(await _wait(func() -> bool: return _pin("journal-a") == "automatic"))
	assert(_pin("journal-b") == "sunwheat")
	assert(main.latest_snapshot.get("chronicle", []).is_empty())
	print("PASS: independent journal pins, invalid rejection, and personal automatic reset — %s" % token)
	await create_timer(0.5).timeout
	quit()


func _pin(player_token: String) -> String:
	return str(main.latest_snapshot.get("player_activity_pins", {}).get(player_token, "automatic"))


func _wait(check: Callable) -> bool:
	for step in range(400):
		if check.call():
			return true
		await create_timer(0.05).timeout
	return false
