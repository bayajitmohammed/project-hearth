extends SceneTree

const MainScene = preload("res://main.tscn")
const STEP_SECONDS := 0.05
const TIMEOUT_SECONDS := 20.0

var main
var token := ""


func _init() -> void:
	token = _argument("--player-token=")
	assert(not token.is_empty(), "A unique --player-token is required.")
	main = MainScene.instantiate()
	root.add_child(main)
	main.local_input_enabled = false
	assert(await _wait_until(_room_is_full, "observe all eight players"))
	assert(int(main.latest_snapshot.get("max_players", 0)) == 8)
	assert(main.latest_snapshot.get("positions", {}).has(token))
	await create_timer(1.0).timeout
	print("PASS: Eight-player capacity probe %s" % token)
	quit()


func _wait_until(check: Callable, description: String) -> bool:
	var deadline := Time.get_ticks_msec() + int(TIMEOUT_SECONDS * 1000.0)
	while Time.get_ticks_msec() < deadline:
		if check.call():
			return true
		await create_timer(STEP_SECONDS).timeout
	push_error("Timed out waiting to %s." % description)
	return false


func _room_is_full() -> bool:
	return (
		main.client_connected
		and int(main.latest_snapshot.get("active_player_count", 0)) == 8
		and main.latest_snapshot.get("positions", {}).size() == 8
	)


func _argument(prefix: String) -> String:
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with(prefix):
			return argument.trim_prefix(prefix)
	return ""
