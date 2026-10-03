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
	assert(main.market_marker != null)
	assert(main.produce_stall != null)

	var snapshot := _snapshot()
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
	snapshot["player_mastery"]["artisan"] = {"farming": 4, "cooking": 2, "trade": 2}
	main.receive_snapshot(snapshot)
	assert(main.produce_stall.visible)
	assert(main.quest_title_label.text == "OUR SHARED WORLD")
	assert("shared world is ready" in main.objective_label.text)
	assert("Gardener I" in main.mastery_label.text)
	assert("Cook I" in main.mastery_label.text)
	assert("Trader I" in main.mastery_label.text)

	snapshot["daily_food_order_active"] = true
	snapshot["daily_food_order_day"] = 2
	snapshot["daily_food_order_kind"] = WorldStateModel.DAILY_ORDER_FRESH_MOONROOT
	snapshot["daily_food_deliveries"] = 0
	snapshot["daily_food_order_label"] = "Fresh moonroot"
	snapshot["daily_food_order_required"] = WorldStateModel.DAILY_FRESH_MOONROOT_DELIVERIES
	snapshot["world_day"] = 2
	snapshot["harvested_garden_plots"]["moonroot_1"] = false
	snapshot["positions"] = {"artisan": WorldStateModel.GARDEN_PLOT_POSITIONS["moonroot_1"]}
	main.receive_snapshot(snapshot)
	assert(main.garden_markers["moonroot_1"].visible)
	assert("Daily request D2 · Fresh moonroot 0/3" in main.world_change_label.text)
	assert(main.interaction_prompt.visible)
	assert("Harvest moonroot" in main.interaction_prompt.text)
	snapshot["materials"]["moonroot"] = 3
	snapshot["positions"] = {"artisan": WorldStateModel.MARKET_CRATE_POSITION}
	main.receive_snapshot(snapshot)
	assert(main.market_marker.visible)
	assert("Deliver fresh moonroot" in main.interaction_prompt.text)

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
		"player_mastery": {"artisan": {"farming": 0, "cooking": 0, "trade": 0}},
	}
