extends SceneTree

const MainScene = preload("res://main.tscn")
const WorldStateModel = preload("res://scripts/world_state.gd")
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
	assert(await _wait_until(_is_connected, "connect to the server"))
	assert(str(main.latest_snapshot.get("livelihood_stage", "")) == "food_need")

	for plot_id: String in WorldStateModel.GARDEN_PLOT_POSITIONS:
		assert(await _move_to(WorldStateModel.GARDEN_PLOT_POSITIONS[plot_id]), "Could not reach %s." % plot_id)
		main._request_interaction()
		assert(await _wait_until(
			func() -> bool: return bool(main.latest_snapshot.get("harvested_garden_plots", {}).get(plot_id, false)),
			"harvest %s" % plot_id
		))

	assert(await _move_to(WorldStateModel.COOKFIRE_POSITION), "Could not reach the cookfire.")
	for stew_target: int in [1, 2]:
		main._request_interaction()
		assert(await _wait_until(
			func() -> bool: return int(main.latest_snapshot.get("materials", {}).get("hearth_stew", 0)) == stew_target,
			"cook stew %d" % stew_target
		))

	assert(await _move_to(WorldStateModel.MARKET_CRATE_POSITION), "Could not reach the market crate.")
	for delivery_target: int in [1, 2]:
		main._request_interaction()
		assert(await _wait_until(
			func() -> bool: return int(main.latest_snapshot.get("stews_delivered", 0)) == delivery_target,
			"deliver stew %d" % delivery_target
		))

	assert(str(main.latest_snapshot.get("livelihood_stage", "")) == "complete")
	assert(bool(main.latest_snapshot.get("produce_stall_open", false)))
	var mastery: Dictionary = main.latest_snapshot.get("player_mastery", {}).get(token, {})
	assert(mastery == {"farming": 4, "cooking": 2, "trade": 2, "building": 0, "combat": 0, "exploration": 0})
	print("PASS: Multiplayer Choose a Life loop and personal mastery")
	quit()


func _move_to(target: Vector3) -> bool:
	var deadline := Time.get_ticks_msec() + int(TIMEOUT_SECONDS * 1000.0)
	while Time.get_ticks_msec() < deadline:
		var position: Vector3 = main.latest_snapshot.get("positions", {}).get(token, Vector3.INF)
		if position.is_finite():
			var difference := target - position
			var planar := Vector2(difference.x, difference.z)
			if planar.length() <= 0.3:
				main.submit_input.rpc_id(1, Vector2.ZERO)
				return true
			main.submit_input.rpc_id(1, planar.normalized())
		await create_timer(STEP_SECONDS).timeout
	main.submit_input.rpc_id(1, Vector2.ZERO)
	return false


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


func _argument(prefix: String) -> String:
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with(prefix):
			return argument.trim_prefix(prefix)
	return ""
