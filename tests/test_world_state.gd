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
	for resource_id: String in ["wood_1", "wood_2", "herb_1"]:
		state.positions["player-a"] = WorldStateModel.RESOURCE_POSITIONS[resource_id]
		assert(state.try_gather_resource("player-a"))
	assert(state.materials["wood"] == 2)
	assert(state.materials["herb"] == 1)
	assert(not state.try_gather_resource("player-a"), "A gathered node must not duplicate resources.")
	state.positions["player-a"] = WorldStateModel.COLLECTIBLE_POSITION
	assert(state.try_collect("player-a"))
	assert(not state.try_collect("player-a"), "The collectible must only be claimed once.")
	assert(state.quest_stage == "return_to_mara")
	state.positions["player-a"] = WorldStateModel.MARA_POSITION
	assert(state.interact_with_mara("player-a"))
	assert(state.quest_stage == "repair_cottage")
	assert(state.craft_repair_kit())
	assert(not state.craft_repair_kit(), "Only one repair kit is needed.")
	assert(state.materials["wood"] == 0)
	assert(state.materials["herb"] == 0)
	for part_id: String in WorldStateModel.REPAIR_POSITIONS:
		state.positions["player-a"] = WorldStateModel.REPAIR_POSITIONS[part_id]
		assert(state.try_repair_cottage("player-a"))
	assert(state.quest_stage == "home_repaired")
	assert(state.materials["repair_kit"] == 0)
	assert(state.reputation == 1)
	assert(state.map_rumor_unlocked)

	var restored := WorldStateModel.new()
	restored.load_dictionary(state.to_dictionary())
	assert(restored.collectible_collected)
	assert(restored.quest_stage == "home_repaired")
	assert(restored.gathered_resources.size() == 3)
	assert(restored.repaired_parts.values().all(func(value: bool) -> bool: return value))
	assert(restored.reputation == 1)
	assert(restored.map_rumor_unlocked)
	assert(restored.register_player("player-a") == state.positions["player-a"])

	var combat_state := WorldStateModel.new()
	combat_state.register_player("fighter")
	combat_state.positions["fighter"] = WorldStateModel.CREATURE_SPAWN + Vector3(1.0, 0.0, 0.0)
	for hit: int in WorldStateModel.CREATURE_MAX_HEALTH:
		assert(combat_state.attack_creature("fighter"), "Attack %d should hit." % hit)
	assert(combat_state.creature_defeated)
	assert(not combat_state.attack_creature("fighter"))

	var revive_state := WorldStateModel.new()
	revive_state.register_player("victim")
	revive_state.register_player("helper")
	revive_state.positions["victim"] = WorldStateModel.CREATURE_SPAWN
	revive_state.positions["helper"] = WorldStateModel.CREATURE_SPAWN + Vector3(1.0, 0.0, 0.0)
	for attack: int in WorldStateModel.PLAYER_MAX_HEALTH:
		revive_state.creature_attack_cooldown = 0.0
		assert(revive_state.simulate_creature(0.1, ["victim"]), "Creature attack %d should land." % attack)
	assert(revive_state.downed_players["victim"], "The creature should down a player after three hits.")
	assert(revive_state.try_revive_player("helper"))
	assert(not revive_state.downed_players["victim"])
	assert(revive_state.player_health["victim"] == 2)
	print("PASS: Project Hearth world state")
	quit()
