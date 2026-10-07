extends SceneTree

const World = preload("res://scripts/world_state.gd")
const Builder = preload("res://scripts/homestead_builder.gd")


func _init() -> void:
	var world := World.new()
	world.register_player("a")
	world.register_player("b")
	world.positions["a"] = World.furnishing_position(Vector2i.ZERO) + Vector3(0, 0.6, 1)
	world.positions["b"] = world.positions["a"]
	world.materials["wood"] = 4
	assert(not world.try_change_furnishing("a", Vector2i.ZERO, "bench", 0, false))
	world.quest_stage = "home_repaired"
	assert(not world.try_change_furnishing("unknown", Vector2i.ZERO, "bench", 0, false))
	assert(not world.try_change_furnishing("a", Vector2i(-1, 0), "bench", 0, false))
	assert(not world.try_change_furnishing("a", Vector2i(4, 2), "bench", 0, false), "Remote placements must fail.")
	assert(not world.try_change_furnishing("a", Vector2i.ZERO, "castle", 0, false))
	assert(not world.try_change_furnishing("a", Vector2i.ZERO, "bench", 4, false))
	world.downed_players["a"] = true
	assert(not world.try_change_furnishing("a", Vector2i.ZERO, "bench", 0, false))
	world.downed_players["a"] = false
	assert(world.try_change_furnishing("a", Vector2i.ZERO, "bench", 1, false))
	assert(world.materials["wood"] == 2)
	assert(not world.try_change_furnishing("b", Vector2i.ZERO, "flower_box", 2, false), "Two builders cannot occupy one cell.")
	assert(world.materials["wood"] == 2)
	var restored := World.new()
	restored.load_dictionary(world.to_dictionary())
	assert(restored.furnishings == world.furnishings)
	assert(restored.furnishings["0,0"]["rotation"] == 1)
	assert(restored.try_change_furnishing("b", Vector2i.ZERO, "", 0, true), "A companion can rearrange shared furnishings.")
	assert(restored.materials["wood"] == 4)
	assert(not restored.try_change_furnishing("a", Vector2i.ZERO, "", 0, true), "Repeated removal must not duplicate refunds.")
	assert(restored.player_mastery == world.player_mastery)
	restored.materials["wood"] = 1
	assert(not restored.try_change_furnishing("a", Vector2i.ZERO, "bench", 0, false))
	var older := World.new()
	older.load_dictionary({"version": 24, "furnishings": world.furnishings})
	assert(older.furnishings.is_empty())
	var malformed := World.new()
	malformed.load_dictionary({"version": 25, "furnishings": {"0,0": {"kind": "castle", "rotation": 0}, "1,0": {"kind": "bench", "rotation": 9}, "99,99": {"kind": "bench", "rotation": 0}}})
	assert(malformed.furnishings.is_empty())
	var builder := Builder.new()
	root.add_child(builder)
	await process_frame
	var snapshot := {"quest_stage": "home_repaired", "positions": world.positions, "materials": world.materials, "furnishings": world.furnishings}
	builder.toggle_mode()
	builder.update_view(snapshot, "a", 0.0, true)
	assert(builder.can_remove and not builder.can_place)
	assert(builder.pieces.size() == 1)
	assert(is_equal_approx(builder.pieces["0,0"].rotation.y, PI / 2.0))
	snapshot["furnishings"] = {}
	builder.update_view(snapshot, "a", 0.0, true)
	assert(builder.can_place and not builder.can_remove)
	builder.cycle_piece()
	builder.rotate_piece()
	assert(builder.kind == "flower_box" and builder.quarter_turns == 1)
	builder.update_view(snapshot, "a", 0.0, false)
	assert(not builder.active)
	world.furnishings.clear()
	world.materials["wood"] = 4
	for locked_kind: String in ["watch_lantern", "gathering_table"]:
		assert(not world.try_change_furnishing("a", Vector2i.ZERO, locked_kind, 0, false))
	assert(world.materials["wood"] == 4)
	world.briarwatch_stage = "complete"
	world.moonwell_supper_stage = "complete"
	assert(world.try_change_furnishing("b", Vector2i.ZERO, "watch_lantern", 2, false))
	assert(world.try_change_furnishing("a", Vector2i(1, 0), "gathering_table", 3, false))
	assert(world.materials["wood"] == 0)
	restored.load_dictionary(world.to_dictionary())
	assert(restored.furnishings == world.furnishings)
	assert(restored.try_change_furnishing("a", Vector2i.ZERO, "", 0, true))
	assert(restored.try_change_furnishing("b", Vector2i.ZERO, "watch_lantern", 0, false))
	assert(restored.materials["wood"] == 0)
	assert(restored.player_mastery == world.player_mastery)
	builder.toggle_mode()
	builder.cycle_piece()
	assert(builder.kind == "watch_lantern")
	builder.update_view(snapshot, "a", 0, true)
	assert(not builder.can_place and "Briarwatch" in builder.details.text)
	assert(not builder.preview.get_node("WarmLight").visible)
	snapshot["briarwatch_stage"] = "complete"
	snapshot["moonwell_supper_stage"] = "complete"
	snapshot["materials"] = {"wood": 4}
	snapshot["furnishings"] = world.furnishings
	builder.update_view(snapshot, "a", 0, true)
	assert(builder.pieces["0,0"].get_node("WarmLight").visible)
	snapshot["furnishings"] = {}
	builder.update_view(snapshot, "a", 0, true)
	assert(builder.can_place)
	builder.cycle_piece()
	assert(builder.kind == "gathering_table")
	builder.cycle_piece()
	assert(builder.kind == "foundation")
	for step in range(6):
		builder.cycle_piece()
	assert(builder.kind == "bench")
	print("PASS: shared furnishing conservation, authority, persistence, and preview")
	quit()
