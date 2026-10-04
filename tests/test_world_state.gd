extends SceneTree

const WorldStateModel = preload("res://scripts/world_state.gd")


func _init() -> void:
	var state := WorldStateModel.new()
	var first_spawn: Vector3 = state.register_player("player-a")
	assert(first_spawn == WorldStateModel.SPAWN_POINT)
	assert(state.player_relationships["player-a"] == {"mara": 0})
	assert(state.player_npc_check_in_day["player-a"] == {"mara": 0})
	assert(state.player_coins["player-a"] == 0)
	assert(state.player_outing_kits["player-a"] == WorldStateModel.OUTING_KIT_VANGUARD)

	state.move_player("player-a", Vector2(0.0, -1.0), 1.5)
	assert(state.register_player("player-a").z < first_spawn.z)
	state.move_player("player-a", Vector2(-1.0, 0.0), 100.0)
	assert(state.register_player("player-a").x == WorldStateModel.WORLD_MIN_X)
	assert(not state.interact_with_mara("player-a"))
	state.positions["player-a"] = WorldStateModel.MARA_POSITION
	assert(state.interact_with_mara("player-a"))
	assert(state.quest_stage == "recover_supplies")
	assert(state.player_relationships["player-a"]["mara"] == 1)
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
	assert(state.player_relationships["player-a"]["mara"] == 2)
	assert(state.craft_repair_kit())
	assert(not state.craft_repair_kit(), "Only one repair kit is needed.")
	assert(state.materials["wood"] == 0)
	assert(state.materials["herb"] == 0)
	for part_id: String in WorldStateModel.REPAIR_POSITIONS:
		state.positions["player-a"] = WorldStateModel.REPAIR_POSITIONS[part_id]
		assert(state.try_repair_cottage("player-a"))
	assert(state.player_mastery["player-a"]["building"] == 3)
	assert(not state.try_repair_cottage("player-a"), "Completed repairs must not duplicate Building mastery.")
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
	assert(state.player_relationships["player-a"]["mara"] == 3)
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
	state.positions["player-a"] = state.mara_position
	assert(state.interact_with_mara("player-a"), "Each player may check in with Mara once per world day.")
	assert(state.player_relationships["player-a"]["mara"] == 4)
	assert(state.player_npc_check_in_day["player-a"]["mara"] == state.world_day)
	assert(not state.interact_with_mara("player-a"), "Repeated same-day check-ins must not farm rapport.")
	state.positions["player-b"] = state.mara_position
	assert(state.interact_with_mara("player-b"), "One player's check-in must not consume a companion's opportunity.")
	assert(state.player_relationships["player-b"]["mara"] == 1)
	assert(state.player_npc_check_in_day["player-b"]["mara"] == state.world_day)

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
	assert(restored.player_relationships["player-a"]["mara"] == 4)
	assert(restored.player_relationships["player-b"]["mara"] == 1)
	assert(restored.player_npc_check_in_day["player-a"]["mara"] == 1)
	var next_day_relationship := WorldStateModel.new()
	next_day_relationship.load_dictionary(state.to_dictionary())
	assert(next_day_relationship.simulate_world_clock(WorldStateModel.WORLD_MINUTES_PER_DAY))
	next_day_relationship.positions["player-a"] = next_day_relationship.mara_position
	assert(next_day_relationship.interact_with_mara("player-a"))
	assert(next_day_relationship.player_relationships["player-a"]["mara"] == 5)
	assert(next_day_relationship.player_npc_check_in_day["player-a"]["mara"] == 2)

	var exploration_state := WorldStateModel.new()
	exploration_state.load_dictionary(state.to_dictionary())
	exploration_state.positions["player-a"] = Vector3(0.0, 0.6, WorldStateModel.NORTHWOOD_REVEAL_Z)
	assert(exploration_state.update_exploration("player-a"))
	assert(exploration_state.shared_map_discoveries["northwood"])
	assert(exploration_state.exploration_stage == "find_ruins")
	assert(exploration_state.player_mastery["player-a"]["exploration"] == 1)
	assert(not exploration_state.update_exploration("player-a"), "An already shared discovery must not duplicate mastery.")
	exploration_state.positions["player-a"] = WorldStateModel.RUINS_POSITION
	assert(exploration_state.update_exploration("player-a"))
	assert(exploration_state.shared_map_discoveries["old_stone_ruins"])
	assert(exploration_state.exploration_stage == "defeat_guardian")
	assert(exploration_state.player_mastery["player-a"]["exploration"] == 2)
	var direct_explorer := WorldStateModel.new()
	direct_explorer.exploration_stage = "follow_rumor"
	direct_explorer.register_player("direct")
	direct_explorer.positions["direct"] = WorldStateModel.RUINS_POSITION
	assert(direct_explorer.update_exploration("direct"))
	assert(direct_explorer.shared_map_discoveries.values().all(func(value: bool) -> bool: return value))
	assert(direct_explorer.player_mastery["direct"]["exploration"] == 2, "Crossing both new reveal conditions earns both discovery credits.")
	exploration_state.positions["player-a"] = WorldStateModel.RUIN_GUARDIAN_SPAWN + Vector3(1.0, 0.0, 0.0)
	for hit: int in WorldStateModel.RUIN_GUARDIAN_MAX_HEALTH:
		exploration_state.player_attack_recovery["player-a"] = 0.0
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
	assert(exploration_state.player_coins["player-a"] == 1)
	assert(exploration_state.player_coins["player-b"] == 1)
	assert(exploration_state.neighborhood_morale == 2)
	assert(exploration_state.reputation == 4)
	assert(exploration_state.chronicle.size() == 4)
	assert(exploration_state.player_mastery["player-a"] == {"farming": 2, "cooking": 1, "trade": 1, "fishing": 0, "building": 3, "combat": 5, "exploration": 2})
	assert(exploration_state.player_mastery["player-b"] == {"farming": 2, "cooking": 1, "trade": 1, "fishing": 0, "building": 0, "combat": 0, "exploration": 0})
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
	assert(restored_livelihood.daily_food_order_reason() == "Clear skies favor fresh harvests")
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
	assert(restored_livelihood.player_mastery["player-a"] == {"farming": 6, "cooking": 1, "trade": 4, "fishing": 0, "building": 3, "combat": 5, "exploration": 2})
	assert(restored_livelihood.player_coins["player-a"] == 4, "Each accepted market unit must pay its contributing player one coin.")
	assert(restored_livelihood.player_coins["player-b"] == 1)
	restored_livelihood.world_minute = WorldStateModel.WORLD_MINUTES_PER_DAY - 1
	assert(restored_livelihood.simulate_world_clock(1.0))
	assert(restored_livelihood.world_day == 3)
	assert(restored_livelihood.daily_food_order_kind == WorldStateModel.DAILY_ORDER_FRESH_MOONROOT)
	assert(restored_livelihood.daily_food_order_reason() == "Clear skies favor fresh harvests")
	restored_livelihood.world_minute = WorldStateModel.WORLD_MINUTES_PER_DAY - 1
	assert(restored_livelihood.simulate_world_clock(1.0))
	assert(restored_livelihood.world_day == 4)
	assert(restored_livelihood.daily_food_order_kind == WorldStateModel.DAILY_ORDER_HEARTH_STEW)
	assert(restored_livelihood.daily_food_order_reason() == "Gentle rain calls for warming stew")
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
	assert(restored_livelihood.player_mastery["player-a"] == {"farming": 10, "cooking": 3, "trade": 6, "fishing": 0, "building": 3, "combat": 5, "exploration": 2})
	assert(restored_livelihood.player_coins["player-a"] == 6, "Trade II bulk delivery must pay once per accepted unit.")
	var persisted_daily_order := WorldStateModel.new()
	persisted_daily_order.load_dictionary(restored_livelihood.to_dictionary())
	assert(persisted_daily_order.world_day == 4)
	assert(persisted_daily_order.daily_food_order_day == 4)
	assert(persisted_daily_order.daily_food_order_kind == WorldStateModel.DAILY_ORDER_HEARTH_STEW)
	assert(persisted_daily_order.daily_food_deliveries == WorldStateModel.REQUIRED_STEW_DELIVERIES)
	assert(not persisted_daily_order.daily_food_order_active)
	assert(persisted_daily_order.pantry_stock == WorldStateModel.PANTRY_MAX_STOCK)
	assert(persisted_daily_order.player_coins["player-a"] == 6)

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
	assert(technique_state.player_mastery["specialist"]["building"] == 0, "Returning players from older saves gain the additive Building track at zero.")
	assert(technique_state.player_mastery["specialist"]["combat"] == 0, "Returning players from older saves gain the additive Combat track at zero.")
	assert(technique_state.player_mastery["specialist"]["exploration"] == 0, "Returning players from older saves gain the additive Exploration track at zero.")
	assert(technique_state.player_mastery["specialist"]["fishing"] == 0, "Returning players from older saves gain the additive Fishing track at zero.")
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
	assert(technique_state.player_coins["specialist"] == 2)

	var fishing_state := WorldStateModel.new()
	fishing_state.quest_stage = "home_repaired"
	fishing_state.register_player("angler")
	fishing_state.register_player("companion")
	assert(not fishing_state.try_fishing_interaction("angler"), "Fishing requires being at Willowmere Pond.")
	fishing_state.positions["angler"] = WorldStateModel.FISHING_SPOT_POSITION
	fishing_state.positions["companion"] = WorldStateModel.FISHING_SPOT_POSITION
	assert(fishing_state.try_fishing_interaction("angler"))
	assert(fishing_state.player_fishing_phase["angler"] == "waiting")
	assert(fishing_state.try_fishing_interaction("companion"))
	var companion_wait_remaining := float(fishing_state.player_fishing_time["companion"])
	fishing_state.simulate_fishing(0.5, ["angler"])
	assert(is_equal_approx(float(fishing_state.player_fishing_time["companion"]), companion_wait_remaining), "An inactive player's cast must not advance offline.")
	assert(fishing_state.try_fishing_interaction("companion"), "Reeling early ends only the companion's cast.")
	assert(fishing_state.player_fishing_phase["companion"] == "idle")
	fishing_state.simulate_fishing(WorldStateModel.FISHING_WAIT_SECONDS, ["angler", "companion"])
	assert(fishing_state.player_fishing_phase["angler"] == "bite")
	assert(fishing_state.player_fishing_phase["companion"] == "idle")
	var mid_cast_restore := WorldStateModel.new()
	mid_cast_restore.load_dictionary(fishing_state.to_dictionary())
	mid_cast_restore.register_player("angler")
	assert(mid_cast_restore.player_fishing_phase["angler"] == "idle", "Transient cast timing must not resume after restart.")
	assert(fishing_state.try_fishing_interaction("angler"))
	assert(fishing_state.player_riverfish["angler"] == 1)
	assert(fishing_state.player_mastery["angler"]["fishing"] == 1)
	assert(fishing_state.try_fishing_interaction("angler"))
	fishing_state.simulate_fishing(WorldStateModel.FISHING_WAIT_SECONDS, ["angler"])
	fishing_state.simulate_fishing(WorldStateModel.FISHING_BITE_SECONDS, ["angler"])
	assert(fishing_state.player_fishing_phase["angler"] == "idle", "A missed bite returns the player to ready.")
	assert(fishing_state.player_riverfish["angler"] == 1, "Missing a bite grants no catch.")
	fishing_state.livelihood_stage = "food_need"
	fishing_state.materials["moonroot"] = 2
	fishing_state.positions["angler"] = WorldStateModel.COOKFIRE_POSITION
	assert(fishing_state.interact("angler"))
	assert(fishing_state.materials["hearth_stew"] == 1, "Required shared stew cooking keeps interaction priority.")
	assert(fishing_state.player_riverfish["angler"] == 1)
	assert(fishing_state.player_provisions["angler"] == 0)
	fishing_state.livelihood_stage = "complete"
	assert(fishing_state.interact("angler"))
	assert(fishing_state.player_riverfish["angler"] == 0)
	assert(fishing_state.player_provisions["angler"] == 1)
	assert(fishing_state.player_mastery["angler"]["cooking"] == 2)
	var restored_fishing := WorldStateModel.new()
	restored_fishing.load_dictionary(fishing_state.to_dictionary())
	restored_fishing.register_player("angler")
	assert(restored_fishing.player_riverfish["angler"] == 0)
	assert(restored_fishing.player_mastery["angler"]["fishing"] == 1)

	var coin_state := WorldStateModel.new()
	coin_state.livelihood_stage = "complete"
	coin_state.produce_stall_open = true
	coin_state.register_player("buyer")
	coin_state.player_coins["buyer"] = WorldStateModel.TRAIL_PROVISION_PRICE
	coin_state.supply_basket_stock = WorldStateModel.SUPPLY_BASKET_DAILY_STOCK
	assert(not coin_state.try_buy_trail_provision("buyer"), "A purchase must be made at the supply basket.")
	assert(coin_state.player_coins["buyer"] == WorldStateModel.TRAIL_PROVISION_PRICE)
	coin_state.positions["buyer"] = WorldStateModel.SUPPLY_BASKET_POSITION
	assert(coin_state.try_buy_trail_provision("buyer"))
	assert(coin_state.player_coins["buyer"] == 0)
	assert(coin_state.player_provisions["buyer"] == 1)
	assert(coin_state.supply_basket_stock == WorldStateModel.SUPPLY_BASKET_DAILY_STOCK - 1)
	assert(not coin_state.try_buy_trail_provision("buyer"), "Insufficient funds must not grant another provision.")
	coin_state.downed_players["buyer"] = true
	coin_state.player_health["buyer"] = 0
	assert(coin_state.try_return_to_safety("buyer"))
	assert(coin_state.player_coins["buyer"] == 0, "Returning to safety must not drop personal coin.")
	var restored_coin_state := WorldStateModel.new()
	restored_coin_state.load_dictionary(coin_state.to_dictionary())
	assert(restored_coin_state.player_coins["buyer"] == 0)
	assert(restored_coin_state.recovery_packs["buyer"]["count"] == 1, "Only provisions, never coin, belong in a recovery pack.")
	assert(restored_coin_state.supply_basket_stock == WorldStateModel.SUPPLY_BASKET_DAILY_STOCK - 1)
	var daily_supply := WorldStateModel.new()
	daily_supply.load_dictionary({"version": 15, "livelihood_stage": "complete", "produce_stall_open": true})
	assert(daily_supply.supply_basket_stock == WorldStateModel.SUPPLY_BASKET_DAILY_STOCK, "Older completed worlds migrate with a full current-day basket.")
	daily_supply.supply_basket_stock = 0
	daily_supply.world_minute = WorldStateModel.WORLD_MINUTES_PER_DAY - 1
	assert(daily_supply.simulate_world_clock(1.0))
	assert(daily_supply.supply_basket_stock == WorldStateModel.SUPPLY_BASKET_DAILY_STOCK, "A new day resets rather than stacks supply.")
	var persisted_supply := WorldStateModel.new()
	persisted_supply.load_dictionary(daily_supply.to_dictionary())
	assert(persisted_supply.supply_basket_stock == WorldStateModel.SUPPLY_BASKET_DAILY_STOCK)

	var handoff_state := WorldStateModel.new()
	for player_token: String in ["giver", "friend-a", "friend-b", "offline-friend"]:
		handoff_state.register_player(player_token)
	handoff_state.positions["giver"] = Vector3(0.0, 0.6, 10.0)
	handoff_state.positions["friend-a"] = Vector3(-1.0, 0.6, 10.0)
	handoff_state.positions["friend-b"] = Vector3(1.0, 0.6, 10.0)
	handoff_state.positions["offline-friend"] = Vector3(0.2, 0.6, 10.0)
	handoff_state.player_provisions["giver"] = 3
	handoff_state.player_health["friend-a"] = 2
	assert(handoff_state.interact("giver", ["giver", "friend-a", "friend-b"]), "An injured friend must receive field aid before a handoff.")
	assert(handoff_state.player_health["friend-a"] == 3)
	assert(handoff_state.player_provisions["giver"] == 2)
	assert(handoff_state.player_provisions["friend-a"] == 0)
	handoff_state.player_health["offline-friend"] = 2
	assert(handoff_state.interact("giver", ["giver", "friend-a", "friend-b"]))
	assert(handoff_state.player_provisions["giver"] == 1)
	assert(handoff_state.player_provisions["friend-a"] == 1, "Equal-distance handoffs choose the lexically first identity.")
	assert(handoff_state.player_provisions["friend-b"] == 0)
	assert(handoff_state.player_provisions["offline-friend"] == 0, "Inactive identities cannot receive a handoff from their saved position.")
	assert(handoff_state.player_health["offline-friend"] == 2, "Inactive identities cannot consume live field aid.")
	assert(not handoff_state.try_give_trail_provision("giver", ["giver"]), "Solo play has no handoff target.")
	assert(handoff_state.player_provisions.values().reduce(func(total: int, count: int) -> int: return total + count, 0) == 2)
	var restored_handoff := WorldStateModel.new()
	restored_handoff.load_dictionary(handoff_state.to_dictionary())
	for player_token: String in ["giver", "friend-a", "friend-b", "offline-friend"]:
		restored_handoff.register_player(player_token)
	assert(restored_handoff.player_provisions["giver"] == 1)
	assert(restored_handoff.player_provisions["friend-a"] == 1)

	var project_state := WorldStateModel.new()
	project_state.livelihood_stage = "complete"
	project_state.produce_stall_open = true
	for contributor: String in ["neighbor-a", "neighbor-b"]:
		project_state.register_player(contributor)
		project_state.player_coins[contributor] = 2
	assert(not project_state.try_contribute_hearthbloom("neighbor-a"), "A contribution must be made at the project site.")
	project_state.positions["neighbor-a"] = WorldStateModel.HEARTHBLOOM_POSITION
	assert(project_state.try_contribute_hearthbloom("neighbor-a"))
	assert(project_state.try_contribute_hearthbloom("neighbor-a"))
	assert(project_state.hearthbloom_contributions == 2)
	assert(project_state.player_coins["neighbor-a"] == 0)
	assert(not project_state.hearthbloom_complete)
	project_state.mark_world_empty(4000)
	project_state.apply_offline_catch_up(4060)
	assert(project_state.hearthbloom_contributions == 2, "An empty world must neither finish nor decay a shared project.")
	var restored_project := WorldStateModel.new()
	restored_project.load_dictionary(project_state.to_dictionary())
	assert(restored_project.hearthbloom_contributions == 2)
	restored_project.positions["neighbor-b"] = WorldStateModel.HEARTHBLOOM_POSITION
	assert(restored_project.try_contribute_hearthbloom("neighbor-b"))
	assert(restored_project.try_contribute_hearthbloom("neighbor-b"))
	assert(restored_project.hearthbloom_complete)
	assert(restored_project.hearthbloom_contributions == WorldStateModel.HEARTHBLOOM_REQUIRED_COINS)
	assert(restored_project.player_coins["neighbor-b"] == 0)
	assert(restored_project.neighborhood_morale == 1)
	assert(restored_project.reputation == 1)
	assert(restored_project.chronicle == ["The neighborhood pooled its earnings to bloom a Hearthbloom planter beside the cottage."])
	assert(not restored_project.try_contribute_hearthbloom("neighbor-b"), "A completed project must never consume more coin.")

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
	var field_aid := WorldStateModel.new()
	field_aid.register_player("helper")
	field_aid.register_player("friend")
	field_aid.player_provisions["helper"] = 1
	field_aid.player_health["friend"] = 1
	field_aid.positions["helper"] = WorldStateModel.SPAWN_POINT
	field_aid.positions["friend"] = WorldStateModel.SPAWN_POINT + Vector3(1.0, 0.0, 0.0)
	assert(field_aid.try_aid_injured_friend("helper"))
	assert(field_aid.player_provisions["helper"] == 0)
	assert(field_aid.player_health["friend"] == 2)
	field_aid.player_provisions["helper"] = 1
	field_aid.downed_players["friend"] = true
	field_aid.player_health["friend"] = 0
	assert(not field_aid.try_aid_injured_friend("helper"), "Field aid must not replace revival.")
	assert(field_aid.player_provisions["helper"] == 1)
	field_aid.downed_players["friend"] = false
	field_aid.player_health["friend"] = 2
	field_aid.positions["friend"] = WorldStateModel.RUINS_POSITION
	assert(not field_aid.try_aid_injured_friend("helper"), "Field aid requires a nearby friend.")
	assert(field_aid.player_provisions["helper"] == 1)

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
	assert(rainy_day.recommended_daily_food_order_kind() == WorldStateModel.DAILY_ORDER_HEARTH_STEW)
	var overcast_stew_day := WorldStateModel.new()
	overcast_stew_day.world_day = 5
	assert(overcast_stew_day.world_weather() == "overcast")
	assert(overcast_stew_day.recommended_daily_food_order_kind() == WorldStateModel.DAILY_ORDER_HEARTH_STEW)
	assert(overcast_stew_day.daily_food_order_reason() == "Overcast market rotation")
	var overcast_fresh_day := WorldStateModel.new()
	overcast_fresh_day.world_day = 8
	assert(overcast_fresh_day.world_weather() == "overcast")
	assert(overcast_fresh_day.recommended_daily_food_order_kind() == WorldStateModel.DAILY_ORDER_FRESH_MOONROOT)

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
	assert(migrated_daily_order.daily_food_order_reason() == "Existing request continues safely")
	assert(migrated_daily_order.stews_delivered == WorldStateModel.REQUIRED_STEW_DELIVERIES)
	migrated_daily_order.register_player("returning-player")
	assert(migrated_daily_order.player_relationships["returning-player"] == {"mara": 0})
	assert(migrated_daily_order.player_npc_check_in_day["returning-player"] == {"mara": 0})
	assert(migrated_daily_order.player_coins["returning-player"] == 0)
	assert(migrated_daily_order.hearthbloom_contributions == 0)
	assert(not migrated_daily_order.hearthbloom_complete)
	assert(migrated_daily_order.player_outing_kits["returning-player"] == WorldStateModel.OUTING_KIT_VANGUARD)

	var building_state := WorldStateModel.new()
	building_state.quest_stage = "repair_cottage"
	building_state.materials["repair_kit"] = 1
	for builder_token: String in ["builder-a", "builder-b"]:
		building_state.register_player(builder_token)
	assert(not building_state.try_repair_cottage("builder-a"))
	assert(building_state.player_mastery["builder-a"]["building"] == 0, "Out-of-range repair input must not grant mastery.")
	building_state.positions["builder-a"] = WorldStateModel.REPAIR_POSITIONS["door"]
	building_state.positions["builder-b"] = WorldStateModel.REPAIR_POSITIONS["wall"]
	assert(building_state.try_repair_cottage("builder-a"))
	assert(building_state.try_repair_cottage("builder-b"))
	assert(building_state.player_mastery["builder-a"]["building"] == 1)
	assert(building_state.player_mastery["builder-b"]["building"] == 1)
	assert(not building_state.try_repair_cottage("builder-a"), "An already repaired part must not grant duplicate mastery.")

	var combat_state := WorldStateModel.new()
	combat_state.register_player("fighter")
	combat_state.positions["fighter"] = WorldStateModel.SPAWN_POINT
	assert(not combat_state.attack_creature("fighter"))
	assert(combat_state.player_mastery["fighter"]["combat"] == 0, "A missed attack must not grant mastery.")
	assert(is_zero_approx(combat_state.player_attack_recovery["fighter"]), "Out-of-range input must not consume recovery.")
	combat_state.positions["fighter"] = WorldStateModel.CREATURE_SPAWN + Vector3(1.0, 0.0, 0.0)
	assert(combat_state.attack_creature("fighter"))
	assert(combat_state.player_mastery["fighter"]["combat"] == 1)
	assert(combat_state.player_attack_recovery["fighter"] == WorldStateModel.PLAYER_ATTACK_RECOVERY_SECONDS)
	assert(not combat_state.attack_creature("fighter"), "Recovery must reject immediate repeated damage.")
	combat_state.positions["fighter"] = WorldStateModel.CREATURE_SPAWN + Vector3(4.0, 0.0, 0.0)
	combat_state.simulate_creature(0.2, ["fighter"])
	assert(combat_state.player_attack_recovery["fighter"] > 0.0)
	combat_state.simulate_creature(0.25, ["fighter"])
	assert(is_zero_approx(combat_state.player_attack_recovery["fighter"]))
	combat_state.positions["fighter"] = combat_state.creature_position + Vector3(1.0, 0.0, 0.0)
	assert(combat_state.attack_creature("fighter"))
	combat_state.player_attack_recovery["fighter"] = 0.0
	assert(combat_state.attack_creature("fighter"))
	assert(combat_state.creature_defeated)
	assert(not combat_state.attack_creature("fighter"))
	assert(combat_state.player_mastery["fighter"]["combat"] == 3, "Only the three damaging hits grant mastery.")
	var power_state := WorldStateModel.new()
	power_state.register_player("striker")
	assert(not power_state.power_strike_creature("striker"), "An out-of-range Power Strike must fail without cost.")
	assert(is_zero_approx(power_state.player_attack_recovery["striker"]))
	power_state.positions["striker"] = WorldStateModel.CREATURE_SPAWN + Vector3(1.0, 0.0, 0.0)
	assert(power_state.power_strike_creature("striker"))
	assert(power_state.creature_health == WorldStateModel.CREATURE_MAX_HEALTH - 2)
	assert(power_state.player_attack_recovery["striker"] == WorldStateModel.PLAYER_POWER_STRIKE_RECOVERY_SECONDS)
	assert(power_state.player_mastery["striker"]["combat"] == 1, "Power Strike grants one mastery credit per action, not per damage.")
	assert(not power_state.attack_creature("striker"), "Basic and power attacks must share personal recovery.")
	power_state.simulate_creature(WorldStateModel.PLAYER_POWER_STRIKE_RECOVERY_SECONDS, ["striker"])
	assert(power_state.attack_creature("striker"))
	assert(power_state.creature_defeated)
	assert(power_state.player_mastery["striker"]["combat"] == 2)
	var loadout_state := WorldStateModel.new()
	loadout_state.quest_stage = "home_repaired"
	for loadout_token: String in ["guardian", "vanguard"]:
		loadout_state.register_player(loadout_token)
	assert(not loadout_state.try_switch_outing_kit("guardian"), "Outing kits may only change at the home rack.")
	loadout_state.positions["guardian"] = WorldStateModel.GEAR_RACK_POSITION
	assert(loadout_state.try_switch_outing_kit("guardian"))
	assert(loadout_state.player_outing_kits["guardian"] == WorldStateModel.OUTING_KIT_GUARDIAN)
	assert(loadout_state.outing_kit_label("guardian") == "Guardian")
	assert(loadout_state.outing_kit_label("vanguard") == "Vanguard")
	var restored_loadout := WorldStateModel.new()
	restored_loadout.load_dictionary(loadout_state.to_dictionary())
	assert(restored_loadout.player_outing_kits["guardian"] == WorldStateModel.OUTING_KIT_GUARDIAN)
	for loadout_token: String in ["guardian", "vanguard"]:
		restored_loadout.positions[loadout_token] = WorldStateModel.CREATURE_SPAWN + Vector3(1.0, 0.0, 0.0)
	assert(restored_loadout.attack_creature("guardian"))
	assert(is_equal_approx(
		restored_loadout.player_attack_recovery["guardian"],
		WorldStateModel.PLAYER_ATTACK_RECOVERY_SECONDS + WorldStateModel.GUARDIAN_ATTACK_RECOVERY_PENALTY_SECONDS
	))
	assert(restored_loadout.attack_creature("vanguard"))
	assert(restored_loadout.player_attack_recovery["vanguard"] == WorldStateModel.PLAYER_ATTACK_RECOVERY_SECONDS)
	restored_loadout.reset_player_combat_timers("guardian")
	assert(restored_loadout.power_strike_creature("guardian"))
	assert(is_equal_approx(
		restored_loadout.player_attack_recovery["guardian"],
		WorldStateModel.PLAYER_POWER_STRIKE_RECOVERY_SECONDS + WorldStateModel.GUARDIAN_ATTACK_RECOVERY_PENALTY_SECONDS
	))
	restored_loadout.reset_player_combat_timers("guardian")
	assert(restored_loadout.try_brace("guardian"))
	assert(restored_loadout.player_brace_time["guardian"] == WorldStateModel.GUARDIAN_BRACE_WINDOW_SECONDS)
	assert(restored_loadout.player_brace_cooldown["guardian"] == WorldStateModel.GUARDIAN_BRACE_COOLDOWN_SECONDS)
	restored_loadout.positions["guardian"] = WorldStateModel.GEAR_RACK_POSITION
	restored_loadout.downed_players["guardian"] = true
	assert(not restored_loadout.try_switch_outing_kit("guardian"), "A downed player cannot change loadout.")
	restored_loadout.downed_players["guardian"] = false
	assert(restored_loadout.try_switch_outing_kit("guardian"))
	assert(restored_loadout.player_outing_kits["guardian"] == WorldStateModel.OUTING_KIT_VANGUARD)
	var daily_combat := WorldStateModel.new()
	daily_combat.creature_defeated = true
	daily_combat.creature_health = 0
	daily_combat.creature_position = WorldStateModel.CREATURE_SPAWN + Vector3(2.0, 0.0, 0.0)
	daily_combat.creature_attack_cooldown = 1.0
	daily_combat.creature_attack_windup = WorldStateModel.ENEMY_ATTACK_WINDUP_SECONDS
	daily_combat.creature_attack_target = "departed-fighter"
	daily_combat.creature_returning = true
	daily_combat.ruin_guardian_defeated = true
	daily_combat.ruin_guardian_health = 0
	daily_combat.world_minute = WorldStateModel.WORLD_MINUTES_PER_DAY - 1
	assert(daily_combat.simulate_world_clock(1.0), "The next world day must be a persistent clock change.")
	assert(daily_combat.world_day == 2)
	assert(not daily_combat.creature_defeated, "The ordinary forest encounter must renew on the next day.")
	assert(daily_combat.creature_health == WorldStateModel.CREATURE_MAX_HEALTH)
	assert(daily_combat.creature_position == WorldStateModel.CREATURE_SPAWN)
	assert(is_zero_approx(daily_combat.creature_attack_cooldown))
	assert(is_zero_approx(daily_combat.creature_attack_windup))
	assert(daily_combat.creature_attack_target.is_empty())
	assert(not daily_combat.creature_returning)
	assert(daily_combat.ruin_guardian_defeated, "The authored ruin guardian must remain permanently defeated.")
	assert(daily_combat.ruin_guardian_health == 0)
	var restored_daily_combat := WorldStateModel.new()
	restored_daily_combat.load_dictionary(daily_combat.to_dictionary())
	assert(not restored_daily_combat.creature_defeated)
	assert(restored_daily_combat.creature_health == WorldStateModel.CREATURE_MAX_HEALTH)
	var catch_up_combat := WorldStateModel.new()
	catch_up_combat.creature_defeated = true
	catch_up_combat.creature_health = 0
	catch_up_combat.world_minute = WorldStateModel.WORLD_MINUTES_PER_DAY - 2
	catch_up_combat.mark_world_empty(1000)
	catch_up_combat.apply_offline_catch_up(1003)
	assert(catch_up_combat.world_day == 2)
	assert(not catch_up_combat.creature_defeated, "Bounded empty-room calendar catch-up must use the same daily renewal.")
	var guardian_power := WorldStateModel.new()
	guardian_power.exploration_stage = "defeat_guardian"
	guardian_power.register_player("striker")
	guardian_power.positions["striker"] = WorldStateModel.RUIN_GUARDIAN_SPAWN + Vector3(1.0, 0.0, 0.0)
	assert(guardian_power.power_strike_creature("striker"))
	assert(guardian_power.ruin_guardian_health == WorldStateModel.RUIN_GUARDIAN_MAX_HEALTH - 2)
	var cooperative_combat := WorldStateModel.new()
	for fighter_token: String in ["fighter-a", "fighter-b"]:
		cooperative_combat.register_player(fighter_token)
		cooperative_combat.positions[fighter_token] = WorldStateModel.CREATURE_SPAWN + Vector3(1.0, 0.0, 0.0)
	assert(cooperative_combat.attack_creature("fighter-a"))
	assert(cooperative_combat.attack_creature("fighter-b"), "One player's recovery must not delay a companion.")
	assert(cooperative_combat.creature_health == WorldStateModel.CREATURE_MAX_HEALTH - 2)
	assert(cooperative_combat.player_mastery["fighter-a"]["combat"] == 1)
	assert(cooperative_combat.player_mastery["fighter-b"]["combat"] == 1)

	var brace_state := WorldStateModel.new()
	brace_state.register_player("defender")
	brace_state.register_player("companion")
	brace_state.positions["defender"] = WorldStateModel.CREATURE_SPAWN
	assert(not brace_state.simulate_creature(0.1, ["defender", "companion"]), "Entering strike range starts a wind-up before damage.")
	assert(brace_state.creature_attack_target == "defender")
	assert(brace_state.creature_attack_windup == WorldStateModel.ENEMY_ATTACK_WINDUP_SECONDS)
	assert(brace_state.try_brace("defender"))
	assert(brace_state.player_brace_time["defender"] == WorldStateModel.PLAYER_BRACE_WINDOW_SECONDS)
	assert(brace_state.player_brace_cooldown["defender"] == WorldStateModel.PLAYER_BRACE_COOLDOWN_SECONDS)
	assert(not brace_state.try_brace("defender"), "An active brace cannot be restarted.")
	assert(brace_state.try_brace("companion"), "One player's brace must not delay a companion.")
	assert(not brace_state.simulate_creature(0.3, ["defender", "companion"]))
	assert(brace_state.simulate_creature(0.3, ["defender", "companion"]))
	assert(brace_state.player_health["defender"] == WorldStateModel.PLAYER_MAX_HEALTH)
	assert(is_zero_approx(brace_state.player_brace_time["defender"]), "A blocked hit must consume the brace.")
	assert(brace_state.player_brace_cooldown["defender"] > 0.0)
	assert(not brace_state.try_brace("defender"), "Brace cooldown must reject repeated defense.")
	brace_state.positions["defender"] = WorldStateModel.SPAWN_POINT
	brace_state.simulate_creature(WorldStateModel.PLAYER_BRACE_COOLDOWN_SECONDS, ["defender"])
	assert(is_zero_approx(brace_state.player_brace_cooldown["defender"]))
	assert(brace_state.try_brace("defender"))
	brace_state.player_attack_recovery["defender"] = WorldStateModel.PLAYER_ATTACK_RECOVERY_SECONDS
	brace_state.reset_player_combat_timers("defender")
	assert(is_zero_approx(brace_state.player_attack_recovery["defender"]))
	assert(is_zero_approx(brace_state.player_brace_time["defender"]))
	assert(is_zero_approx(brace_state.player_brace_cooldown["defender"]))
	var downed_bracer := WorldStateModel.new()
	downed_bracer.register_player("downed")
	downed_bracer.downed_players["downed"] = true
	assert(not downed_bracer.try_brace("downed"), "Downed players cannot brace.")
	assert(not brace_state.to_dictionary().has("player_brace_time"), "Brace timing must remain transient across saves.")
	assert(not brace_state.to_dictionary().has("creature_attack_windup"), "Enemy wind-ups must remain transient across saves.")

	var intercept_state := WorldStateModel.new()
	for token: String in ["traveler", "guardian"]:
		intercept_state.register_player(token)
	intercept_state.positions["traveler"] = WorldStateModel.CREATURE_SPAWN
	intercept_state.positions["guardian"] = WorldStateModel.CREATURE_SPAWN + Vector3(1.0, 0.0, 0.0)
	intercept_state.player_outing_kits["guardian"] = WorldStateModel.OUTING_KIT_GUARDIAN
	assert(not intercept_state.simulate_creature(0.1, ["traveler", "guardian"]))
	assert(intercept_state.creature_attack_target == "traveler")
	assert(intercept_state.try_brace("guardian"))
	assert(intercept_state.simulate_creature(WorldStateModel.ENEMY_ATTACK_WINDUP_SECONDS, ["traveler", "guardian"]))
	assert(intercept_state.player_health["traveler"] == WorldStateModel.PLAYER_MAX_HEALTH)
	assert(is_zero_approx(intercept_state.player_brace_time["guardian"]), "An interception must spend the Guardian's brace.")
	assert(intercept_state.guardian_intercept_player == "guardian")
	assert(intercept_state.guardian_intercept_target == "traveler")
	assert(intercept_state.guardian_intercept_time == WorldStateModel.GUARDIAN_INTERCEPT_FEEDBACK_SECONDS)
	assert(not intercept_state.to_dictionary().has("guardian_intercept_player"), "Interception feedback must remain transient across saves.")
	intercept_state.positions["traveler"] = WorldStateModel.SPAWN_POINT
	intercept_state.positions["guardian"] = WorldStateModel.SPAWN_POINT
	intercept_state.simulate_creature(WorldStateModel.GUARDIAN_INTERCEPT_FEEDBACK_SECONDS, ["traveler", "guardian"])
	assert(intercept_state.guardian_intercept_player.is_empty())
	assert(intercept_state.guardian_intercept_target.is_empty())

	var self_brace_priority := WorldStateModel.new()
	for token: String in ["traveler", "guardian"]:
		self_brace_priority.register_player(token)
	self_brace_priority.positions["traveler"] = WorldStateModel.CREATURE_SPAWN
	self_brace_priority.positions["guardian"] = WorldStateModel.CREATURE_SPAWN + Vector3(1.0, 0.0, 0.0)
	self_brace_priority.player_outing_kits["guardian"] = WorldStateModel.OUTING_KIT_GUARDIAN
	assert(not self_brace_priority.simulate_creature(0.1, ["traveler", "guardian"]))
	assert(self_brace_priority.try_brace("traveler"))
	assert(self_brace_priority.try_brace("guardian"))
	assert(self_brace_priority.simulate_creature(WorldStateModel.ENEMY_ATTACK_WINDUP_SECONDS, ["traveler", "guardian"]))
	assert(is_zero_approx(self_brace_priority.player_brace_time["traveler"]))
	assert(self_brace_priority.player_brace_time["guardian"] > 0.0, "The target's own brace must resolve before Guardian interception.")
	assert(self_brace_priority.guardian_intercept_player.is_empty())

	var deterministic_intercept := WorldStateModel.new()
	for token: String in ["traveler", "guardian-a", "guardian-b"]:
		deterministic_intercept.register_player(token)
	deterministic_intercept.positions["traveler"] = WorldStateModel.CREATURE_SPAWN
	deterministic_intercept.positions["guardian-a"] = WorldStateModel.CREATURE_SPAWN + Vector3(1.0, 0.0, 0.0)
	deterministic_intercept.positions["guardian-b"] = WorldStateModel.CREATURE_SPAWN + Vector3(-1.0, 0.0, 0.0)
	for token: String in ["guardian-a", "guardian-b"]:
		deterministic_intercept.player_outing_kits[token] = WorldStateModel.OUTING_KIT_GUARDIAN
	assert(not deterministic_intercept.simulate_creature(0.1, ["traveler", "guardian-b", "guardian-a"]))
	assert(deterministic_intercept.try_brace("guardian-a"))
	assert(deterministic_intercept.try_brace("guardian-b"))
	assert(deterministic_intercept.simulate_creature(WorldStateModel.ENEMY_ATTACK_WINDUP_SECONDS, ["traveler", "guardian-b", "guardian-a"]))
	assert(deterministic_intercept.guardian_intercept_player == "guardian-a", "Equal-distance interception must use stable player identity order.")
	assert(is_zero_approx(deterministic_intercept.player_brace_time["guardian-a"]))
	assert(deterministic_intercept.player_brace_time["guardian-b"] > 0.0)

	var ineligible_intercept := WorldStateModel.new()
	for token: String in ["traveler", "vanguard", "far-guardian", "downed-guardian"]:
		ineligible_intercept.register_player(token)
	ineligible_intercept.positions["traveler"] = WorldStateModel.CREATURE_SPAWN
	ineligible_intercept.positions["vanguard"] = WorldStateModel.CREATURE_SPAWN + Vector3(1.0, 0.0, 0.0)
	ineligible_intercept.positions["far-guardian"] = WorldStateModel.CREATURE_SPAWN + Vector3(WorldStateModel.GUARDIAN_INTERCEPT_RADIUS + 0.1, 0.0, 0.0)
	ineligible_intercept.positions["downed-guardian"] = WorldStateModel.CREATURE_SPAWN + Vector3(-1.0, 0.0, 0.0)
	ineligible_intercept.player_outing_kits["far-guardian"] = WorldStateModel.OUTING_KIT_GUARDIAN
	ineligible_intercept.player_outing_kits["downed-guardian"] = WorldStateModel.OUTING_KIT_GUARDIAN
	ineligible_intercept.downed_players["downed-guardian"] = true
	ineligible_intercept.player_brace_time["downed-guardian"] = WorldStateModel.GUARDIAN_BRACE_WINDOW_SECONDS
	var ineligible_tokens := ["traveler", "vanguard", "far-guardian", "downed-guardian"]
	assert(not ineligible_intercept.simulate_creature(0.1, ineligible_tokens))
	assert(ineligible_intercept.try_brace("vanguard"))
	assert(ineligible_intercept.try_brace("far-guardian"))
	assert(ineligible_intercept.simulate_creature(WorldStateModel.ENEMY_ATTACK_WINDUP_SECONDS, ineligible_tokens))
	assert(ineligible_intercept.player_health["traveler"] == WorldStateModel.PLAYER_MAX_HEALTH - 1, "Vanguards and distant Guardians must not intercept.")
	assert(ineligible_intercept.guardian_intercept_player.is_empty())
	var evasion_state := WorldStateModel.new()
	evasion_state.register_player("evader")
	evasion_state.positions["evader"] = WorldStateModel.CREATURE_SPAWN
	assert(not evasion_state.simulate_creature(0.1, ["evader"]))
	assert(evasion_state.creature_attack_target == "evader")
	evasion_state.positions["evader"] = WorldStateModel.SPAWN_POINT
	assert(not evasion_state.simulate_creature(WorldStateModel.ENEMY_ATTACK_WINDUP_SECONDS, ["evader"]))
	assert(evasion_state.player_health["evader"] == WorldStateModel.PLAYER_MAX_HEALTH, "Leaving strike range during wind-up must avoid the hit.")
	assert(evasion_state.creature_attack_target.is_empty())
	var leash_state := WorldStateModel.new()
	leash_state.register_player("runner")
	leash_state.creature_position = WorldStateModel.CREATURE_SPAWN + Vector3(-4.0, 0.0, 0.0)
	leash_state.creature_health = 1
	leash_state.creature_attack_windup = WorldStateModel.ENEMY_ATTACK_WINDUP_SECONDS
	leash_state.creature_attack_target = "runner"
	leash_state.positions["runner"] = WorldStateModel.CREATURE_SPAWN + Vector3(-9.0, 0.0, 0.0)
	var first_return_position := leash_state.creature_position
	assert(not leash_state.simulate_creature(0.5, ["runner"]))
	assert(leash_state.creature_returning)
	assert(leash_state.creature_position.distance_to(WorldStateModel.CREATURE_SPAWN) < first_return_position.distance_to(WorldStateModel.CREATURE_SPAWN))
	assert(leash_state.creature_health == 1, "An enemy must not heal until it reaches home.")
	assert(leash_state.creature_attack_target.is_empty(), "Leaving the home boundary must cancel a pending strike.")
	assert(leash_state.simulate_creature(2.0, ["runner"]), "Arriving home must persist the completed encounter reset.")
	assert(leash_state.creature_position == WorldStateModel.CREATURE_SPAWN)
	assert(leash_state.creature_health == WorldStateModel.CREATURE_MAX_HEALTH)
	assert(not leash_state.creature_returning)
	assert(not leash_state.to_dictionary().has("creature_returning"), "Return presentation must remain transient across saves.")
	var held_encounter := WorldStateModel.new()
	for token: String in ["runner", "holder"]:
		held_encounter.register_player(token)
	held_encounter.positions["runner"] = WorldStateModel.CREATURE_SPAWN + Vector3(-9.0, 0.0, 0.0)
	held_encounter.positions["holder"] = WorldStateModel.CREATURE_SPAWN + Vector3(1.0, 0.0, 0.0)
	held_encounter.creature_attack_windup = WorldStateModel.ENEMY_ATTACK_WINDUP_SECONDS
	held_encounter.creature_attack_target = "runner"
	assert(not held_encounter.simulate_creature(0.1, ["runner", "holder"]))
	assert(held_encounter.creature_attack_target == "holder", "A companion inside the boundary must keep the encounter active.")
	assert(not held_encounter.creature_returning)
	var guardian_brace := WorldStateModel.new()
	guardian_brace.exploration_stage = "defeat_guardian"
	guardian_brace.register_player("ruins-defender")
	guardian_brace.positions["ruins-defender"] = WorldStateModel.RUIN_GUARDIAN_SPAWN
	assert(not guardian_brace.simulate_creature(0.1, ["ruins-defender"]))
	assert(guardian_brace.ruin_guardian_attack_target == "ruins-defender")
	assert(guardian_brace.try_brace("ruins-defender"))
	assert(guardian_brace.simulate_creature(WorldStateModel.ENEMY_ATTACK_WINDUP_SECONDS, ["ruins-defender"]))
	assert(guardian_brace.player_health["ruins-defender"] == WorldStateModel.PLAYER_MAX_HEALTH)
	var ruins_intercept := WorldStateModel.new()
	ruins_intercept.exploration_stage = "defeat_guardian"
	for token: String in ["ruins-traveler", "ruins-protector"]:
		ruins_intercept.register_player(token)
	ruins_intercept.positions["ruins-traveler"] = WorldStateModel.RUIN_GUARDIAN_SPAWN
	ruins_intercept.positions["ruins-protector"] = WorldStateModel.RUIN_GUARDIAN_SPAWN + Vector3(1.0, 0.0, 0.0)
	ruins_intercept.player_outing_kits["ruins-protector"] = WorldStateModel.OUTING_KIT_GUARDIAN
	assert(not ruins_intercept.simulate_creature(0.1, ["ruins-traveler", "ruins-protector"]))
	assert(ruins_intercept.ruin_guardian_attack_target == "ruins-traveler")
	assert(ruins_intercept.try_brace("ruins-protector"))
	assert(ruins_intercept.simulate_creature(WorldStateModel.ENEMY_ATTACK_WINDUP_SECONDS, ["ruins-traveler", "ruins-protector"]))
	assert(ruins_intercept.player_health["ruins-traveler"] == WorldStateModel.PLAYER_MAX_HEALTH)
	assert(ruins_intercept.guardian_intercept_player == "ruins-protector")
	var interrupted_guardian := WorldStateModel.new()
	interrupted_guardian.exploration_stage = "defeat_guardian"
	interrupted_guardian.register_player("finisher")
	interrupted_guardian.positions["finisher"] = WorldStateModel.RUIN_GUARDIAN_SPAWN
	assert(not interrupted_guardian.simulate_creature(0.1, ["finisher"]))
	interrupted_guardian.ruin_guardian_health = 1
	assert(interrupted_guardian.attack_creature("finisher"))
	assert(interrupted_guardian.ruin_guardian_defeated)
	assert(interrupted_guardian.ruin_guardian_attack_target.is_empty(), "Defeating an enemy must cancel its pending warning.")
	assert(is_zero_approx(interrupted_guardian.ruin_guardian_attack_windup))
	var guardian_leash := WorldStateModel.new()
	guardian_leash.exploration_stage = "defeat_guardian"
	guardian_leash.register_player("runner")
	guardian_leash.ruin_guardian_position = WorldStateModel.RUIN_GUARDIAN_SPAWN + Vector3(0.0, 0.0, 4.0)
	guardian_leash.ruin_guardian_health = 2
	guardian_leash.positions["runner"] = WorldStateModel.RUIN_GUARDIAN_SPAWN + Vector3(0.0, 0.0, 10.0)
	assert(not guardian_leash.simulate_creature(0.5, ["runner"]))
	assert(guardian_leash.ruin_guardian_returning)
	assert(guardian_leash.ruin_guardian_health == 2)
	assert(guardian_leash.simulate_creature(2.0, ["runner"]))
	assert(guardian_leash.ruin_guardian_position == WorldStateModel.RUIN_GUARDIAN_SPAWN)
	assert(guardian_leash.ruin_guardian_health == WorldStateModel.RUIN_GUARDIAN_MAX_HEALTH)

	var rest_state := WorldStateModel.new()
	rest_state.quest_stage = "home_repaired"
	rest_state.register_player("resting-player")
	rest_state.register_player("companion")
	rest_state.positions["resting-player"] = WorldStateModel.COTTAGE_REST_POSITION
	rest_state.player_health["resting-player"] = 1
	rest_state.player_health["companion"] = 2
	rest_state.player_provisions["resting-player"] = 1
	var minute_before_rest := rest_state.world_minute
	assert(rest_state.try_rest_at_cottage("resting-player"))
	assert(rest_state.player_health["resting-player"] == WorldStateModel.PLAYER_MAX_HEALTH)
	assert(rest_state.player_health["companion"] == 2, "Rest must not alter a companion's health.")
	assert(rest_state.player_provisions["resting-player"] == 1, "Home rest must not consume a field provision.")
	assert(rest_state.world_minute == minute_before_rest, "Personal rest must not advance the shared clock.")
	assert(not rest_state.try_rest_at_cottage("resting-player"), "Full-health players should not trigger rest.")
	rest_state.player_health["resting-player"] = 1
	rest_state.downed_players["resting-player"] = true
	assert(not rest_state.try_rest_at_cottage("resting-player"), "Downed players must use the existing recovery flow.")
	rest_state.downed_players["resting-player"] = false
	rest_state.positions["resting-player"] = WorldStateModel.SPAWN_POINT
	assert(not rest_state.try_rest_at_cottage("resting-player"), "Rest must require reaching the repaired cottage.")

	var revive_state := WorldStateModel.new()
	revive_state.register_player("victim")
	revive_state.register_player("helper")
	revive_state.positions["victim"] = WorldStateModel.CREATURE_SPAWN
	revive_state.positions["helper"] = WorldStateModel.CREATURE_SPAWN + Vector3(1.0, 0.0, 0.0)
	for attack: int in WorldStateModel.PLAYER_MAX_HEALTH:
		revive_state.creature_attack_cooldown = 0.0
		assert(not revive_state.simulate_creature(0.1, ["victim"]), "Creature attack %d should telegraph first." % attack)
		assert(revive_state.simulate_creature(WorldStateModel.ENEMY_ATTACK_WINDUP_SECONDS, ["victim"]), "Creature attack %d should land after its wind-up." % attack)
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
