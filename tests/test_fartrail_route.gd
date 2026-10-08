extends SceneTree

const World = preload("res://scripts/world_state.gd")
const View = preload("res://scripts/fartrail_route_view.gd")
const Catalog = preload("res://scripts/activity_catalog.gd")


func _init() -> void:
	_run.call_deferred()


func _run() -> void:
	var world := World.new()
	for station: Vector3 in [World.TRAILWORK_BENCH_POSITION, World.NIMA_MAP_TABLE_POSITION, World.HOMESTEAD_LANTERN_POSITIONS["west_garden"]]:
		assert(World.FARTRAIL_HOME_POST.distance_to(station) > World.INTERACTION_RADIUS)
		assert(World.FARTRAIL_HOME_ARRIVAL.distance_to(station) > World.INTERACTION_RADIUS)
	assert(World.FARTRAIL_HOME_ARRIVAL.z < World.FURNISHING_ORIGIN.z - 1.8)
	world.world_seed = 112358
	world.register_player("a")
	world.register_player("b")
	var post := World.Wilderness.outpost_position(world.world_seed) + Vector3(0, 0, -4)
	world.positions["a"] = post
	world.positions["b"] = post
	world.materials["wood"] = 3
	world.materials["herb"] = 2
	assert(not world.try_fartrail_route("a"))
	world.outpost_parts = {"shelter": true, "remedies": true, "meal": true}
	assert(not world.try_fartrail_route("a"))
	world.ruin_waystone_activated = true
	world.downed_players["a"] = true
	assert(not world.try_fartrail_route("a"))
	world.downed_players["a"] = false
	assert(world.try_fartrail_route("a"))
	assert(world.fartrail_route_parts == {"frame": true} and world.materials["wood"] == 0)
	assert(world.player_mastery["a"]["building"] == 1)
	var partial := World.new()
	partial.load_dictionary(world.to_dictionary())
	assert(partial.fartrail_route_parts == {"frame": true})
	partial.positions["a"] = World.FARTRAIL_HOME_POST
	assert(not partial.try_fartrail_route("a"))
	partial.positions["a"] = post
	partial.simulate_world_clock(1440)
	assert(partial.fartrail_route_parts.size() == 1)
	assert(partial.try_fartrail_route("b"))
	assert(partial.materials["herb"] == 0 and partial.chronicle.size() == 1)
	assert(partial.player_mastery["b"]["building"] == 0)
	partial.player_health["a"] = 1
	partial.player_provisions["a"] = 2
	assert(partial.try_fartrail_route("a"))
	assert(partial.positions["a"] == World.FARTRAIL_HOME_ARRIVAL)
	assert(partial.positions["b"] == post)
	partial.downed_players["b"] = true
	assert(not partial.try_fartrail_route("b"))
	partial.downed_players["b"] = false
	assert(not partial.try_fartrail_route("a"), "Arrival must not immediately bounce back.")
	partial.positions["a"] = World.FARTRAIL_HOME_POST
	assert(partial.try_fartrail_route("a"))
	assert(partial.positions["a"] == post + Vector3(0, 0, -2.5))
	assert(not partial.try_fartrail_route("a"))
	assert(partial.player_health["a"] == 1 and partial.player_provisions["a"] == 2)
	assert(partial.chronicle.size() == 1 and partial.player_mastery["a"]["building"] == 1)
	var restored := World.new()
	restored.load_dictionary(partial.to_dictionary())
	assert(restored.fartrail_route_parts.size() == 2)
	restored.register_player("newcomer")
	restored.positions["newcomer"] = World.FARTRAIL_HOME_POST
	assert(restored.try_fartrail_route("newcomer"))
	var legacy := partial.to_dictionary()
	legacy["version"] = 38
	restored.load_dictionary(legacy)
	assert(restored.fartrail_route_parts.is_empty())
	for seed_value in [1, 112358, 271828, 2147483647]:
		var arrival := World.Wilderness.outpost_position(seed_value) + Vector3(0, 0, -6.5)
		assert(World.Wilderness.cell_at(arrival) == World.Wilderness.outpost_cell(seed_value))
		for point: Vector3 in World.Wilderness.scenery(seed_value, World.Wilderness.outpost_cell(seed_value)):
			assert(point.distance_to(arrival) > 1.4)
	world.fartrail_route_parts.clear()
	assert(world.try_fartrail_route("b"), "An affordable binding can precede an unaffordable frame.")
	assert(world.fartrail_route_parts == {"binding": true})
	var view := View.new()
	root.add_child(view)
	view.update_view({}, "a")
	assert(not view.visible)
	view.update_view(partial.to_dictionary(), "a")
	assert(view.visible and view.lights[0].visible and view.lights[1].visible)
	assert(view.posts[0].position == World.FARTRAIL_HOME_POST)
	assert(view.posts[1].position == post)
	assert("Travel home" in view.markers[1].get_node("Label").text)
	assert(Catalog.find_entry(partial.to_dictionary(), "fartrail_route")["complete"])
	view.free()
	print("PASS: Fartrail gates, conserved shared jobs, partial/legacy saves, independent travel, newcomers and route presentation")
	quit()
