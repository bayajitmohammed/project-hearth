extends SceneTree

const MainScene = preload("res://main.tscn")
const WorldStateModel = preload("res://scripts/world_state.gd")
const STEP_SECONDS := 0.05
const TIMEOUT_SECONDS := 20.0

var main
var token := ""


func _init() -> void:
	token = _argument("--player-token=")
	assert(token in ["kit-a", "kit-b"], "Use a kit-a or kit-b identity.")
	main = MainScene.instantiate()
	root.add_child(main)
	main.local_input_enabled = false
	assert(await _wait_until(_is_connected, "connect to the kit room"))
	assert(await _wait_until(_both_players_visible, "see both kit players"))
	assert(_kit("kit-a") == WorldStateModel.OUTING_KIT_VANGUARD)
	assert(_kit("kit-b") == WorldStateModel.OUTING_KIT_VANGUARD)

	if token == "kit-a":
		main._request_interaction()
	assert(await _wait_until(
		func() -> bool: return _kit("kit-a") == WorldStateModel.OUTING_KIT_GUARDIAN,
		"equip kit-a's Guardian kit"
	))
	assert(_kit("kit-b") == WorldStateModel.OUTING_KIT_VANGUARD, "One player's loadout must not change a companion's.")

	if token == "kit-b":
		main._request_interaction()
	assert(await _wait_until(
		func() -> bool: return _kit("kit-b") == WorldStateModel.OUTING_KIT_GUARDIAN,
		"equip kit-b's Guardian kit"
	))
	assert(_kit("kit-a") == WorldStateModel.OUTING_KIT_GUARDIAN)

	if token == "kit-a":
		main._request_interaction()
	assert(await _wait_until(
		func() -> bool: return _kit("kit-a") == WorldStateModel.OUTING_KIT_VANGUARD,
		"switch kit-a back to Vanguard"
	))
	assert(_kit("kit-b") == WorldStateModel.OUTING_KIT_GUARDIAN)
	print("PASS: Outing-kit multiplayer probe %s — personal, synchronized, reversible" % token)
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
	return positions.has("kit-a") and positions.has("kit-b")


func _kit(player_token: String) -> String:
	return str(
		main.latest_snapshot.get("player_outing_kits", {}).get(
			player_token, WorldStateModel.OUTING_KIT_VANGUARD
		)
	)


func _argument(prefix: String) -> String:
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with(prefix):
			return argument.trim_prefix(prefix)
	return ""
