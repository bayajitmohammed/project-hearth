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
	assert(token in ["keepsake-a", "keepsake-b"], "Use a Mara-keepsake probe identity.")
	main = MainScene.instantiate()
	root.add_child(main)
	main.local_input_enabled = false
	assert(await _wait_until(_is_connected, "connect to the keepsake room"))
	if role == "browser-observer":
		assert(token == "keepsake-a")
		assert(await _wait_until(func() -> bool: return _active_player_count() >= 2, "see the browser observer"))
		assert(_has_keepsake("keepsake-a"))
		assert(_charm_visible("keepsake-a"))
		print("PASS: Browser Mara-keepsake partner — charm visible")
		await create_timer(15.0).timeout
		quit()
		return
	assert(await _wait_until(_both_players_visible, "see both keepsake players"))
	assert(_has_keepsake("keepsake-a"))
	assert(not _has_keepsake("keepsake-b"))
	assert(_charm_visible("keepsake-a"))
	assert(not _charm_visible("keepsake-b"))
	if token == "keepsake-b":
		main._request_interaction()
	assert(await _wait_until(_new_keepsake_visible, "share Mara's newly awarded keepsake"))
	assert(_rapport("keepsake-b") == 3)
	assert(_has_keepsake("keepsake-b"))
	assert(_charm_visible("keepsake-b"))
	print("PASS: Mara keepsake probe %s — milestone visible to both peers" % token)
	await create_timer(1.0).timeout
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
	return main.player_nodes.has("keepsake-a") and main.player_nodes.has("keepsake-b")


func _active_player_count() -> int:
	return main.latest_snapshot.get("positions", {}).size()


func _new_keepsake_visible() -> bool:
	return _rapport("keepsake-b") == 3 and _has_keepsake("keepsake-b") and _charm_visible("keepsake-b")


func _rapport(player_token: String) -> int:
	return int(main.latest_snapshot.get("player_relationships", {}).get(player_token, {}).get("mara", -1))


func _has_keepsake(player_token: String) -> bool:
	return bool(main.latest_snapshot.get("player_mara_keepsakes", {}).get(player_token, false))


func _charm_visible(player_token: String) -> bool:
	if not main.player_nodes.has(player_token):
		return false
	var charm := main.player_nodes[player_token].get_node_or_null("MaraKeepsake") as MeshInstance3D
	return charm != null and charm.visible


func _argument(prefix: String) -> String:
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with(prefix):
			return argument.trim_prefix(prefix)
	return ""
