extends SceneTree

const Layout = preload("res://scripts/wilderness_layout.gd")
const World = preload("res://scripts/world_state.gd")
const View = preload("res://scripts/wilderness_view.gd")
const Catalog = preload("res://scripts/activity_catalog.gd")


func _init() -> void:
	_run.call_deferred()


func _run() -> void:
	var fingerprints := {1: 3850125997, 112358: 3712180068, 271828: 3499698317}
	for seed_value in [1, 112358, 271828]:
		var original: Array = []
		for x in range(3):
			for z in range(3):
				var cell := Vector2i(x, z)
				original.append([Layout.title(cell), Layout.cache_position(seed_value, cell), Layout.scenery(seed_value, cell), Layout.plot_origin(seed_value, cell), Layout.forage_nodes(seed_value, cell)])
		original.append(Layout.outpost_position(seed_value))
		assert(hash(var_to_bytes(original)) == fingerprints[seed_value], "Original terrain must remain stable.")
	assert(Layout.cells().size() == 36)
	var world := World.new()
	world.world_seed = 112358
	world.register_player("a")
	world.register_player("b")
	world.quest_stage = "home_repaired"
	world.materials["wood"] = 100
	var biomes: Dictionary = {}
	for cell: Vector2i in Layout.cells():
		assert(Layout.valid(cell) and Layout.cell_at(Layout.center(cell)) == cell)
		var biome := Layout.biome(world.world_seed, cell)
		biomes[biome] = true
		var wood := 0
		var sources := Layout.forage_nodes(world.world_seed, cell)
		assert(sources.size() == 3)
		for source: Dictionary in sources:
			wood += int(source["kind"] == "wood")
		assert(wood == Layout.BIOMES[biome]["wood"])
		world.positions["a"] = Layout.cache_position(world.world_seed, cell)
		assert(world.update_exploration("a"))
		assert(world.try_wilderness_cache("a"))
	assert(biomes.size() == 4 and world.wilderness_discoveries.size() == 36)
	var journal := Catalog.find_entry(world.to_dictionary(), "wilderness")
	assert("36/36" in journal["hud_description"] and journal["hud_description"].length() < 190)
	assert(Layout.title(Vector2i(-3, -3)) in journal["description"])
	var outer := Vector2i(-3, -3)
	world.positions["a"] = Layout.claim_post(world.world_seed, outer)
	assert(world.try_claim_plot("a"))
	world.positions["a"] = Layout.plot_origin(world.world_seed, outer) + Vector3(0, 0.6, 1)
	assert(world.try_change_furnishing("a", Vector2i.ZERO, "foundation", 0, false, [], "-3,-3"))
	var source: Dictionary = Layout.forage_nodes(world.world_seed, outer)[0]
	world.positions["a"] = source["position"]
	world.positions["b"] = source["position"]
	assert(world.try_gather_wilderness("a"))
	assert(not world.try_gather_wilderness("b"))
	var restored := World.new()
	restored.load_dictionary(world.to_dictionary())
	assert(restored.wilderness_discoveries == world.wilderness_discoveries)
	assert(restored.player_wilderness_caches == world.player_wilderness_caches)
	assert(restored.wilderness_plots == world.wilderness_plots)
	assert(restored.wilderness_forage_days == world.wilderness_forage_days)
	assert(not restored.try_gather_wilderness("a"))
	world.positions["a"] = Vector3(-25, 0.6, -90)
	assert(world.move_player("a", Vector2.RIGHT, 100).x == World.WORLD_MIN_X)
	world.positions["a"] = Vector3(0, 0.6, -70)
	assert(world.move_player("a", Vector2.UP, 100).z == World.WORLD_MIN_Z)
	world.positions["a"] = Vector3(-25, 0.6, -90)
	assert(world.move_player("a", Vector2.UP, 100).z == Layout.MIN_Z)
	assert(world.move_player("a", Vector2.LEFT, 100).x == Layout.MIN_X)
	var view := View.new()
	root.add_child(view)
	var snapshot := {"world_seed": world.world_seed, "positions": world.positions}
	for cell: Vector2i in Layout.cells():
		world.positions["a"] = Layout.center(cell)
		view.update_view(snapshot, "a")
		assert(view.sections.size() <= 9 and view.sections.has(Layout.key(cell)))
		for rendered: Vector2i in Layout.cells():
			assert(view.sections.has(Layout.key(rendered)) == (absi(rendered.x - cell.x) <= 1 and absi(rendered.y - cell.y) <= 1))
	view.free()
	print("PASS: 36 regions, legacy fingerprints, biome resources, negative-key persistence, bounds and bounded streaming")
	quit()
