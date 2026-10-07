extends SceneTree

const World = preload("res://scripts/world_state.gd")
const View = preload("res://scripts/wilderness_view.gd")


func _init() -> void:
	_run.call_deferred()


func _run() -> void:
	var world := World.new()
	world.quest_stage = "home_repaired"
	world.world_seed = 112358
	world.register_player("a")
	world.register_player("b")
	world.materials["wood"] = 20
	world.wilderness_plots["2,2"] = {"structures": {}, "furnishings": {}}
	var origin := World.Wilderness.plot_origin(world.world_seed, Vector2i(2, 2))
	world.positions["a"] = origin + Vector3(0, 0.6, 0)
	for piece: Array in [["bedroll", 0], ["foundation", 0], ["wall", 0], ["doorway", 2], ["roof", 0]]:
		assert(world.try_change_furnishing("a", Vector2i.ZERO, piece[0], piece[1], false, ["a"], "2,2"))
	assert(world.homestead_guest.is_empty(), "Shelter alone does not invite Sera.")
	world.positions["a"] = origin + Vector3(3, 0.6, 0)
	assert(world.try_change_furnishing("a", Vector2i(1, 0), "cookhearth", 0, false, ["a"], "2,2"))
	assert(world.homestead_guest == {"plot": "2,2", "met": false, "meals": 0})
	assert(world.try_change_furnishing("a", Vector2i(1, 0), "cookhearth", 0, true, [], "2,2"))
	assert(not world.homestead_guest.is_empty(), "Rearranging never evicts the guest.")
	assert(not world.try_homestead_guest("a"))
	var site := World.homestead_guest_position(world.to_dictionary())
	world.positions["a"] = site
	world.positions["b"] = site
	world.downed_players["a"] = true
	assert(not world.try_homestead_guest("a"))
	world.downed_players["a"] = false
	assert(world.try_homestead_guest("a"))
	assert(world.player_relationships["a"]["sera"] == 1)
	assert(not world.try_homestead_guest("b"))
	world.player_provisions["a"] = 1
	world.player_provisions["b"] = 2
	assert(world.try_homestead_guest("a"))
	var restored := World.new()
	restored.load_dictionary(world.to_dictionary())
	world = restored
	assert(world.homestead_guest["meals"] == 1)
	var reputation := world.reputation
	var morale := world.neighborhood_morale
	var history := world.chronicle.size()
	assert(world.try_homestead_guest("b"))
	assert(world.homestead_guest["meals"] == 2 and world.player_provisions["b"] == 1)
	assert(world.reputation == reputation + 1 and world.neighborhood_morale == morale + 1 and world.chronicle.size() == history + 1)
	assert(world.try_homestead_guest("a") and world.try_homestead_guest("b"))
	assert(not world.try_homestead_guest("a") and not world.try_homestead_guest("b"))
	assert(world.player_relationships["a"]["sera"] == 2 and world.player_relationships["b"]["sera"] == 1)
	world._advance_world_minutes(1440)
	assert(world.try_homestead_guest("b"))
	assert(world.player_provisions["b"] == 1 and world.chronicle.size() == history + 1)
	assert(world.player_mastery["a"]["cooking"] == 0 and world.player_mastery["b"]["cooking"] == 0)
	assert(world.try_pin_activity("b", "sera"))
	var view := View.new()
	root.add_child(view)
	var snapshot := world.to_dictionary()
	snapshot["positions"] = world.positions.duplicate()
	view.update_view(snapshot, "a")
	assert(is_instance_valid(view.guest_root) and view.guest_awning.visible)
	snapshot["positions"]["a"] = World.Wilderness.ORIGIN + Vector3(2, 0.6, 2)
	view.update_view(snapshot, "a")
	assert(not is_instance_valid(view.guest_root))
	snapshot["positions"]["a"] = site
	view.update_view(snapshot, "a")
	assert(is_instance_valid(view.guest_root) and view.guest_awning.visible)
	view.free()
	var saved := world.to_dictionary()
	world.load_dictionary(saved)
	assert(world.homestead_guest["meals"] == 2 and not world.try_homestead_guest("b"))
	# Old qualifying layouts gain an invitation, not a completed story or rewards.
	saved["version"] = 36
	saved["wilderness_plots"]["2,2"]["furnishings"]["1,0"] = {"kind": "cookhearth", "rotation": 0}
	world.load_dictionary(saved)
	assert(not world.homestead_guest["met"] and world.homestead_guest["meals"] == 0)
	print("PASS: construction-triggered guest, safe rearrangement, shared conserved welcome, partial migration, one-time outcome, independent rapport and streaming")
	quit()
