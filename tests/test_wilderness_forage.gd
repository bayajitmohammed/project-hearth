extends SceneTree

const World = preload("res://scripts/world_state.gd")
const Layout = preload("res://scripts/wilderness_layout.gd")
const View = preload("res://scripts/wilderness_view.gd")


func _init() -> void:
	_run.call_deferred()


func _run() -> void:
	var world := World.new()
	world.world_seed = 112358
	world.register_player("a")
	world.register_player("b")
	var sources := Layout.forage_nodes(world.world_seed, Vector2i(2, 2))
	assert(sources.size() == 3 and sources == Layout.forage_nodes(world.world_seed, Vector2i(2, 2)))
	assert(sources != Layout.forage_nodes(271828, Vector2i(2, 2)))
	assert(not world.try_gather_wilderness("unknown"))
	assert(not world.try_gather_wilderness("a"))
	world.positions["a"] = sources[0]["position"]
	world.positions["b"] = sources[0]["position"]
	assert(world.try_gather_wilderness("a"))
	assert(not world.try_gather_wilderness("b"))
	assert(world.materials["wood"] == 1)
	var restored := World.new()
	restored.load_dictionary(world.to_dictionary())
	assert(not restored.try_gather_wilderness("a"))
	restored.simulate_world_clock(3 * World.WORLD_MINUTES_PER_DAY)
	assert(restored.materials["wood"] == 1)
	assert(restored.try_gather_wilderness("b"))
	assert(not restored.try_gather_wilderness("a"))
	assert(restored.materials["wood"] == 2)
	restored.positions["a"] = sources[2]["position"]
	restored.downed_players["a"] = true
	assert(not restored.try_gather_wilderness("a"))
	restored.downed_players["a"] = false
	assert(restored.try_gather_wilderness("a"))
	assert(restored.materials["herb"] == 1)
	assert(restored.player_mastery == world.player_mastery)
	var legacy := World.new()
	legacy.load_dictionary({"version": 31, "wilderness_forage_days": {"2,2/0": 1}})
	assert(legacy.wilderness_forage_days.is_empty())
	var view := View.new()
	root.add_child(view)
	var snapshot := {"world_seed": 112358, "world_day": restored.world_day, "positions": restored.positions, "wilderness_forage_days": restored.wilderness_forage_days}
	view.update_view(snapshot, "a")
	assert(not view.forage[sources[2]["id"]]["growth"].visible)
	snapshot["positions"]["a"] = Vector3(40, 0.6, -30)
	view.update_view(snapshot, "a")
	assert(view.forage.is_empty())
	snapshot["positions"]["a"] = sources[2]["position"]
	view.update_view(snapshot, "a")
	assert(not view.forage[sources[2]["id"]]["growth"].visible)
	snapshot["world_day"] += 1
	view.update_view(snapshot, "a")
	assert(view.forage[sources[2]["id"]]["growth"].visible)
	var before_catch_up := restored.materials.duplicate()
	restored.world_minute = World.WORLD_MINUTES_PER_DAY - 1
	restored.mark_world_empty(1000)
	restored.apply_offline_catch_up(100000)
	assert(restored.materials == before_catch_up)
	assert(restored.try_gather_wilderness("a"))
	assert(not restored.try_gather_wilderness("a"))
	assert(restored.materials["herb"] == 2)
	for x in range(3):
		for z in range(3):
			for source: Dictionary in Layout.forage_nodes(world.world_seed, Vector2i(x, z)):
				assert(Layout.cell_at(source["position"]) == Vector2i(x, z))
				for tree: Vector3 in Layout.scenery(world.world_seed, Vector2i(x, z)):
					assert(tree.distance_to(source["position"]) > 4)
				assert(source["position"].distance_to(Layout.cache_position(world.world_seed, Vector2i(x, z))) > 3.6)
				for station: String in Layout.OUTPOST_OFFSETS:
					assert(source["position"].distance_to(Layout.outpost_station(world.world_seed, station)) > 3.6)
	print("PASS: deterministic forage, shared depletion, daily renewal, persistence, streaming and protected station space. Sources: ", sources)
	quit()
