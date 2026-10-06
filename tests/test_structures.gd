extends SceneTree

const World = preload("res://scripts/world_state.gd")
const Layout = preload("res://scripts/structure_layout.gd")
const Builder = preload("res://scripts/homestead_builder.gd")


func _init() -> void:
	_run.call_deferred()


func _run() -> void:
	var world := World.new()
	world.quest_stage = "home_repaired"
	world.register_player("a")
	world.register_player("b")
	world.positions["a"] = Vector3(-15, 0.6, 17)
	world.positions["b"] = Vector3(-15, 0.6, 14.6)
	world.materials["wood"] = 12
	assert(not world.try_change_furnishing("a", Vector2i.ZERO, "wall", 0, false))
	assert(world.try_change_furnishing("a", Vector2i.ZERO, "foundation", 0, false))
	assert(not world.try_change_furnishing("a", Vector2i.ZERO, "foundation", 0, false))
	assert(not world.try_change_furnishing("a", Vector2i.ZERO, "wall", 0, false, ["a", "b"]))
	world.positions["b"] = world.positions["a"]
	assert(world.try_change_furnishing("a", Vector2i.ZERO, "wall", 0, false, ["a", "b"]))
	assert(not world.try_change_furnishing("a", Vector2i.ZERO, "roof", 0, false))
	assert(world.try_change_furnishing("b", Vector2i.ZERO, "doorway", 2, false))
	assert(world.try_change_furnishing("b", Vector2i.ZERO, "roof", 1, false))
	assert(world.try_change_furnishing("a", Vector2i.ZERO, "bench", 0, false), "A furnishing can coexist with a structure.")
	assert(world.materials["wood"] == 2)
	assert(not world.try_change_furnishing("a", Vector2i.ZERO, "foundation", 0, true))
	assert(not world.try_change_furnishing("a", Vector2i.ZERO, "wall", 0, true))
	assert(world.materials["wood"] == 2)
	var original := world.to_dictionary()
	var restored := World.new()
	restored.load_dictionary(original)
	assert(restored.structures == world.structures and restored.furnishings == world.furnishings)
	var stop := restored.move_player("a", Vector2.UP, 100)
	assert(is_equal_approx(stop.z, 14.98), "Large movement must not tunnel through the north wall.")
	assert(restored.move_player("a", Vector2.DOWN, 1.2).z > 18, "Doorway opening must remain passable.")
	restored.positions["a"] = Vector3(-16.05, 0.6, 19)
	assert(restored.move_player("a", Vector2.UP, 1).z > 17.7, "Doorway posts remain solid.")
	restored.positions["a"] = Vector3(-15, 0.6, 17)
	assert(restored.try_change_furnishing("a", Vector2i.ZERO, "roof", 0, true))
	assert(restored.try_change_furnishing("b", Vector2i.ZERO, "wall", 0, true))
	assert(restored.move_player("a", Vector2.UP, 1).z < 14)
	restored.positions["a"] = Vector3(-15, 0.6, 17)
	assert(restored.try_change_furnishing("a", Vector2i.ZERO, "doorway", 2, true))
	assert(restored.try_change_furnishing("a", Vector2i.ZERO, "foundation", 0, true))
	assert(not restored.try_change_furnishing("a", Vector2i.ZERO, "foundation", 0, true))
	assert(restored.materials["wood"] == 10 and restored.furnishings.size() == 1)
	assert(restored.player_mastery == world.player_mastery)
	var legacy := World.new()
	original["version"] = 32
	legacy.load_dictionary(original)
	assert(legacy.structures.is_empty() and legacy.furnishings == world.furnishings)
	assert(Layout.sanitize({"0,0/roof": {"kind": "roof", "rotation": 0}}).is_empty())
	for turns in range(4):
		var rects := Layout.solid_rects(Vector2i.ZERO, "wall", turns)
		assert(rects.size() == 1)
		var center := rects[0].get_center()
		var normal := Vector3(0, 0, -1).rotated(Vector3.UP, turns * PI / 2)
		var start := Vector3(center.x, 0.6, center.y) + normal * 2
		var finish := start - normal * 5
		var one_wall := {Layout.key(Vector2i.ZERO, "wall", turns): {"kind": "wall", "rotation": turns}}
		assert(Layout.constrain_movement(one_wall, start, finish).distance_to(finish) > 1)
	var builder := Builder.new()
	root.add_child(builder)
	builder.toggle_mode()
	for step in range(5):
		builder.cycle_piece()
	assert(builder.kind == "wall")
	var snapshot := {"quest_stage": "home_repaired", "positions": restored.positions, "materials": {"wood": 4}, "structures": {}}
	builder.update_view(snapshot, "a", 0, true)
	assert(not builder.can_place and "foundation" in builder.details.text)
	snapshot["structures"] = world.structures
	builder.update_view(snapshot, "a", 0, true)
	assert(builder.structure_nodes.size() == 4 and not builder.can_remove)
	print("PASS: supported structures, safe placement/removal, refunds, persistence, preview, solid walls and passable doorways")
	quit()
