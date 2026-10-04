extends SceneTree

const MainScene = preload("res://main.tscn")
const STEP_SECONDS := 0.05
const TIMEOUT_SECONDS := 20.0

var main
var token := ""
var role := ""


func _init() -> void:
	token = _argument("--player-token=")
	role = _argument("--probe-role=")
	assert(token in ["supply-a", "supply-b"], "Use a supply probe identity.")
	main = MainScene.instantiate()
	root.add_child(main)
	main.local_input_enabled = false
	assert(await _wait_until(_is_connected, "connect to the supply room"))
	if role == "browser-observer":
		assert(token == "supply-a")
		assert(await _wait_until(func() -> bool: return _active_player_count() >= 2, "see the browser observer"))
		assert(_stock() == 1)
		main._request_interaction()
		assert(await _wait_until(func() -> bool: return _stock() == 0, "sell the final unit"))
		print("PASS: Browser daily-supply partner — final unit sold")
		quit()
		return
	assert(await _wait_until(_both_players_visible, "see both supply buyers"))
	main._request_interaction()
	assert(await _wait_until(_last_unit_resolved, "resolve the last shared supply unit"))
	assert(_stock() == 0)
	assert(_provisions("supply-a") + _provisions("supply-b") == 1)
	assert(_coins("supply-a") + _coins("supply-b") == 2)
	print("PASS: Daily supply probe %s — last unit purchased once" % token)
	quit()


func _wait_until(check: Callable, description: String) -> bool:
	var deadline := Time.get_ticks_msec() + int(TIMEOUT_SECONDS * 1000.0)
	while Time.get_ticks_msec() < deadline:
		if check.call():
			return true
		await create_timer(STEP_SECONDS).timeout
	push_error("Timed out waiting to %s." % description)
	return false


func _is_connected() -> bool:
	return main.client_connected and not main.latest_snapshot.is_empty()


func _both_players_visible() -> bool:
	var positions: Dictionary = main.latest_snapshot.get("positions", {})
	return positions.has("supply-a") and positions.has("supply-b")


func _active_player_count() -> int:
	return main.latest_snapshot.get("positions", {}).size()


func _last_unit_resolved() -> bool:
	return (
		_stock() == 0
		and _provisions("supply-a") + _provisions("supply-b") == 1
		and _coins("supply-a") + _coins("supply-b") == 2
	)


func _stock() -> int:
	return int(main.latest_snapshot.get("supply_basket_stock", -1))


func _provisions(player_token: String) -> int:
	return int(main.latest_snapshot.get("player_provisions", {}).get(player_token, -1))


func _coins(player_token: String) -> int:
	return int(main.latest_snapshot.get("player_coins", {}).get(player_token, -1))


func _argument(prefix: String) -> String:
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with(prefix):
			return argument.trim_prefix(prefix)
	return ""
