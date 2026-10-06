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
	assert(not world.try_outpost_interaction("unknown"))
	assert(not world.try_outpost_interaction("a"))
	world.positions["a"] = Layout.outpost_station(world.world_seed, "shelter")
	world.materials["wood"] = 2
	assert(not world.try_outpost_interaction("a"))
	assert(world.materials["wood"] == 2)
	world.materials["wood"] = 4
	assert(world.try_outpost_interaction("a"))
	assert(not world.try_outpost_interaction("a"))
	assert(world.materials["wood"] == 1)
	assert(world.player_mastery["a"]["building"] == 1)
	var restored := World.new()
	restored.load_dictionary(world.to_dictionary())
	assert(restored.outpost_parts == {"shelter": true})
	restored.positions["b"] = Layout.outpost_station(world.world_seed, "meal")
	restored.player_riverfish["b"] = 1
	assert(not restored.try_outpost_interaction("b"))
	assert(restored.player_riverfish["b"] == 1)
	restored.shared_riverfish_stock = 1
	assert(restored.try_outpost_interaction("b"))
	assert(restored.player_riverfish["b"] == 0 and restored.shared_riverfish_stock == 0)
	assert(restored.player_mastery["b"]["cooking"] == 2)
	restored.positions["a"] = Layout.outpost_station(world.world_seed, "remedies")
	restored.materials["herb"] = 3
	restored.downed_players["a"] = true
	assert(not restored.try_outpost_interaction("a"))
	restored.downed_players["a"] = false
	assert(restored.try_outpost_interaction("a"))
	assert(restored.outpost_parts.size() == 3 and restored.reputation == 1 and restored.chronicle.size() == 1)
	assert(restored.materials["herb"] == 1)
	assert(restored.try_outpost_interaction("a"), "Completed remedy station becomes trailcraft.")
	assert(restored.materials["wood"] == 0 and restored.materials["herb"] == 0 and restored.player_provisions["a"] == 1)
	assert(not restored.try_outpost_interaction("a"))
	restored.positions["a"] = Layout.outpost_station(world.world_seed, "rest")
	restored.player_health["a"] = 1
	assert(restored.try_outpost_interaction("a"))
	assert(restored.player_health["a"] == World.PLAYER_MAX_HEALTH)
	assert(not restored.try_outpost_interaction("a"))
	assert(restored.reputation == 1 and restored.chronicle.size() == 1)
	world.load_dictionary(restored.to_dictionary())
	assert(world.outpost_parts.size() == 3)
	var legacy := World.new()
	legacy.load_dictionary({"version": 30, "outpost_parts": {"shelter": true}})
	assert(legacy.outpost_parts.is_empty())
	var view := View.new()
	root.add_child(view)
	var snapshot := {"world_seed": 112358, "positions": world.positions, "outpost_parts": world.outpost_parts}
	view.update_view(snapshot, "a")
	assert(view.outpost_markers["rest"].visible and view.outpost_markers["craft"].visible)
	assert(not view.outpost_markers["meal"].visible)
	snapshot["positions"]["a"] = Vector3(40, 0.6, -30)
	view.update_view(snapshot, "a")
	assert(view.outpost_markers.is_empty())
	snapshot["positions"]["a"] = Layout.outpost_position(112358)
	view.update_view(snapshot, "a")
	assert(view.outpost_pieces["shelter"].visible and view.outpost_markers["rest"].visible)
	print("PASS: split outpost jobs, conserved ingredients, partial saves, recovery/crafting, migration and streamed reconstruction. Site: ", Layout.outpost_position(112358))
	quit()
