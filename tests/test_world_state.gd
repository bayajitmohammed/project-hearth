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
	assert(exploration_state.livelihood_stage == "food_need")
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
	assert(restored_exploration.livelihood_stage == "food_need")

	for plot_id: String in WorldStateModel.GARDEN_PLOT_POSITIONS:
		var farmer := "player-a" if plot_id in ["moonroot_1", "moonroot_2"] else "player-b"
		exploration_state.positions[farmer] = WorldStateModel.GARDEN_PLOT_POSITIONS[plot_id]
		assert(exploration_state.try_harvest_garden(farmer))
	assert(exploration_state.materials["moonroot"] == 4)
	assert(exploration_state.player_mastery["player-a"]["farming"] == 2)
	assert(exploration_state.player_mastery["player-b"]["farming"] == 2)
	assert(not exploration_state.try_harvest_garden("player-a"), "A garden plot must not harvest twice.")
	for cook_index: int in WorldStateModel.REQUIRED_STEW_DELIVERIES:
		var cook := "player-a" if cook_index == 0 else "player-b"
		exploration_state.positions[cook] = WorldStateModel.COOKFIRE_POSITION
		assert(exploration_state.try_cook_hearth_stew(cook))
	assert(exploration_state.materials["moonroot"] == 0)
	assert(exploration_state.materials["hearth_stew"] == 2)
	for delivery_index: int in WorldStateModel.REQUIRED_STEW_DELIVERIES:
		var trader := "player-b" if delivery_index == 0 else "player-a"
		exploration_state.positions[trader] = WorldStateModel.MARKET_CRATE_POSITION
		assert(exploration_state.try_deliver_hearth_stew(trader))
	assert(exploration_state.livelihood_stage == "complete")
	assert(exploration_state.produce_stall_open)
	assert(exploration_state.stews_delivered == WorldStateModel.REQUIRED_STEW_DELIVERIES)
	assert(exploration_state.neighborhood_morale == 2)
	assert(exploration_state.reputation == 4)
	assert(exploration_state.chronicle.size() == 4)
	assert(exploration_state.player_mastery["player-a"] == {"farming": 2, "cooking": 1, "trade": 1})
	assert(exploration_state.player_mastery["player-b"] == {"farming": 2, "cooking": 1, "trade": 1})
	var restored_livelihood := WorldStateModel.new()
	restored_livelihood.load_dictionary(exploration_state.to_dictionary())
	assert(restored_livelihood.livelihood_stage == "complete")
	assert(restored_livelihood.produce_stall_open)
	assert(restored_livelihood.harvested_garden_plots.values().all(func(value: bool) -> bool: return value))
	assert(restored_livelihood.player_mastery["player-a"]["farming"] == 2)
	var milestone_reputation := restored_livelihood.reputation
	var milestone_morale := restored_livelihood.neighborhood_morale
	var milestone_chronicle_size := restored_livelihood.chronicle.size()
	restored_livelihood.world_minute = WorldStateModel.WORLD_MINUTES_PER_DAY - 1
	assert(restored_livelihood.simulate_world_clock(1.0))
	assert(restored_livelihood.world_day == 2)
	assert(restored_livelihood.daily_food_order_active)
	assert(restored_livelihood.daily_food_order_day == 2)
	assert(restored_livelihood.daily_food_order_kind == WorldStateModel.DAILY_ORDER_FRESH_MOONROOT)
	assert(restored_livelihood.daily_food_order_required() == WorldStateModel.DAILY_FRESH_MOONROOT_DELIVERIES)
	assert(restored_livelihood.stews_delivered == WorldStateModel.REQUIRED_STEW_DELIVERIES)
	assert(restored_livelihood.harvested_garden_plots.values().all(func(value: bool) -> bool: return not value))
	for plot_id: String in WorldStateModel.GARDEN_PLOT_POSITIONS:
		restored_livelihood.positions["player-a"] = WorldStateModel.GARDEN_PLOT_POSITIONS[plot_id]
		assert(restored_livelihood.try_harvest_garden("player-a"))
	restored_livelihood.positions["player-a"] = WorldStateModel.COOKFIRE_POSITION
	assert(not restored_livelihood.try_cook_hearth_stew("player-a"), "Fresh-produce requests must protect their required crop from accidental cooking.")
	restored_livelihood.pantry_stock = 1
	for delivery_index: int in WorldStateModel.DAILY_FRESH_MOONROOT_DELIVERIES:
		restored_livelihood.positions["player-a"] = WorldStateModel.MARKET_CRATE_POSITION
		assert(restored_livelihood.interact("player-a"), "Fresh moonroot %d should deliver." % delivery_index)
	assert(not restored_livelihood.daily_food_order_active)
	assert(restored_livelihood.pantry_stock == 2)
	assert(restored_livelihood.player_provisions["player-a"] == 0, "Daily delivery must take priority over pantry pickup.")
	assert(restored_livelihood.reputation == milestone_reputation)
	assert(restored_livelihood.neighborhood_morale == milestone_morale)
	assert(restored_livelihood.chronicle.size() == milestone_chronicle_size)
	assert(restored_livelihood.player_mastery["player-a"] == {"farming": 6, "cooking": 1, "trade": 4})
	restored_livelihood.world_minute = WorldStateModel.WORLD_MINUTES_PER_DAY - 1
	assert(restored_livelihood.simulate_world_clock(1.0))
	assert(restored_livelihood.world_day == 3)
	assert(restored_livelihood.daily_food_order_kind == WorldStateModel.DAILY_ORDER_HEARTH_STEW)
	for plot_id: String in ["moonroot_1", "moonroot_2", "moonroot_3"]:
		restored_livelihood.positions["player-a"] = WorldStateModel.GARDEN_PLOT_POSITIONS[plot_id]
		assert(restored_livelihood.try_harvest_garden("player-a"))
	assert(restored_livelihood.harvested_garden_plots.values().all(func(value: bool) -> bool: return value))
	for cook_index: int in WorldStateModel.REQUIRED_STEW_DELIVERIES:
		restored_livelihood.positions["player-a"] = WorldStateModel.COOKFIRE_POSITION
		assert(restored_livelihood.try_cook_hearth_stew("player-a"), "Daily stew %d should cook." % cook_index)
	restored_livelihood.positions["player-a"] = WorldStateModel.MARKET_CRATE_POSITION
	assert(restored_livelihood.interact("player-a"), "Trade II should bulk-deliver both daily stews.")
	assert(not restored_livelihood.daily_food_order_active)
	assert(restored_livelihood.pantry_stock == WorldStateModel.PANTRY_MAX_STOCK)
	assert(restored_livelihood.player_mastery["player-a"] == {"farming": 10, "cooking": 3, "trade": 6})
	var persisted_daily_order := WorldStateModel.new()
	persisted_daily_order.load_dictionary(restored_livelihood.to_dictionary())
	assert(persisted_daily_order.world_day == 3)
	assert(persisted_daily_order.daily_food_order_day == 3)
	assert(persisted_daily_order.daily_food_order_kind == WorldStateModel.DAILY_ORDER_HEARTH_STEW)
	assert(persisted_daily_order.daily_food_deliveries == WorldStateModel.REQUIRED_STEW_DELIVERIES)
	assert(not persisted_daily_order.daily_food_order_active)
	assert(persisted_daily_order.pantry_stock == WorldStateModel.PANTRY_MAX_STOCK)

	var technique_state := WorldStateModel.new()
	technique_state.load_dictionary({
		"version": 11,
		"livelihood_stage": "complete",
		"produce_stall_open": true,
		"world_day": 3,
		"daily_food_order_active": true,
		"daily_food_order_day": 3,
		"daily_food_order_kind": WorldStateModel.DAILY_ORDER_HEARTH_STEW,
		"daily_food_deliveries": 0,
		"player_mastery": {"specialist": {"farming": 8, "cooking": 4, "trade": 4}},
	})
	technique_state.positions["specialist"] = WorldStateModel.GARDEN_PLOT_POSITIONS["moonroot_1"]
	assert(technique_state.try_harvest_garden("specialist"))
	assert(technique_state.harvested_garden_plots["moonroot_1"])
	assert(technique_state.harvested_garden_plots["moonroot_2"])
	technique_state.positions["specialist"] = WorldStateModel.GARDEN_PLOT_POSITIONS["moonroot_3"]
	assert(technique_state.try_harvest_garden("specialist"))
	assert(technique_state.materials["moonroot"] == 4)
	technique_state.positions["specialist"] = WorldStateModel.COOKFIRE_POSITION
	assert(technique_state.try_cook_hearth_stew("specialist"))
	assert(technique_state.materials["hearth_stew"] == 2)
	assert(technique_state.player_mastery["specialist"]["cooking"] == 6)
	technique_state.positions["specialist"] = WorldStateModel.MARKET_CRATE_POSITION
	assert(technique_state.try_deliver_hearth_stew("specialist"))
	assert(not technique_state.daily_food_order_active)
	assert(technique_state.daily_food_deliveries == 2)
	assert(technique_state.player_mastery["specialist"]["trade"] == 6)

	exploration_state.mark_world_empty(1000)
	assert(exploration_state.apply_offline_catch_up(1300) == WorldStateModel.PANTRY_MAX_STOCK)
	assert(exploration_state.pantry_stock == WorldStateModel.PANTRY_MAX_STOCK)
	exploration_state.positions["player-a"] = WorldStateModel.MARKET_CRATE_POSITION
	assert(exploration_state.try_take_pantry_provision("player-a"))
	assert(exploration_state.pantry_stock == WorldStateModel.PANTRY_MAX_STOCK - 1)
	assert(exploration_state.player_provisions["player-a"] == 1)
	assert(not exploration_state.try_use_trail_provision("player-a"), "A full-health player must not waste a provision.")
	exploration_state.player_health["player-a"] = WorldStateModel.PLAYER_MAX_HEALTH - 1
	assert(exploration_state.try_use_trail_provision("player-a"))
	assert(exploration_state.player_health["player-a"] == WorldStateModel.PLAYER_MAX_HEALTH)
	assert(exploration_state.player_provisions["player-a"] == 0)
	assert(exploration_state.try_take_pantry_provision("player-a"))
	assert(exploration_state.player_provisions["player-a"] == 1)
	exploration_state.positions["player-a"] = WorldStateModel.RUINS_POSITION
	exploration_state.downed_players["player-a"] = true
	exploration_state.player_health["player-a"] = 0
	assert(not exploration_state.try_use_trail_provision("player-a"), "A provision must not self-revive a downed player.")
	assert(exploration_state.try_return_to_safety("player-a"))
	assert(exploration_state.player_provisions["player-a"] == 0)
	assert(exploration_state.recovery_packs["player-a"]["count"] == 1)
	assert(exploration_state.recovery_packs["player-a"]["position"] == WorldStateModel.RUINS_POSITION)
	var restored_shared_world := WorldStateModel.new()
	restored_shared_world.load_dictionary(exploration_state.to_dictionary())
	assert(restored_shared_world.pantry_stock == WorldStateModel.PANTRY_MAX_STOCK - 2)
	assert(restored_shared_world.recovery_packs["player-a"]["position"] == WorldStateModel.RUINS_POSITION)
	restored_shared_world.positions["player-b"] = WorldStateModel.RUINS_POSITION
	assert(restored_shared_world.try_recover_pack("player-b"))
	assert(restored_shared_world.player_provisions["player-a"] == 1)
	assert(restored_shared_world.recovery_packs.is_empty())
	restored_shared_world.mark_world_empty(2000)
	assert(restored_shared_world.apply_offline_catch_up(2030) == 0)
	assert(restored_shared_world.apply_offline_catch_up(2120) == 0, "Catch-up runs only once per empty-room sleep.")

	assert(restored_shared_world.festival_stage == "available")
	restored_shared_world.positions["player-a"] = WorldStateModel.FESTIVAL_ARCH_POSITION
	restored_shared_world.positions["player-b"] = WorldStateModel.FESTIVAL_ARCH_POSITION
	assert(restored_shared_world.try_festival_interaction("player-a"))
	assert(restored_shared_world.festival_stage == "signup")
	assert(restored_shared_world.try_festival_interaction("player-b"))
	assert(restored_shared_world.festival_participants.size() == 2)
	assert(restored_shared_world.try_festival_interaction("player-a"))
	assert(restored_shared_world.festival_stage == "racing")
	for checkpoint_id: String in WorldStateModel.FESTIVAL_CHECKPOINT_ORDER:
		restored_shared_world.positions["player-b"] = WorldStateModel.FESTIVAL_CHECKPOINT_POSITIONS[checkpoint_id]
		assert(restored_shared_world.try_festival_interaction("player-b"))
	assert(restored_shared_world.festival_last_winner == "player-b")
	assert(restored_shared_world.festival_completed)
	assert(restored_shared_world.festival_ribbons["player-b"] == 1)
	assert(restored_shared_world.neighborhood_morale == 3)
	assert(restored_shared_world.reputation == 5)
	assert(restored_shared_world.festival_stage == "racing", "Remaining entrants may still finish and earn a ribbon.")
	for checkpoint_id: String in WorldStateModel.FESTIVAL_CHECKPOINT_ORDER:
		restored_shared_world.positions["player-a"] = WorldStateModel.FESTIVAL_CHECKPOINT_POSITIONS[checkpoint_id]
		assert(restored_shared_world.try_festival_interaction("player-a"))
	assert(restored_shared_world.festival_stage == "results")
	assert(restored_shared_world.festival_ribbons["player-a"] == 1)
	assert(restored_shared_world.chronicle.size() == 5)
	var restored_festival := WorldStateModel.new()
	restored_festival.load_dictionary(restored_shared_world.to_dictionary())
	assert(restored_festival.festival_completed)
	assert(restored_festival.festival_last_winner == "player-b")
	assert(restored_festival.festival_ribbons["player-a"] == 1)
	assert(restored_festival.festival_ribbons["player-b"] == 1)
	assert(restored_festival.festival_stage == "available", "Interrupted or completed runs reopen safely after restart.")
	assert(restored_festival.festival_participants.is_empty())
	restored_festival.positions["player-a"] = WorldStateModel.FESTIVAL_ARCH_POSITION
	assert(restored_festival.try_festival_interaction("player-a"))
	assert(restored_festival.festival_stage == "signup")
	assert(restored_festival.try_festival_interaction("player-a"))
	assert(restored_festival.festival_stage == "racing")
	assert(restored_festival.festival_ribbons["player-a"] == 1, "Starting a replay must not alter earned ribbons.")
	assert(restored_festival.remove_festival_participant("player-a"))
	assert(restored_festival.festival_stage == "available", "An empty interrupted run must reopen enrollment.")

	var clock_state := WorldStateModel.new()
	clock_state.load_dictionary({
		"version": 9,
		"quest_stage": "home_repaired",
		"neighborhood_event_stage": "complete",
		"world_day": 2,
		"world_minute": 11 * 60 + 59,
	})
	assert(clock_state.world_time_period() == "Morning")
	assert(clock_state.world_weather() == "clear")
	assert(clock_state.world_weather_label() == "Clear skies")
	assert(clock_state.mara_position == WorldStateModel.MARA_POSITION)
	assert(clock_state.mara_activity == "tending the cottage")
	assert(clock_state.simulate_world_clock(1.0), "Crossing a routine boundary must request a save.")
	assert(clock_state.world_minute == 12 * 60)
	assert(clock_state.world_time_period() == "Afternoon")
	assert(clock_state.mara_position == WorldStateModel.MARA_WELCOME_POSITION)
	clock_state.produce_stall_open = true
	assert(clock_state.simulate_world_clock(1.0), "Opening the market must update Mara's afternoon routine.")
	assert(clock_state.mara_position == WorldStateModel.MARA_MARKET_POSITION)
	assert(clock_state.mara_activity == "helping at the market")
	clock_state.mark_world_empty(100)
	assert(clock_state.apply_offline_catch_up(1100) == 0)
	assert(clock_state.world_minute == 18 * 60 + 1, "Empty-world calendar catch-up must cap at six hours.")
	assert(clock_state.world_time_period() == "Evening")
	var restored_clock := WorldStateModel.new()
	restored_clock.load_dictionary(clock_state.to_dictionary())
	assert(restored_clock.world_day == 2)
	assert(restored_clock.world_minute == clock_state.world_minute)
	assert(restored_clock.mara_activity == "at the gathering place")
	var steady_clock := WorldStateModel.new()
	steady_clock.load_dictionary({
		"version": 9,
		"quest_stage": "home_repaired",
		"neighborhood_event_stage": "complete",
		"world_minute": 13 * 60 + 1,
	})
	assert(not steady_clock.simulate_world_clock(1.0), "Ordinary clock minutes must not save every second.")
	assert(steady_clock.world_minute == 13 * 60 + 2)
	var rainy_day := WorldStateModel.new()
	rainy_day.load_dictionary({"version": 10, "world_day": 4})
	assert(rainy_day.world_weather() == "gentle_rain")
	assert(rainy_day.world_weather_label() == "Gentle rain")

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
	var migrated_slice_three := WorldStateModel.new()
	migrated_slice_three.load_dictionary({
		"version": 5,
		"quest_stage": "home_repaired",
		"neighborhood_event_stage": "complete",
		"exploration_stage": "complete",
		"ruin_waystone_activated": true,
	})
	assert(migrated_slice_three.livelihood_stage == "food_need")
	assert(migrated_slice_three.materials["moonroot"] == 0)
	var migrated_slice_four := WorldStateModel.new()
	migrated_slice_four.load_dictionary({
		"version": 6,
		"livelihood_stage": "complete",
		"produce_stall_open": true,
	})
	assert(migrated_slice_four.pantry_stock == 0)
	assert(migrated_slice_four.player_provisions.is_empty())
	assert(migrated_slice_four.recovery_packs.is_empty())
	var migrated_slice_five := WorldStateModel.new()
	migrated_slice_five.load_dictionary({
		"version": 7,
		"livelihood_stage": "complete",
		"produce_stall_open": true,
	})
	assert(migrated_slice_five.festival_stage == "available")
	assert(not migrated_slice_five.festival_completed)
	assert(migrated_slice_five.festival_ribbons.is_empty())
	assert(migrated_slice_five.world_day == 1)
	assert(migrated_slice_five.world_minute == WorldStateModel.WORLD_START_MINUTE)
	assert(not migrated_slice_five.daily_food_order_active)
	assert(migrated_slice_five.daily_food_order_day == 0)
	var migrated_daily_order := WorldStateModel.new()
	migrated_daily_order.load_dictionary({
		"version": 10,
		"livelihood_stage": "complete",
		"produce_stall_open": true,
		"world_day": 2,
		"daily_food_order_active": true,
		"daily_food_order_day": 2,
		"stews_delivered": 1,
	})
	assert(migrated_daily_order.daily_food_order_kind == WorldStateModel.DAILY_ORDER_HEARTH_STEW)
	assert(migrated_daily_order.daily_food_deliveries == 1)
	assert(migrated_daily_order.stews_delivered == WorldStateModel.REQUIRED_STEW_DELIVERIES)

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
