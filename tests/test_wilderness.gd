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
	var cell := Vector2i(2, 2)
	var cache := Layout.cache_position(world.world_seed, cell)
	assert(Layout.valid(Layout.cell_at(cache)))
	assert(Layout.scenery(112358, cell) == Layout.scenery(112358, cell))
	assert(Layout.scenery(112358, cell) != Layout.scenery(271828, cell))
	world.positions["a"] = cache
	world.positions["b"] = cache
	assert(world.update_exploration("a"))
	assert(not world.update_exploration("b"))
	assert(world.player_mastery["a"]["exploration"] == 1)
	assert(world.try_wilderness_cache("a"))
	assert(not world.try_wilderness_cache("a"))
	assert(world.try_wilderness_cache("b"))
	assert(world.player_provisions["a"] == 1 and world.player_provisions["b"] == 1)
	var restored := World.new()
	restored.load_dictionary(world.to_dictionary())
	assert(restored.wilderness_discoveries == world.wilderness_discoveries)
	assert(restored.player_wilderness_caches == world.player_wilderness_caches)
	assert(not restored.try_wilderness_cache("a"))
	restored.positions["a"] = Layout.cache_position(world.world_seed, Vector2i.ZERO)
	restored.downed_players["a"] = true
	assert(not restored.try_wilderness_cache("a"))
	assert(not restored.update_exploration("a"))
	restored.downed_players["a"] = false
	assert(restored.try_wilderness_cache("a"))
	world.move_player("a", Vector2.LEFT, 100)
	assert(world.positions["a"].x == Layout.MIN_X)
	world.move_player("a", Vector2.DOWN, 100)
	assert(world.positions["a"].z == 22)
	var legacy := World.new()
	legacy.load_dictionary({"version": 29, "wilderness_discoveries": {"2,2": true}, "player_wilderness_caches": {"a": {"2,2": true}}})
	assert(legacy.wilderness_discoveries.is_empty() and legacy.player_wilderness_caches.is_empty())
	var view := View.new()
	root.add_child(view)
	var snapshot := {"world_seed": 112358, "positions": {"a": cache}, "player_wilderness_caches": world.player_wilderness_caches}
	view.update_view(snapshot, "a")
	assert(view.sections.size() == 4)
	assert("CACHE COLLECTED" in view.cache_markers["2,2"].get_node("Label").text)
	var first_trees := Layout.scenery(112358, cell)
	snapshot["positions"]["a"] = Layout.center(Vector2i.ZERO)
	view.update_view(snapshot, "a")
	assert(not view.sections.has("2,2") and view.sections.size() == 9)
	snapshot["positions"]["a"] = cache
	view.update_view(snapshot, "a")
	assert(view.sections.has("2,2") and Layout.scenery(view.rendered_seed, cell) == first_trees)
	snapshot["positions"]["a"] = Vector3(40, 0.6, -30)
	view.update_view(snapshot, "a")
	assert(view.sections.is_empty())
	print("PASS: seeded wilderness, independent caches, discovery, persistence, bounds, and streaming eviction/reload")
	quit()
