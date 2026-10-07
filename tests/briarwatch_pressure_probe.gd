extends SceneTree

const Scene = preload("res://main.tscn")
var main
var token := ""


func _init() -> void:
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with("--player-token="):
			token = argument.trim_prefix("--player-token=")
	assert(token in ["pressure-a", "pressure-b"])
	main = Scene.instantiate()
	root.add_child(main)
	main.local_input_enabled = false
	if "--browser-companion" in OS.get_cmdline_user_args():
		for step in range(4800):
			var windup := float(main.latest_snapshot.get("briarwatch_windup", 0))
			if windup > 0 and windup <= 0.35:
				main._request_brace()
			await create_timer(0.05).timeout
		quit()
		return
	assert(await _wait(func() -> bool: return main.latest_snapshot.get("briarwatch_pulse_positions", []).size() == 2 and float(main.latest_snapshot.get("briarwatch_windup", 0)) > 0))
	assert(main.briarwatch.pulses[0].visible and main.briarwatch.pulses[1].visible)
	assert(await _wait(func() -> bool: return float(main.latest_snapshot["briarwatch_windup"]) <= 0.35))
	main._request_brace()
	assert(await _wait(func() -> bool: return float(main.latest_snapshot["briarwatch_windup"]) == 0))
	assert(main.latest_snapshot["player_health"][token] == 3)
	if token == "pressure-a":
		main.submit_input.rpc_id(1, Vector2.DOWN)
		await create_timer(1.8).timeout
		main.submit_input.rpc_id(1, Vector2.ZERO)
	assert(await _wait(func() -> bool: return main.latest_snapshot.get("briarwatch_pulse_positions", []).size() == 1 and float(main.latest_snapshot["briarwatch_windup"]) > 0))
	assert(main.latest_snapshot["broken_briarwatch_bindings"] == {"west": true})
	assert(main.briarwatch.warning.visible == (token == "pressure-b"))
	print("PASS: two synchronized marks, timed defense, withdrawal downscaling and preserved bindings — %s" % token)
	quit()


func _wait(check: Callable) -> bool:
	for step in range(600):
		if check.call():
			return true
		await create_timer(0.05).timeout
	return false
