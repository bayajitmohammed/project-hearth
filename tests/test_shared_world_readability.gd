extends SceneTree

const MainScene = preload("res://main.tscn")
const WorldStateModel = preload("res://scripts/world_state.gd")


func _init() -> void:
	var main = MainScene.instantiate()
	root.add_child(main)
	await process_frame
	main.local_token = "scout"
	var snapshot := _snapshot()
	main.receive_snapshot(snapshot)
	assert(main.quest_title_label.text == "OUR SHARED WORLD")
	assert("Players 3/8" in main.progress_label.text)
	assert("Pantry 2/3" in main.progress_label.text)
	assert("Your provisions 1" in main.progress_label.text)
	assert("Coin 0" in main.progress_label.text)
	assert(main.interaction_prompt.visible)
	assert("Take a trail provision" in main.interaction_prompt.text)

	var pack_position := Vector3(7.0, 0.6, -7.0)
	snapshot["positions"]["scout"] = pack_position
	snapshot["pantry_stock"] = 0
	snapshot["recovery_packs"] = {
		"friend": {"owner": "friend", "count": 2, "position": pack_position},
	}
	main.receive_snapshot(snapshot)
	assert(main.recovery_pack_nodes.size() == 1)
	assert(main.recovery_pack_nodes.has("friend"))
	assert(main.recovery_pack_nodes["friend"].position == pack_position)
	assert(main.recovery_pack_nodes["friend"].get_node("Label").text == "TRAIL PACK · 2")
	assert("Recover a friend's trail pack" in main.interaction_prompt.text)

	snapshot["positions"]["scout"] = WorldStateModel.SPAWN_POINT
	snapshot["recovery_packs"] = {}
	snapshot["player_health"]["scout"] = WorldStateModel.PLAYER_MAX_HEALTH - 1
	main.receive_snapshot(snapshot)
	assert("Q  ·  Use a trail provision" in main.interaction_prompt.text)
	assert("Q / controller B uses a trail provision" in main.combat_label.text)
	assert(main._local_can_use_trail_provision())

	snapshot["positions"]["scout"] = WorldStateModel.COTTAGE_REST_POSITION
	snapshot["player_provisions"]["scout"] = 0
	main.receive_snapshot(snapshot)
	assert(main.cottage_rest_marker.visible)
	assert(main.cottage_rest_marker.get_node("Label").text == "REST AT HOME")
	assert("Rest and recover" in main.interaction_prompt.text)

	snapshot["positions"] = {
		"scout": WorldStateModel.SPAWN_POINT,
		"friend": WorldStateModel.SPAWN_POINT + Vector3(1.0, 0.0, 0.0),
	}
	snapshot["player_health"] = {"scout": WorldStateModel.PLAYER_MAX_HEALTH, "friend": 2}
	snapshot["downed_players"] = {"scout": false, "friend": false}
	snapshot["player_provisions"]["scout"] = 1
	main.receive_snapshot(snapshot)
	assert("Aid friend" in main.interaction_prompt.text)
	assert("with a trail provision" in main.interaction_prompt.text)
	snapshot["player_health"]["friend"] = WorldStateModel.PLAYER_MAX_HEALTH
	main.receive_snapshot(snapshot)
	assert(main._local_provision_handoff_target() == "friend")
	assert("Give 1 trail provision to friend" in main.interaction_prompt.text)

	var main_source := FileAccess.get_file_as_string("res://scripts/main.gd")
	var state_source := FileAccess.get_file_as_string("res://scripts/world_state.gd")
	assert(main_source.contains("const MAX_PLAYERS := 8"), "Slice 5 rooms must admit eight players.")
	assert(main_source.contains("That player is already active in this room"), "Duplicate active identities need a clear rejection.")
	assert(main_source.contains("Players %d/%d · Pantry %d/%d · Supply %d/%d · Your provisions %d · Coin %d"), "The shared-world HUD must expose room, recovery, bounded supply, and personal coin state.")
	assert(main_source.contains("Recover %s trail pack"), "Recovery packs need a nearby interaction prompt.")
	assert(main_source.contains("Take a trail provision"), "The pantry catch-up result needs a nearby interaction prompt.")
	assert(main_source.contains("request_use_trail_provision"), "Clients need a server-authoritative provision-use request.")
	assert(main_source.contains("\"Aid friend\""), "Touch players need a nearby field-aid target.")
	assert(main_source.contains("\"Give provision\""), "Touch players need a nearby provision-handoff target.")
	assert(main_source.contains("_append_mobile_target(candidates, cottage_rest_marker, \"Rest\""), "Touch players need the contextual home-rest action.")
	assert(state_source.contains("PANTRY_MAX_STOCK := 3"), "Offline catch-up must remain bounded.")
	assert(state_source.contains("func apply_offline_catch_up"), "Empty-world return needs an explicit catch-up rule.")
	assert(state_source.contains("func try_recover_pack"), "Friends need a recovery action.")
	assert(state_source.contains("func try_use_trail_provision"), "Trail provisions need an actual expedition use.")
	assert(state_source.contains("func try_aid_injured_friend"), "Friends need a cooperative field-aid action.")
	assert(state_source.contains("func try_give_trail_provision"), "Nearby friends need a conservative inventory handoff.")
	assert(state_source.contains("func try_rest_at_cottage"), "The repaired home needs a safe recovery action.")
	assert(InputMap.has_action("use_provision"), "Keyboard, controller, and Web builds need one shared provision action.")
	print("PASS: Project Hearth shared-world readability")
	quit()


func _snapshot() -> Dictionary:
	return {
		"positions": {"scout": WorldStateModel.MARKET_CRATE_POSITION},
		"collectible_collected": true,
		"quest_stage": "home_repaired",
		"materials": {"wood": 0, "herb": 0, "repair_kit": 0, "moonroot": 0, "hearth_stew": 0},
		"gathered_resources": {},
		"repaired_parts": {"door": true, "wall": true, "garden": true},
		"player_health": {"scout": WorldStateModel.PLAYER_MAX_HEALTH},
		"downed_players": {"scout": false},
		"creature_position": WorldStateModel.CREATURE_SPAWN,
		"creature_health": 0,
		"creature_defeated": true,
		"reputation": 4,
		"map_rumor_unlocked": true,
		"mara_position": WorldStateModel.MARA_WELCOME_POSITION,
		"neighborhood_event_stage": "complete",
		"lit_welcome_lanterns": {"cottage": true, "road": true, "forest": true},
		"neighborhood_morale": 2,
		"chronicle": [],
		"shared_map_discoveries": {"northwood": true, "old_stone_ruins": true},
		"exploration_stage": "complete",
		"ruin_guardian_position": WorldStateModel.RUIN_GUARDIAN_SPAWN,
		"ruin_guardian_health": 0,
		"ruin_guardian_defeated": true,
		"ruin_waystone_activated": true,
		"livelihood_stage": "complete",
		"harvested_garden_plots": {
			"moonroot_1": true,
			"moonroot_2": true,
			"moonroot_3": true,
			"moonroot_4": true,
		},
		"stews_delivered": 2,
		"produce_stall_open": true,
		"player_mastery": {"scout": {"farming": 1, "cooking": 1, "trade": 1}},
		"pantry_stock": 2,
		"last_catch_up_units": 0,
		"player_provisions": {"scout": 1},
		"recovery_packs": {},
		"active_player_count": 3,
		"max_players": 8,
	}
