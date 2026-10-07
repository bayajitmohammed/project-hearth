extends SceneTree

const World = preload("res://scripts/world_state.gd")
const Layout = preload("res://scripts/wilderness_layout.gd")
const Builder = preload("res://scripts/homestead_builder.gd")
const View = preload("res://scripts/wilderness_view.gd")


func _init() -> void:
	_run.call_deferred()


func _run() -> void:
	var world := World.new()
	world.world_seed = 112358
	world.register_player("a")
	world.register_player("b")
	var cell := Vector2i(2, 2)
	var origin := Layout.plot_origin(world.world_seed, cell)
	world.positions["a"] = Layout.claim_post(world.world_seed, cell)
	world.positions["b"] = world.positions["a"]
	world.materials["wood"] = 20
	assert(not world.try_claim_plot("a"))
	world.quest_stage = "home_repaired"
	assert(world.try_claim_plot("a"))
	assert(not world.try_claim_plot("b") and world.materials["wood"] == 18)
	assert(not world.try_change_furnishing("a", Vector2i.ZERO, "foundation", 0, false, [], "2,2"), "Reach is checked at the remote plot, not just its post.")
	world.positions["a"] = origin + Vector3(0, 0.6, 1)
	assert(not world.try_change_furnishing("a", Vector2i.ZERO, "foundation", 0, false, [], "1,2"))
	assert(world.try_change_furnishing("a", Vector2i.ZERO, "foundation", 0, false, [], "2,2"))
	world.positions["b"] = origin + Vector3(0, 0.6, -1.4)
	assert(not world.try_change_furnishing("a", Vector2i.ZERO, "wall", 0, false, ["a", "b"], "2,2"))
	world.positions["b"] = origin + Vector3(0, 0.6, 1)
	assert(world.try_change_furnishing("b", Vector2i.ZERO, "wall", 0, false, ["a", "b"], "2,2"))
	assert(world.try_change_furnishing("a", Vector2i.ZERO, "bench", 1, false, [], "2,2"))
	assert(world.structures.is_empty() and world.furnishings.is_empty())
	assert(world.move_player("a", Vector2.UP, 4).z > origin.z - 1.1)
	var restored := World.new()
	restored.load_dictionary(world.to_dictionary())
	assert(restored.wilderness_plots == world.wilderness_plots)
	assert(restored.try_change_furnishing("b", Vector2i.ZERO, "wall", 0, true, [], "2,2"))
	assert(restored.materials["wood"] == 14)
	assert(restored.move_player("a", Vector2.UP, 1).z < origin.z - 2)
	var old := world.to_dictionary()
	old["version"] = 33
	restored.load_dictionary(old)
	assert(restored.wilderness_plots.is_empty())
	world.positions["a"] = Layout.claim_post(world.world_seed, Vector2i(1, 2))
	assert(world.try_claim_plot("a"))
	assert(world.wilderness_plots["1,2"]["structures"].is_empty())
	world.positions["a"] = Layout.claim_post(world.world_seed, Layout.outpost_cell(world.world_seed))
	assert(not world.try_claim_plot("a"))
	assert(world.chronicle.size() == 2 and world.player_mastery["a"]["building"] == 0)
	for seed_value in [1, 73021, 112358, 2147483647]:
		for x in range(3):
			for z in range(3):
				var section := Vector2i(x, z)
				if section == Layout.outpost_cell(seed_value):
					continue
				var start := Layout.plot_origin(seed_value, section)
				var footprint := Rect2(Vector2(start.x - 1.5, start.z - 1.5), Vector2(15, 9))
				var cache := Layout.cache_position(seed_value, section)
				assert(not footprint.grow(1).has_point(Vector2(cache.x, cache.z)))
				for source: Dictionary in Layout.forage_nodes(seed_value, section):
					assert(not footprint.grow(1).has_point(Vector2(source["position"].x, source["position"].z)))
				for point: Vector3 in Layout.scenery(seed_value, section):
					assert(not footprint.grow(1).has_point(Vector2(point.x, point.z)))
	var builder := Builder.new()
	root.add_child(builder)
	var view := View.new()
	root.add_child(view)
	world.positions["a"] = origin + Vector3(0, 0.6, 2)
	var snapshot := {"world_seed": world.world_seed, "quest_stage": world.quest_stage, "positions": world.positions, "materials": world.materials, "wilderness_plots": world.wilderness_plots}
	builder.toggle_mode()
	builder.update_view(snapshot, "a", 0, true)
	view.update_view(snapshot, "a")
	assert(builder.plot_id == "2,2" and builder.can_remove)
	assert(builder.remote_roots["2,2"].get_child_count() == 3)
	assert("SHARED PLOT" in view.claim_markers["2,2"].get_node("Label").text)
	world.positions["a"] = Vector3(-105, 0.6, -65)
	builder.update_view(snapshot, "a", 0, true)
	view.update_view(snapshot, "a")
	assert(not builder.remote_roots.has("2,2") and not view.claim_markers.has("2,2"))
	world.positions["a"] = origin + Vector3(0, 0.6, 2)
	builder.update_view(snapshot, "a", 0, true)
	view.update_view(snapshot, "a")
	assert(builder.remote_roots["2,2"].get_child_count() == 3)
	print("PASS: wilderness claims, independent persistent layouts, shared collision/refunds, protected content and streamed reconstruction")
	quit()
