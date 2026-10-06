extends SceneTree

const State = preload("res://scripts/world_state.gd")
const Scene = preload("res://main.tscn")


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var world := State.new()
	for token in ["a", "b"]:
		world.register_player(token)
	world.positions["a"] = State.BRIARWATCH_ENTRANCE
	assert(not world.try_briarwatch_interaction("a"))
	world.ruin_waystone_activated = true
	assert(world.interact("a"))
	assert(world.briarwatch_stage == "bindings")
	world.positions["a"] = Vector3(0, 0.6, -60)
	world.positions["b"] = Vector3(8, 0.6, -60)
	assert(not world.simulate_briarwatch(3.1, ["a", "b"]))
	assert(world.briarwatch_windup == State.BRIARWATCH_WARNING_SECONDS)
	var marked: Vector3 = world.briarwatch_pulse_position
	world.positions["a"] = marked + Vector3(3, 0, 0)
	assert(not world.simulate_briarwatch(1.3, ["a", "b"]))
	assert(world.player_health["a"] == 3, "Moving away evades a mark that does not chase.")
	world.simulate_briarwatch(3.1, ["a", "b"])
	assert(world.briarwatch_pulse_position == world.positions["b"], "Pressure rotates through eligible players.")
	assert(world.try_brace("b"))
	world.simulate_briarwatch(1.3, ["a", "b"])
	assert(world.player_health["b"] == 3 and world.player_brace_time["b"] == 0)
	world.simulate_briarwatch(3.1, ["a", "b"])
	assert(world.simulate_briarwatch(1.3, ["a", "b"]))
	assert(world.player_health["a"] == 2)
	world.simulate_briarwatch(3.1, ["a", "b"])
	world.simulate_briarwatch(0.1, [])
	assert(world.briarwatch_windup == 0, "Empty worlds cancel pressure.")
	var guarded := State.new()
	for token in ["a", "b"]:
		guarded.register_player(token)
	guarded.ruin_waystone_activated = true
	guarded.briarwatch_stage = "bindings"
	guarded.positions["a"] = Vector3(0, 0.6, -60)
	guarded.positions["b"] = Vector3(1, 0.6, -60)
	guarded.player_outing_kits["b"] = State.OUTING_KIT_GUARDIAN
	guarded.simulate_briarwatch(3.1, ["a", "b"])
	assert(guarded.try_brace("b"))
	guarded.simulate_briarwatch(1.3, ["a", "b"])
	assert(guarded.player_health["a"] == 3 and guarded.guardian_intercept_player == "b")
	assert(guarded.player_health["b"] == 2, "An interceptor's spent brace cannot also block their own area hit.")
	guarded.simulate_briarwatch(3.1, ["a", "b"])
	guarded.positions["a"] = State.SPAWN_POINT
	guarded.positions["b"] = State.SPAWN_POINT
	guarded.simulate_briarwatch(2.0, ["a", "b"])
	assert(guarded.briarwatch_windup == 0 and guarded.player_health["b"] == 2)
	guarded.positions["a"] = Vector3(30, 0.6, -47)
	assert(guarded.move_player("a", Vector2.UP, 2).z == -48)
	world.positions["a"] = State.BRIARWATCH_BINDINGS["west"]
	assert(world.interact("a"))
	assert(not world.try_briarwatch_interaction("a"))
	world.simulate_briarwatch(3.1, ["a"])
	var restored := State.new()
	restored.load_dictionary(world.to_dictionary())
	assert(restored.briarwatch_windup == 0 and restored.briarwatch_cooldown == 3)
	assert(restored.broken_briarwatch_bindings == {"west": true})
	for binding_id in ["east", "north"]:
		restored.positions["b"] = State.BRIARWATCH_BINDINGS[binding_id]
		assert(restored.interact("b"))
	assert(restored.briarwatch_stage == "rekindle")
	assert(restored.player_mastery["a"]["exploration"] == 1)
	assert(restored.player_mastery["b"]["exploration"] == 2)
	restored.positions["b"] = State.BRIARWATCH_BEACON
	restored.downed_players["b"] = true
	assert(not restored.try_briarwatch_interaction("b"))
	restored.downed_players["b"] = false
	assert(restored.interact("b"))
	assert(restored.briarwatch_stage == "complete")
	assert(restored.reputation == 1 and restored.neighborhood_morale == 1 and restored.chronicle.size() == 1)
	assert(restored.interact("b"))
	assert(restored.positions["b"] == State.HOME_WAYSTONE_ARRIVAL)
	assert(restored.chronicle.size() == 1)
	world.load_dictionary(restored.to_dictionary())
	assert(world.briarwatch_stage == "complete")
	world.load_dictionary({"version": 28, "ruin_waystone_activated": true})
	assert(world.briarwatch_stage == "rumor" and world.broken_briarwatch_bindings.is_empty())
	var main = Scene.instantiate()
	root.add_child(main)
	main.local_input_enabled = false
	main.local_token = "a"
	main.peer_to_token[1] = "a"
	main.world_state = restored
	main.receive_snapshot(main._snapshot_for_clients())
	assert(main.briarwatch.beacon_beam.visible and not main.briarwatch.spirit.visible)
	main.queue_free()
	await process_frame
	print("PASS: Briarwatch evade/brace/damage, rotating pressure, shared bindings, saves, beacon, and presentation")
	quit()
