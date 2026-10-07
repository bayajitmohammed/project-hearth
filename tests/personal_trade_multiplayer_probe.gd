extends SceneTree

const Scene = preload("res://main.tscn")
var main
var token := ""


func _init() -> void:
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with("--player-token="):
			token = argument.trim_prefix("--player-token=")
	assert(token in ["trade-a", "trade-b"])
	main = Scene.instantiate()
	root.add_child(main)
	main.local_input_enabled = false
	if "--browser-companion" in OS.get_cmdline_user_args():
		await _browser_companion()
		quit()
		return
	assert(await _wait(func() -> bool: return main.latest_snapshot.get("positions", {}).size() == 2))
	if token == "trade-a":
		main._request_trade({"action": "propose", "to": "trade-b", "give": "coin", "give_count": 2, "take": "riverfish", "take_count": 1})
	assert(await _wait(func() -> bool: return not main.latest_snapshot.get("trades", {}).get("offers", {}).is_empty()))
	var offer: Dictionary = main.latest_snapshot["trades"]["offers"].values()[0]
	assert(main.latest_snapshot["player_coins"]["trade-a"] == 4)
	if token == "trade-b":
		await create_timer(0.3).timeout
		main._request_trade({"action": "accept", "id": offer["id"]})
	assert(await _wait(func() -> bool: return main.latest_snapshot["player_coins"]["trade-a"] == 2))
	assert(main.latest_snapshot["player_coins"]["trade-b"] == 2 and main.latest_snapshot["player_riverfish"]["trade-a"] == 1 and main.latest_snapshot["player_riverfish"]["trade-b"] == 2)
	if token == "trade-b":
		main._request_trade({"action": "accept", "id": offer["id"]})
	await create_timer(0.3).timeout
	assert(main.latest_snapshot["player_coins"]["trade-a"] == 2)
	print("PASS: two-client exact offer, acceptance, conserved personal balances and replay rejection — %s" % token)
	await create_timer(0.5).timeout
	quit()


func _browser_companion() -> void:
	assert(await _wait(func() -> bool: return not main.latest_snapshot.get("trades", {}).get("offers", {}).is_empty(), 4800))
	var offer: Dictionary = main.latest_snapshot["trades"]["offers"].values()[0]
	await create_timer(3).timeout
	main._request_trade({"action": "accept", "id": offer["id"]})
	assert(await _wait(func() -> bool: return main.latest_snapshot["player_coins"][token] == 1))
	await create_timer(5).timeout
	main._request_trade({"action": "propose", "to": offer["from"], "give": "riverfish", "give_count": 1, "take": "coin", "take_count": 1})
	assert(await _wait(func() -> bool: return main.latest_snapshot["player_coins"][token] == 2, 2400))
	print("PASS: browser proposed once and explicitly accepted the companion's reverse offer")
	await create_timer(5).timeout


func _wait(check: Callable, steps: int = 600) -> bool:
	for step in range(steps):
		if check.call():
			return true
		await create_timer(0.05).timeout
	return false
