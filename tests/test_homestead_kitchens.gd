extends SceneTree

const World = preload("res://scripts/world_state.gd")
const Builder = preload("res://scripts/homestead_builder.gd")


func _init() -> void:
	_run.call_deferred()


func _run() -> void:
	for remote in [false, true]:
		var world := World.new()
		world.quest_stage = "home_repaired"
		world.livelihood_stage = "food_need"
		world.register_player("a")
		world.register_player("b")
		world.materials = {"wood": 6, "moonroot": 4, "sunwheat": 2, "herb": 1}
		world.player_riverfish["a"] = 1
		world.shared_riverfish_stock = 1
		var plot_id := "2,2" if remote else ""
		var shift := Vector3.ZERO
		if remote:
			world.wilderness_plots[plot_id] = {"furnishings": {}, "structures": {}}
			shift = World.Wilderness.plot_origin(world.world_seed, Vector2i(2, 2)) - World.FURNISHING_ORIGIN
		for index in range(3):
			var kind: String = ["cookhearth", "grain_mill", "bread_oven"][index]
			var cell := Vector2i(index, 0)
			world.positions["a"] = World.furnishing_position(cell) + shift + Vector3(0, 0.6, 1)
			if kind != "cookhearth":
				world.reedbank_stage = "meet_oren"
				assert(not world.try_change_furnishing("a", cell, kind, 0, false, [], plot_id))
				world.reedbank_stage = "complete"
			assert(world.try_change_furnishing("a", cell, kind, 0, false, [], plot_id))
			world.positions["b"] = world.positions["a"]
			world.downed_players["a"] = true
			assert(not world.try_use_furnishing("a"))
			world.downed_players["a"] = false
			match kind:
				"cookhearth":
					world.player_mastery["a"]["cooking"] = World.COOKING_TIER_TWO_MASTERY
					assert(world.interact("a"))
					assert(world.materials["hearth_stew"] == 2 and world.materials["moonroot"] == 0)
					assert(world.player_riverfish["a"] == 1 and world.shared_riverfish_stock == 1)
					assert(world.interact("a"))
					assert(world.player_riverfish["a"] == 0 and world.shared_riverfish_stock == 1)
					assert(world.try_use_furnishing("b"))
					assert(world.shared_riverfish_stock == 0 and world.player_provisions["b"] == 1)
					assert(not world.try_use_furnishing("b"))
				"grain_mill":
					assert(world.try_use_furnishing("a"))
					assert(world.materials["sunwheat"] == 0 and world.materials["flour"] == 1)
					assert(not world.try_use_furnishing("b"))
				"bread_oven":
					assert(world.try_use_furnishing("b"))
					assert(world.materials["flour"] == 0 and world.materials["herb"] == 0)
					assert(world.player_provisions["b"] == 3 and world.player_mastery["b"]["cooking"] == 2)
					assert(not world.try_use_furnishing("a"))
		assert(world.materials["wood"] == 0)
		assert(world.try_pin_activity("a", "kitchen"))
		var restored := World.new()
		restored.load_dictionary(world.to_dictionary())
		assert(restored.player_activity_pins["a"] == "kitchen")
		assert(World.furnishing_stations(restored.to_dictionary()) == World.furnishing_stations(world.to_dictionary()))
		var snapshot := world.to_dictionary()
		snapshot["positions"] = world.positions
		var builder := Builder.new()
		root.add_child(builder)
		builder.update_view(snapshot, "b", 0, true)
		assert(builder.station_markers.size() == 3)
		assert("Bake" in builder.station_markers[plot_id + "/2,0"].get_node("Label").text)
		builder.free()
		for index in range(3):
			var cell := Vector2i(index, 0)
			world.positions["a"] = World.furnishing_position(cell) + shift + Vector3(0, 0.6, 1)
			assert(world.try_change_furnishing("a", cell, "bench", 0, true, [], plot_id))
		assert(world.materials["wood"] == 6 and world.materials["hearth_stew"] == 2 and world.player_provisions["b"] == 3)
		world.positions["b"] = World.SPAWN_POINT
		assert(not world.try_use_furnishing("b"))
	print("PASS: home/remote kitchens, unlocks, conserved shared recipes, stew priority/batching, fish fallback, individual credit and persistent presentation")
	quit()
