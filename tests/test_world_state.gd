extends SceneTree

const WorldStateModel = preload("res://scripts/world_state.gd")


func _init() -> void:
	var state := WorldStateModel.new()
	var first_spawn: Vector3 = state.register_player("player-a")
	assert(first_spawn == WorldStateModel.SPAWN_POINT)

	state.move_player("player-a", Vector2(0.0, -1.0), 1.5)
	assert(state.register_player("player-a").z < first_spawn.z)
	state.move_player("player-a", Vector2(-1.0, 0.0), 100.0)
	assert(state.register_player("player-a").x == WorldStateModel.WORLD_MIN_X)
	assert(not state.interact_with_mara("player-a"))
	state.positions["player-a"] = WorldStateModel.MARA_POSITION
	assert(state.interact_with_mara("player-a"))
	assert(state.quest_stage == "recover_supplies")
	state.positions["player-a"] = WorldStateModel.COLLECTIBLE_POSITION
	assert(state.try_collect("player-a"))
	assert(not state.try_collect("player-a"), "The collectible must only be claimed once.")
	assert(state.quest_stage == "return_to_mara")
	state.positions["player-a"] = WorldStateModel.MARA_POSITION
	assert(state.interact_with_mara("player-a"))
	assert(state.quest_stage == "repair_cottage")

	var restored := WorldStateModel.new()
	restored.load_dictionary(state.to_dictionary())
	assert(restored.collectible_collected)
	assert(restored.quest_stage == "repair_cottage")
	assert(restored.register_player("player-a") == state.positions["player-a"])
	print("PASS: Project Hearth world state")
	quit()
