extends SceneTree

const MainScene = preload("res://main.tscn")
const WorldStateModel = preload("res://scripts/world_state.gd")


func _init() -> void:
	var main = MainScene.instantiate()
	root.add_child(main)
	await process_frame
	main.local_token = "explorer"

	assert(main.ruin_guardian_node != null)
	assert(main.waystone_marker.get_node_or_null("Label") != null)
	assert(main.home_waystone != null and main.ruin_waystone != null)

	var snapshot := _snapshot()
	snapshot["positions"] = {"explorer": Vector3(0.0, 0.6, -20.0)}
	snapshot["shared_map_discoveries"]["northwood"] = true
	snapshot["exploration_stage"] = "find_ruins"
	main.receive_snapshot(snapshot)
	assert(main.map_panel.visible)
	assert("Northwood — charted" in main.map_label.text)
	assert(main.quest_title_label.text == "BEYOND THE ROAD")
	assert("find the Old Stone Ruins" in main.objective_label.text)

	snapshot["positions"] = {"explorer": WorldStateModel.RUIN_GUARDIAN_SPAWN}
	snapshot["shared_map_discoveries"]["old_stone_ruins"] = true
	snapshot["exploration_stage"] = "defeat_guardian"
	main.receive_snapshot(snapshot)
	assert(main.ruin_guardian_node.visible)
	assert("Old Stone Ruins — charted" in main.map_label.text)

	snapshot["positions"] = {"explorer": WorldStateModel.RUIN_WAYSTONE_POSITION}
	snapshot["exploration_stage"] = "restore_waystone"
	snapshot["ruin_guardian_defeated"] = true
	snapshot["ruin_guardian_health"] = 0
	main.receive_snapshot(snapshot)
	assert(not main.ruin_guardian_node.visible)
	assert(main.waystone_marker.visible)
	assert(main.interaction_prompt.visible)
	assert("Restore waystone" in main.interaction_prompt.text)

	snapshot["positions"] = {"explorer": WorldStateModel.HOME_WAYSTONE_POSITION}
	snapshot["exploration_stage"] = "complete"
	snapshot["ruin_waystone_activated"] = true
	main.receive_snapshot(snapshot)
	assert(main.waystone_glows.values().all(func(node: MeshInstance3D) -> bool: return node.visible))
	assert("waystone route active" in main.map_label.text)
	assert("Travel to Old Stone Ruins" in main.interaction_prompt.text)

	print("PASS: Beyond the Road is readable")
	quit()


func _snapshot() -> Dictionary:
	return {
		"positions": {},
		"collectible_collected": true,
		"quest_stage": "home_repaired",
		"materials": {"wood": 0, "herb": 0, "repair_kit": 0},
		"gathered_resources": {},
		"repaired_parts": {"door": true, "wall": true, "garden": true},
		"player_health": {"explorer": WorldStateModel.PLAYER_MAX_HEALTH},
		"downed_players": {"explorer": false},
		"creature_position": WorldStateModel.CREATURE_SPAWN,
		"creature_health": 0,
		"creature_defeated": true,
		"reputation": 2,
		"map_rumor_unlocked": true,
		"mara_position": WorldStateModel.MARA_WELCOME_POSITION,
		"neighborhood_event_stage": "complete",
		"lit_welcome_lanterns": {"cottage": true, "road": true, "forest": true},
		"neighborhood_morale": 1,
		"chronicle": [],
		"shared_map_discoveries": {"northwood": false, "old_stone_ruins": false},
		"exploration_stage": "follow_rumor",
		"ruin_guardian_position": WorldStateModel.RUIN_GUARDIAN_SPAWN,
		"ruin_guardian_health": WorldStateModel.RUIN_GUARDIAN_MAX_HEALTH,
		"ruin_guardian_defeated": false,
		"ruin_waystone_activated": false,
	}
