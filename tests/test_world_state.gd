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
	assert(state.neighborhood_event_stage == "invitation")
	assert(state.chronicle == ["The newcomers repaired the abandoned cottage and made it their home."])

	state.positions["player-a"] = state.mara_position
	assert(state.interact_with_mara("player-a"))
	assert(state.neighborhood_event_stage == "lighting")
	assert(state.mara_position == WorldStateModel.MARA_WELCOME_POSITION)
	state.register_player("player-b")
	state.positions["player-a"] = WorldStateModel.WELCOME_LANTERN_POSITIONS["cottage"]
	assert(state.try_light_welcome_lantern("player-a"))
	assert(not state.try_light_welcome_lantern("player-a"), "A lit lantern must not accept duplicate credit.")
	for lantern_id: String in ["road", "forest"]:
		state.positions["player-b"] = WorldStateModel.WELCOME_LANTERN_POSITIONS[lantern_id]
		assert(state.try_light_welcome_lantern("player-b"))
	assert(state.neighborhood_event_stage == "complete")
	assert(state.lit_welcome_lanterns.values().all(func(value: bool) -> bool: return value))
	assert(state.neighborhood_morale == 1)
	assert(state.reputation == 2)
	assert(state.exploration_stage == "follow_rumor")
	assert(state.chronicle == [
		"The newcomers repaired the abandoned cottage and made it their home.",
		"Together, the neighborhood lit welcome lanterns to celebrate its new residents.",
	])

	var restored := WorldStateModel.new()
	restored.load_dictionary(state.to_dictionary())
	assert(restored.collectible_collected)
	assert(restored.quest_stage == "home_repaired")
	assert(restored.gathered_resources.size() == 3)
	assert(restored.repaired_parts.values().all(func(value: bool) -> bool: return value))
	assert(restored.reputation == 2)
	assert(restored.map_rumor_unlocked)
	assert(restored.neighborhood_event_stage == "complete")
	assert(restored.mara_position == WorldStateModel.MARA_WELCOME_POSITION)
	assert(restored.lit_welcome_lanterns.values().all(func(value: bool) -> bool: return value))
	assert(restored.neighborhood_morale == 1)
	assert(restored.chronicle.size() == 2)
	assert(restored.register_player("player-a") == state.positions["player-a"])

	var exploration_state := WorldStateModel.new()
	exploration_state.load_dictionary(state.to_dictionary())
	exploration_state.positions["player-a"] = Vector3(0.0, 0.6, WorldStateModel.NORTHWOOD_REVEAL_Z)
	assert(exploration_state.update_exploration("player-a"))
	assert(exploration_state.shared_map_discoveries["northwood"])
	assert(exploration_state.exploration_stage == "find_ruins")
	exploration_state.positions["player-a"] = WorldStateModel.RUINS_POSITION
	assert(exploration_state.update_exploration("player-a"))
	assert(exploration_state.shared_map_discoveries["old_stone_ruins"])
	assert(exploration_state.exploration_stage == "defeat_guardian")
	exploration_state.positions["player-a"] = WorldStateModel.RUIN_GUARDIAN_SPAWN + Vector3(1.0, 0.0, 0.0)
	for hit: int in WorldStateModel.RUIN_GUARDIAN_MAX_HEALTH:
		assert(exploration_state.attack_creature("player-a"), "Guardian attack %d should hit." % hit)
	assert(exploration_state.ruin_guardian_defeated)
	assert(exploration_state.exploration_stage == "restore_waystone")
	exploration_state.positions["player-a"] = WorldStateModel.RUIN_WAYSTONE_POSITION
	assert(exploration_state.try_use_waystone("player-a"))
	assert(exploration_state.ruin_waystone_activated)
	assert(exploration_state.exploration_stage == "complete")
	assert(exploration_state.reputation == 3)
	assert(exploration_state.chronicle.size() == 3)
	assert(exploration_state.try_use_waystone("player-a"))
	assert(exploration_state.positions["player-a"] == WorldStateModel.HOME_WAYSTONE_ARRIVAL)
	exploration_state.positions["player-a"] = WorldStateModel.HOME_WAYSTONE_POSITION
	assert(exploration_state.try_use_waystone("player-a"))
	assert(exploration_state.positions["player-a"] == WorldStateModel.RUIN_WAYSTONE_ARRIVAL)
	var restored_exploration := WorldStateModel.new()
	restored_exploration.load_dictionary(exploration_state.to_dictionary())
	assert(restored_exploration.shared_map_discoveries.values().all(func(value: bool) -> bool: return value))
	assert(restored_exploration.ruin_guardian_defeated)
	assert(restored_exploration.ruin_waystone_activated)
	assert(restored_exploration.exploration_stage == "complete")

	var migrated_slice_one := WorldStateModel.new()
	migrated_slice_one.load_dictionary({"version": 3, "quest_stage": "home_repaired", "reputation": 1})
	assert(migrated_slice_one.neighborhood_event_stage == "invitation")
	assert(migrated_slice_one.chronicle.size() == 1)
	var migrated_slice_two := WorldStateModel.new()
	migrated_slice_two.load_dictionary({
		"version": 4,
		"quest_stage": "home_repaired",
		"neighborhood_event_stage": "complete",
		"lit_welcome_lanterns": {"cottage": true, "road": true, "forest": true},
	})
	assert(migrated_slice_two.exploration_stage == "follow_rumor")

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
	revive_state.downed_players["victim"] = true
	revive_state.player_health["victim"] = 0
	revive_state.positions["victim"] = WorldStateModel.RUINS_POSITION
	assert(revive_state.try_return_to_safety("victim"))
	assert(revive_state.positions["victim"] == WorldStateModel.SPAWN_POINT)
	assert(revive_state.player_health["victim"] == WorldStateModel.PLAYER_MAX_HEALTH)
	print("PASS: Project Hearth world state")
	quit()
