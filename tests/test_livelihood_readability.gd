extends SceneTree

const MainScene = preload("res://main.tscn")
const WorldStateModel = preload("res://scripts/world_state.gd")


func _init() -> void:
	var main = MainScene.instantiate()
	root.add_child(main)
	await process_frame
	main.local_token = "artisan"

	assert(main.garden_plants.size() == WorldStateModel.GARDEN_PLOT_POSITIONS.size())
	assert(main.cookfire_marker != null)
	assert(main.riverfish_creel != null)
	assert(main.fishing_spot != null)
	assert(main.fishing_marker != null)
	assert(main.fishing_bobber != null)
	assert(main.market_marker != null)
	assert(main.produce_stall != null)
	assert(main.supply_marker != null)
	assert(main.hearthbloom_project != null)
	assert(main.hearthbloom_marker != null)
	assert(main.hearthbloom_blooms != null)
	assert(main.outing_kit_rack != null)
	assert(main.outing_kit_marker != null)

	var snapshot := _snapshot()
	snapshot["positions"] = {"artisan": WorldStateModel.FISHING_SPOT_POSITION}
	main.receive_snapshot(snapshot)
	assert(main.fishing_spot.visible)
	assert(main.fishing_marker.visible)
	assert(not main.fishing_bobber.visible)
	assert("Cast at Willowmere Pond" in main.interaction_prompt.text)
	snapshot["player_fishing_phase"]["artisan"] = "waiting"
	main.receive_snapshot(snapshot)
	assert(main.fishing_bobber.visible)
	assert("WAIT FOR A BITE" in main.fishing_marker.get_node("Label").text)
	assert("Reel early" in main.interaction_prompt.text)
	snapshot["player_fishing_phase"]["artisan"] = "bite"
	main.receive_snapshot(snapshot)
	assert("BITE! REEL NOW" in main.fishing_marker.get_node("Label").text)
	assert("BITE — reel now!" in main.interaction_prompt.text)
	snapshot["player_fishing_phase"]["artisan"] = "idle"
	snapshot["player_riverfish"]["artisan"] = 1
	snapshot["player_mastery"]["artisan"]["fishing"] = 1
	snapshot["positions"] = {"artisan": WorldStateModel.COOKFIRE_POSITION}
	main.receive_snapshot(snapshot)
	assert("Cook riverfish" in main.interaction_prompt.text)
	assert("Riverfish: 1" in main.inventory_label.text)
	assert("Angler I" in main.mastery_label.text)
	snapshot["positions"] = {"artisan": WorldStateModel.RIVERFISH_CREEL_POSITION}
	main.receive_snapshot(snapshot)
	assert(main.riverfish_creel.visible)
	assert("0/8" in main.riverfish_creel.get_node("RiverfishCreelMarker/Label").text)
	assert("Store 1 riverfish" in main.interaction_prompt.text)
	snapshot["player_riverfish"]["artisan"] = 0
	snapshot["shared_riverfish_stock"] = 1
	snapshot["positions"] = {"artisan": WorldStateModel.COOKFIRE_POSITION}
	main.receive_snapshot(snapshot)
	assert("COOK SHARED RIVERFISH" in main.cookfire_marker.get_node("Label").text)
	assert("Cook shared riverfish" in main.interaction_prompt.text)
	assert("Shared creel: 1/8" in main.inventory_label.text)
	assert("Creel 1/8" in main.world_change_label.text)
	snapshot["player_riverfish"]["artisan"] = 1
	snapshot["shared_riverfish_stock"] = 0

	snapshot["positions"] = {"artisan": WorldStateModel.GEAR_RACK_POSITION}
	main.receive_snapshot(snapshot)
	assert(main.outing_kit_rack.visible)
	assert(main.outing_kit_marker.visible)
	assert("Equip Guardian kit" in main.interaction_prompt.text)
	assert("Kit: Vanguard" in main.combat_label.text)
	snapshot["player_outing_kits"]["artisan"] = WorldStateModel.OUTING_KIT_GUARDIAN
	main.receive_snapshot(snapshot)
	assert("Equip Vanguard kit" in main.interaction_prompt.text)
	assert("Kit: Guardian" in main.combat_label.text)

	snapshot["positions"] = {"artisan": WorldStateModel.GARDEN_PLOT_POSITIONS["moonroot_1"]}
	main.receive_snapshot(snapshot)
	assert(main.quest_title_label.text == "CHOOSE A LIFE")
	assert("Harvest moonroot" in main.objective_label.text)
	assert(main.garden_markers["moonroot_1"].visible)
	assert(main.interaction_prompt.visible)
	assert("Harvest moonroot" in main.interaction_prompt.text)

	for plot_id: String in snapshot["harvested_garden_plots"]:
		snapshot["harvested_garden_plots"][plot_id] = true
	snapshot["materials"]["moonroot"] = 4
	snapshot["positions"] = {"artisan": WorldStateModel.COOKFIRE_POSITION}
	main.receive_snapshot(snapshot)
	assert(main.cookfire_marker.visible)
	assert("Cook hearth stew" in main.objective_label.text)
	assert("Cook hearth stew" in main.interaction_prompt.text)

	snapshot["materials"]["moonroot"] = 0
	snapshot["materials"]["hearth_stew"] = 2
	snapshot["positions"] = {"artisan": WorldStateModel.MARKET_CRATE_POSITION}
	main.receive_snapshot(snapshot)
	assert(main.market_marker.visible)
	assert("Deliver hearth stew" in main.objective_label.text)
	assert("Deliver hearth stew" in main.interaction_prompt.text)

	snapshot["materials"]["hearth_stew"] = 0
	snapshot["stews_delivered"] = 2
	snapshot["livelihood_stage"] = "complete"
	snapshot["produce_stall_open"] = true
	snapshot["player_mastery"]["artisan"] = {"farming": 4, "cooking": 2, "trade": 2, "building": 1, "combat": 1, "exploration": 1}
	main.receive_snapshot(snapshot)
	assert(main.produce_stall.visible)
	assert(main.supply_marker.visible)
	assert(main.supply_marker.get_node("TrailSupplyMarker").visible)
	assert(main.hearthbloom_project.visible)
	assert(main.hearthbloom_marker.visible)
	assert(not main.hearthbloom_blooms.visible)
	assert(main.quest_title_label.text == "OUR SHARED WORLD")
	assert("shared world is ready" in main.objective_label.text)
	assert("Gardener I" in main.mastery_label.text)
	assert("Cook I" in main.mastery_label.text)
	assert("Trader I" in main.mastery_label.text)
	assert("Builder I" in main.mastery_label.text)
	assert("Warden I" in main.mastery_label.text)
	assert("Pathfinder I" in main.mastery_label.text)
	assert("Coin 0" in main.progress_label.text)

	snapshot["pantry_stock"] = 0
	snapshot["player_coins"] = {"artisan": WorldStateModel.TRAIL_PROVISION_PRICE}
	snapshot["player_provisions"] = {"artisan": 0}
	snapshot["positions"] = {"artisan": WorldStateModel.SUPPLY_BASKET_POSITION}
	main.receive_snapshot(snapshot)
	assert(main.interaction_prompt.visible)
	assert("Buy trail provision (2 coin)" in main.interaction_prompt.text)
	assert("Coin 2" in main.progress_label.text)
	assert("Supply 3/3" in main.progress_label.text)
	assert("3/3" in main.supply_marker.get_node("TrailSupplyMarker/Label").text)
	snapshot["supply_basket_stock"] = 0
	main.receive_snapshot(snapshot)
	assert("SOLD OUT TODAY" in main.supply_marker.get_node("TrailSupplyMarker/Label").text)
	assert("Supply 0/3" in main.world_change_label.text)
	assert(not main.interaction_prompt.visible)
	snapshot["supply_basket_stock"] = WorldStateModel.SUPPLY_BASKET_DAILY_STOCK

	snapshot["player_coins"] = {"artisan": 1}
	snapshot["hearthbloom_contributions"] = 2
	snapshot["positions"] = {"artisan": WorldStateModel.HEARTHBLOOM_POSITION}
	main.receive_snapshot(snapshot)
	assert("Contribute 1 coin to Hearthbloom (2/4)" in main.interaction_prompt.text)
	assert("Hearthbloom 2/4" in main.world_change_label.text)
	snapshot["hearthbloom_contributions"] = WorldStateModel.HEARTHBLOOM_REQUIRED_COINS
	snapshot["hearthbloom_complete"] = true
	main.receive_snapshot(snapshot)
	assert(not main.hearthbloom_marker.visible)
	assert(main.hearthbloom_blooms.visible)
	assert("Hearthbloom complete" in main.world_change_label.text)

	snapshot["daily_food_order_active"] = true
	snapshot["daily_food_order_day"] = 2
	snapshot["daily_food_order_kind"] = WorldStateModel.DAILY_ORDER_FRESH_MOONROOT
	snapshot["daily_food_deliveries"] = 0
	snapshot["daily_food_order_label"] = "Fresh moonroot"
	snapshot["daily_food_order_required"] = WorldStateModel.DAILY_FRESH_MOONROOT_DELIVERIES
	snapshot["daily_food_order_reason"] = "Clear skies favor fresh harvests"
	snapshot["world_day"] = 2
	snapshot["harvested_garden_plots"]["moonroot_1"] = false
	snapshot["positions"] = {"artisan": WorldStateModel.GARDEN_PLOT_POSITIONS["moonroot_1"]}
	main.receive_snapshot(snapshot)
	assert(main.garden_markers["moonroot_1"].visible)
	assert("Daily request D2 · Fresh moonroot 0/3" in main.world_change_label.text)
	assert("Clear skies favor fresh harvests" in main.world_change_label.text)
	assert(main.interaction_prompt.visible)
	assert("Harvest moonroot" in main.interaction_prompt.text)
	snapshot["materials"]["moonroot"] = 3
	snapshot["positions"] = {"artisan": WorldStateModel.MARKET_CRATE_POSITION}
	main.receive_snapshot(snapshot)
	assert(main.market_marker.visible)
	assert("Deliver fresh moonroot" in main.interaction_prompt.text)

	snapshot["player_mastery"]["artisan"] = {"farming": 8, "cooking": 4, "trade": 4, "building": 1, "combat": 1, "exploration": 1}
	snapshot["materials"]["moonroot"] = 0
	snapshot["positions"] = {"artisan": WorldStateModel.GARDEN_PLOT_POSITIONS["moonroot_1"]}
	main.receive_snapshot(snapshot)
	assert("Carefully tend moonroot pair" in main.interaction_prompt.text)
	assert("Gardener II · Careful Tending" in main.mastery_label.text)
	snapshot["daily_food_order_kind"] = WorldStateModel.DAILY_ORDER_HEARTH_STEW
	snapshot["daily_food_order_label"] = "Hearth stew"
	snapshot["daily_food_order_required"] = WorldStateModel.REQUIRED_STEW_DELIVERIES
	snapshot["materials"]["moonroot"] = 4
	snapshot["positions"] = {"artisan": WorldStateModel.COOKFIRE_POSITION}
	main.receive_snapshot(snapshot)
	assert("Batch cook hearth stew" in main.interaction_prompt.text)
	assert("Cook II · Batch Cooking" in main.mastery_label.text)
	snapshot["materials"]["moonroot"] = 0
	snapshot["materials"]["hearth_stew"] = 2
	snapshot["positions"] = {"artisan": WorldStateModel.MARKET_CRATE_POSITION}
	main.receive_snapshot(snapshot)
	assert("Bulk deliver hearth stew" in main.interaction_prompt.text)
	assert("Trader II · Bulk Delivery" in main.mastery_label.text)

	print("PASS: Choose a Life is readable")
	quit()


func _snapshot() -> Dictionary:
	return {
		"positions": {},
		"collectible_collected": true,
		"quest_stage": "home_repaired",
		"materials": {"wood": 0, "herb": 0, "repair_kit": 0, "moonroot": 0, "hearth_stew": 0},
		"gathered_resources": {},
		"repaired_parts": {"door": true, "wall": true, "garden": true},
		"player_health": {"artisan": WorldStateModel.PLAYER_MAX_HEALTH},
		"downed_players": {"artisan": false},
		"creature_position": WorldStateModel.CREATURE_SPAWN,
		"creature_health": 0,
		"creature_defeated": true,
		"reputation": 3,
		"map_rumor_unlocked": true,
		"mara_position": WorldStateModel.MARA_WELCOME_POSITION,
		"neighborhood_event_stage": "complete",
		"lit_welcome_lanterns": {"cottage": true, "road": true, "forest": true},
		"neighborhood_morale": 1,
		"chronicle": [],
		"shared_map_discoveries": {"northwood": true, "old_stone_ruins": true},
		"exploration_stage": "complete",
		"ruin_guardian_position": WorldStateModel.RUIN_GUARDIAN_SPAWN,
		"ruin_guardian_health": 0,
		"ruin_guardian_defeated": true,
		"ruin_waystone_activated": true,
		"livelihood_stage": "food_need",
		"harvested_garden_plots": {
			"moonroot_1": false,
			"moonroot_2": false,
			"moonroot_3": false,
			"moonroot_4": false,
		},
		"stews_delivered": 0,
		"produce_stall_open": false,
		"daily_food_order_active": false,
		"daily_food_order_day": 0,
		"daily_food_order_kind": "",
		"daily_food_deliveries": 0,
		"player_mastery": {"artisan": {"farming": 0, "cooking": 0, "trade": 0, "fishing": 0, "building": 0, "combat": 0, "exploration": 0}},
		"pantry_stock": 0,
		"player_provisions": {"artisan": 0},
		"player_riverfish": {"artisan": 0},
		"shared_riverfish_stock": 0,
		"player_fishing_phase": {"artisan": "idle"},
		"player_fishing_time": {"artisan": 0.0},
		"player_coins": {"artisan": 0},
		"supply_basket_stock": WorldStateModel.SUPPLY_BASKET_DAILY_STOCK,
		"player_outing_kits": {"artisan": WorldStateModel.OUTING_KIT_VANGUARD},
		"hearthbloom_contributions": 0,
		"hearthbloom_complete": false,
	}
