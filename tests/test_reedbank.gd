extends SceneTree

const State = preload("res://scripts/world_state.gd")
const Scene = preload("res://main.tscn")


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var world := State.new()
	world.register_player("finder")
	world.register_player("builder")
	world.positions["finder"] = State.OREN_TRAIL_POSITION
	assert(not world.try_reedbank_interaction("finder"))
	world.nima_story_stage = "complete"
	assert(world.interact("finder"))
	assert(world.reedbank_stage == "recover_sail")
	assert(not world.try_reedbank_interaction("finder"))
	world.positions["finder"] = State.REEDBANK_SAIL_POSITION
	world.downed_players["finder"] = true
	assert(not world.try_reedbank_interaction("finder"))
	world.downed_players["finder"] = false
	assert(world.interact("finder"))
	assert(int(world.player_mastery["finder"]["exploration"]) == 1)
	var restored := State.new()
	restored.load_dictionary(world.to_dictionary())
	assert(restored.reedbank_stage == "repair_mill")
	restored.positions["builder"] = State.REEDBANK_REPAIR_POSITION
	assert(not restored.try_reedbank_interaction("builder"))
	restored.materials["wood"] = 2
	assert(restored.interact("builder"))
	assert(restored.materials["wood"] == 0)
	assert(int(restored.player_mastery["builder"]["building"]) == 1)
	assert(not restored.try_reedbank_interaction("builder"))
	restored.positions["finder"] = State.OREN_MILL_POSITION
	assert(restored.interact("finder"))
	assert(restored.reputation == 1 and restored.neighborhood_morale == 1)
	assert(restored.chronicle.size() == 1)
	assert(not restored.try_reedbank_interaction("finder"))
	restored.positions["builder"] = State.REEDBANK_REST_POSITION
	restored.player_health["builder"] = 1
	assert(restored.interact("builder"))
	assert(restored.player_health["builder"] == State.PLAYER_MAX_HEALTH)
	var saved: Dictionary = restored.to_dictionary()
	world.load_dictionary(saved)
	assert(world.reedbank_stage == "complete")
	saved["version"] = 25
	world.load_dictionary(saved)
	assert(world.reedbank_stage == "meet_oren")
	world.positions["finder"] = Vector3(17, 0.6, 0)
	assert(world.move_player("finder", Vector2.RIGHT, 1).x == 17)
	world.positions["finder"] = Vector3(17, 0.6, -23)
	assert(world.move_player("finder", Vector2.RIGHT, 1).x == 21)
	var main = Scene.instantiate()
	root.add_child(main)
	main.local_input_enabled = false
	main.world_state = restored
	main.local_token = "builder"
	main.peer_to_token[1] = "builder"
	main.receive_snapshot(main._snapshot_for_clients())
	assert(main.reedbank.turning and main.reedbank.shelter_light.visible)
	assert(main.objective_label.text.contains("Grow sunwheat"))
	main.queue_free()
	await process_frame
	print("PASS: Reedbank story, co-op credit, costs, persistence, boundary, and presentation")
	quit()
