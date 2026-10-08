extends SceneTree

const Scene = preload("res://main.tscn")
const World = preload("res://scripts/world_state.gd")
var main
var token := ""


func _init() -> void:
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with("--player-token="):
			token = argument.trim_prefix("--player-token=")
	assert(token in ["route-a", "route-b"])
	main = Scene.instantiate()
	root.add_child(main)
	main.local_input_enabled = false
	assert(await _wait(func() -> bool: return main.latest_snapshot.get("active_player_count", 0) == 2))
	var post := World.Wilderness.outpost_position(112358) + Vector3(0, 0, -4)
	assert(await _move_to(post))
	main._request_interaction()
	assert(await _wait(func() -> bool: return main.latest_snapshot.get("fartrail_route_parts", {}).size() == 2))
	assert(main.latest_snapshot["materials"]["wood"] == 0 and main.latest_snapshot["materials"]["herb"] == 0)
	assert(main.latest_snapshot["player_mastery"]["route-a"]["building"] + main.latest_snapshot["player_mastery"]["route-b"]["building"] == 1)
	assert(main.latest_snapshot["chronicle"].size() == 1)
	if token == "route-a":
		main._request_interaction()
		assert(await _wait(func() -> bool: return _position("route-a").distance_to(World.FARTRAIL_HOME_ARRIVAL) < 0.1))
		assert(_position("route-b").distance_to(post) < 0.7)
		assert(await _wait(func() -> bool: return _position("route-b").distance_to(World.FARTRAIL_HOME_ARRIVAL) < 0.1))
		assert(await _move_to(World.FARTRAIL_HOME_POST))
		main._request_interaction()
	else:
		assert(await _wait(func() -> bool: return _position("route-a").distance_to(World.FARTRAIL_HOME_ARRIVAL) < 0.1))
		await create_timer(0.4).timeout
		main._request_interaction()
	assert(await _wait(func() -> bool: return _position("route-a").distance_to(post + Vector3(0, 0, -2.5)) < 0.1 and _position("route-b").distance_to(World.FARTRAIL_HOME_ARRIVAL) < 0.1))
	assert(main.fartrail_route_view.lights[0].visible)
	print("PASS: shared route jobs, conserved materials, independent two-way travel — ", token)
	await create_timer(0.5).timeout
	quit()


func _position(identity: String) -> Vector3:
	return main.latest_snapshot.get("positions", {}).get(identity, Vector3.INF)


func _wait(check: Callable) -> bool:
	for step in range(400):
		if check.call():
			return true
		await create_timer(0.05).timeout
	return false


func _move_to(target: Vector3) -> bool:
	for step in range(400):
		var offset := target - _position(token)
		if offset.length() <= 0.6:
			main.submit_input.rpc_id(1, Vector2.ZERO)
			return true
		main.submit_input.rpc_id(1, Vector2(offset.x, offset.z).normalized())
		await create_timer(0.05).timeout
	return false
