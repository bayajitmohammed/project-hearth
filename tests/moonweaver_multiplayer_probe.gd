extends SceneTree

const Scene = preload("res://main.tscn")
var main
var token := ""
var saw_trace := false


func _init() -> void:
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with("--player-token="):
			token = argument.trim_prefix("--player-token=")
	assert(token in ["magic-a", "magic-b"])
	main = Scene.instantiate()
	root.add_child(main)
	main.local_input_enabled = false
	assert(await _wait(func() -> bool: return int(main.latest_snapshot.get("active_player_count", 0)) == 2))
	if token == "magic-a":
		main._request_attack()
	assert(await _wait(func() -> bool: return int(main.latest_snapshot.get("creature_health", 3)) == 2))
	assert(saw_trace and main.spell_view.beams.has("magic-a"))
	assert(main.latest_snapshot["player_outing_kits"]["magic-b"] == "guardian")
	assert(await _wait(func() -> bool: return float(main.latest_snapshot.get("player_attack_recovery", {}).get("magic-a", 1)) <= 0))
	if token == "magic-a":
		main._request_power_strike()
	assert(await _wait(func() -> bool: return bool(main.latest_snapshot.get("creature_defeated", false))))
	assert(main.latest_snapshot["player_mastery"]["magic-a"]["combat"] == 2)
	assert(main.latest_snapshot["player_mastery"]["magic-b"]["combat"] == 0)
	assert(main.latest_snapshot["player_health"][token] == 3)
	assert(await _wait(func() -> bool: return main.latest_snapshot.get("spell_traces", {}).is_empty()))
	print("PASS: synchronized ranged magic and traces, independent kits, conserved damage/credit, safe companion and transient expiry — %s" % token)
	await create_timer(0.5).timeout
	quit()


func _wait(check: Callable) -> bool:
	for step in range(600):
		if not main.latest_snapshot.get("spell_traces", {}).is_empty():
			saw_trace = true
		if check.call():
			return true
		await create_timer(0.025).timeout
	return false
