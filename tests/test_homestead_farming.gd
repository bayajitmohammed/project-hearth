extends SceneTree

const World = preload("res://scripts/world_state.gd")
const Builder = preload("res://scripts/homestead_builder.gd")


func _init() -> void:
	_run.call_deferred()


func _run() -> void:
	for remote in [false, true]:
		var world := World.new()
		world.quest_stage = "home_repaired"
		world.register_player("a")
		world.register_player("b")
		world.materials["wood"] = 10
		var plot_id := "2,2" if remote else ""
		var shift := Vector3.ZERO
		if remote:
			world.wilderness_plots[plot_id] = {"furnishings": {}, "structures": {}}
			shift = World.Wilderness.plot_origin(world.world_seed, Vector2i(2, 2)) - World.FURNISHING_ORIGIN
		for kind: String in World.CROP_BEDS:
			var cell := Vector2i.ZERO
			var id := plot_id + "/0,0"
			world.positions["a"] = World.furnishing_position(cell) + shift + Vector3(0, 0.6, 1)
			world.positions["b"] = world.positions["a"]
			assert(not world.try_change_furnishing("a", cell, kind, 0, false, [], plot_id))
			world.ruin_waystone_activated = true
			if kind == "sunwheat_bed":
				world.reedbank_stage = "complete"
			assert(world.try_change_furnishing("a", cell, kind, 0, false, [], plot_id))
			assert(world.try_use_furnishing("a"))
			assert(not world.try_use_furnishing("b"), "Growing crops cannot duplicate on concurrent interaction.")
			assert(World.homestead_crop_remaining(world.to_dictionary(), id) == 120)
			var restored := World.new()
			restored.load_dictionary(world.to_dictionary())
			assert(restored.homestead_planted_at == world.homestead_planted_at)
			world = restored
			world._advance_world_minutes(119)
			assert(not world.try_use_furnishing("a"))
			world._advance_world_minutes(1)
			var crop: String = World.CROP_BEDS[kind]["crop"]
			var snapshot := world.to_dictionary()
			snapshot["positions"] = world.positions
			var builder := Builder.new()
			root.add_child(builder)
			builder.update_view(snapshot, "a", 0, true)
			assert("Harvest" in builder.station_markers[id].get_node("Label").text)
			assert(builder.station_markers[id].get_node("Crop").get_child_count() == 12)
			if remote:
				snapshot["positions"]["a"] = World.Wilderness.ORIGIN + Vector3(2, 0.6, 2)
				builder.update_view(snapshot, "a", 0, true)
				assert(not builder.station_markers.has(id))
				snapshot["positions"]["a"] = world.positions["b"]
				builder.update_view(snapshot, "a", 0, true)
				assert(builder.station_markers[id].get_node("Crop").get_child_count() == 12)
			assert(world.try_use_furnishing("b"))
			assert(world.materials[crop] == World.CROP_BEDS[kind]["yield"])
			assert(world.player_mastery["b"]["farming"] > 0 and world.player_mastery["a"]["farming"] == 0)
			assert(world.try_use_furnishing("a"), "The next interaction replants, not another harvest.")
			assert(world.materials[crop] == World.CROP_BEDS[kind]["yield"])
			world.downed_players["a"] = true
			assert(not world.try_use_furnishing("a"))
			world.downed_players["a"] = false
			assert(world.try_change_furnishing("a", cell, kind, 0, true, [], plot_id))
			assert(not world.homestead_planted_at.has(id))
			assert(world.try_change_furnishing("a", cell, kind, 1, false, [], plot_id))
			assert(World.homestead_crop_remaining(world.to_dictionary(), id) == -1)
			assert(world.try_use_furnishing("a"))
			world.mark_world_empty(1000)
			world.apply_offline_catch_up(2000)
			assert(World.homestead_crop_remaining(world.to_dictionary(), id) == 0)
			assert(world.materials[crop] == World.CROP_BEDS[kind]["yield"], "Empty time ripens, never harvests.")
			assert(world.try_change_furnishing("a", cell, kind, 0, true, [], plot_id))
			assert(world.materials["wood"] == 10)
			assert(world.try_change_furnishing("a", cell, "bedroll", 0, false, [], plot_id))
			snapshot = world.to_dictionary()
			snapshot["positions"] = world.positions
			builder.update_view(snapshot, "a", 0, true)
			assert(not builder.station_markers[id].has_node("Crop"), "Replacing a bed between snapshots removes old plants.")
			assert(world.try_change_furnishing("a", cell, "bedroll", 0, true, [], plot_id))
			builder.free()
		var invalid := world.to_dictionary()
		invalid["homestead_planted_at"] = {"/99,99": 0, "2,2/0,0": 0}
		world.load_dictionary(invalid)
		assert(world.homestead_planted_at.is_empty())
		world.load_dictionary({"version": 35})
		assert(world.homestead_planted_at.is_empty())
	print("PASS: home/wilderness crop unlocks, timed shared harvest, personal mastery, replant, removal, persistence, safe catch-up and ripe presentation")
	quit()
