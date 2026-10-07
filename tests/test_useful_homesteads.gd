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
		world.materials = {"wood": 20, "herb": 1}
		var plot_id := "2,2" if remote else ""
		var shift := Vector3.ZERO
		if remote:
			world.wilderness_plots[plot_id] = {"structures": {}, "furnishings": {}}
			shift = World.Wilderness.plot_origin(world.world_seed, Vector2i(2, 2)) - World.FURNISHING_ORIGIN
		world.positions["a"] = World.furnishing_position(Vector2i.ZERO) + shift + Vector3(0, 0.6, 1)
		world.positions["b"] = world.positions["a"]
		assert(world.try_change_furnishing("a", Vector2i.ZERO, "bedroll", 0, false, [], plot_id))
		world.player_health["a"] = 1
		world.player_health["b"] = 2
		assert(not world.try_use_furnishing("a"), "Unsheltered bedroll cannot heal.")
		for piece: Array in [["foundation", 0], ["wall", 0], ["doorway", 2], ["roof", 0]]:
			assert(world.try_change_furnishing("b", Vector2i.ZERO, piece[0], piece[1], false, ["a", "b"], plot_id))
		var minute := world.world_minute
		assert(world.try_use_furnishing("a"))
		assert(world.player_health["a"] == 3 and world.player_health["b"] == 2 and world.world_minute == minute)
		assert(not world.try_use_furnishing("a"))
		world.downed_players["b"] = true
		assert(not world.try_use_furnishing("b"))
		world.downed_players["b"] = false
		assert(world.try_change_furnishing("a", Vector2i.ZERO, "roof", 0, true, [], plot_id))
		assert(not world.try_use_furnishing("b"))
		world.positions["a"] = World.furnishing_position(Vector2i(1, 0)) + shift + Vector3(0, 0.6, 1)
		assert(world.try_change_furnishing("a", Vector2i(1, 0), "trailwork_bench", 1, false, [], plot_id))
		var wood: int = world.materials["wood"]
		assert(world.try_use_furnishing("a"))
		assert(world.materials["wood"] == wood - 1 and world.materials["herb"] == 0 and world.player_provisions["a"] == 1)
		assert(not world.try_use_furnishing("a") and world.materials["wood"] == wood - 1)
		assert(world.player_mastery["a"]["building"] == 0 and world.player_mastery["a"]["cooking"] == 0)
		var restored := World.new()
		restored.load_dictionary(world.to_dictionary())
		assert(World.furnishing_stations(restored.to_dictionary()) == World.furnishing_stations(world.to_dictionary()))
		var snapshot := world.to_dictionary()
		snapshot["positions"] = world.positions
		var builder := Builder.new()
		root.add_child(builder)
		builder.update_view(snapshot, "a", 0, true)
		assert(builder.station_markers.size() == 2)
		assert("needs" in builder.station_markers[plot_id + "/0,0"].get_node("Label").text)
		builder.free()
	print("PASS: home/wilderness sheltered rest, roof removal, individual health, conserved trailcraft, persistence and station labels")
	quit()
