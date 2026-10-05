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
	assert(main.trail_survey_marker != null)
	assert(main.nima_node != null and main.nima_field_case != null and main.nima_map_table != null)

	var snapshot := _snapshot()
	snapshot["positions"] = {"explorer": Vector3(0.0, 0.6, -20.0)}
	snapshot["shared_map_discoveries"]["northwood"] = true
	snapshot["exploration_stage"] = "find_ruins"
	snapshot["player_mastery"] = {"explorer": {"exploration": 1}}
	main.receive_snapshot(snapshot)
	assert(main.map_panel.visible)
	assert("Northwood — charted" in main.map_label.text)
	assert(main.quest_title_label.text == "BEYOND THE ROAD")
	assert("find the Old Stone Ruins" in main.objective_label.text)
	assert("Pathfinder I" in main.mastery_label.text)

	snapshot["positions"] = {"explorer": WorldStateModel.RUIN_GUARDIAN_SPAWN}
	snapshot["shared_map_discoveries"]["old_stone_ruins"] = true
	snapshot["exploration_stage"] = "defeat_guardian"
	snapshot["player_attack_recovery"]["explorer"] = 0.2
	main.receive_snapshot(snapshot)
	assert(main.ruin_guardian_node.visible)
	assert("Old Stone Ruins — charted" in main.map_label.text)
	assert("Attack: recovering" in main.combat_label.text)
	snapshot["player_attack_recovery"]["explorer"] = 0.0
	snapshot["player_brace_time"]["explorer"] = 0.2
	main.receive_snapshot(snapshot)
	assert("Attack: ready" in main.combat_label.text)
	assert("Brace: braced" in main.combat_label.text)
	snapshot["player_brace_time"]["explorer"] = 0.0
	snapshot["player_brace_cooldown"]["explorer"] = 0.8
	main.receive_snapshot(snapshot)
	assert("Brace: recovering" in main.combat_label.text)
	snapshot["player_brace_cooldown"]["explorer"] = 0.0
	snapshot["ruin_guardian_attack_windup"] = WorldStateModel.ENEMY_ATTACK_WINDUP_SECONDS
	snapshot["ruin_guardian_attack_target"] = "explorer"
	main.receive_snapshot(snapshot)
	assert("Brace: ready" in main.combat_label.text)
	assert("WARNING: ruin guardian targets YOU — brace or move" in main.combat_label.text)
	assert(main.combat_warning_label.visible)
	assert(main.combat_warning_label.text == "RUIN GUARDIAN ATTACK — BRACE OR MOVE")
	assert(main.ruin_guardian_node.scale.x > 1.0)
	snapshot["ruin_guardian_attack_windup"] = 0.0
	snapshot["ruin_guardian_attack_target"] = ""
	main.receive_snapshot(snapshot)
	assert(not "WARNING:" in main.combat_label.text)
	assert(not main.combat_warning_label.visible)
	assert(is_equal_approx(main.ruin_guardian_node.scale.x, 1.0))
	snapshot["ruin_guardian_returning"] = true
	main.receive_snapshot(snapshot)
	assert("Ruin guardian: returning home" in main.combat_label.text)
	assert(main.ruin_guardian_node.scale.x < 1.0, "Returning enemies need a visible disengagement cue.")
	snapshot["ruin_guardian_returning"] = false

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

	snapshot["nima_story_stage"] = "arrival"
	snapshot["nima_position"] = WorldStateModel.NIMA_ARRIVAL_POSITION
	snapshot["nima_activity"] = "newly arrived at the home waystone"
	snapshot["positions"] = {"explorer": WorldStateModel.NIMA_ARRIVAL_POSITION}
	main.receive_snapshot(snapshot)
	assert(main.nima_node.visible)
	assert(main.quest_title_label.text == "NIMA'S BEARINGS")
	assert("Meet Nima" in main.interaction_prompt.text)
	assert("Nima:" in main.world_time_label.text)
	snapshot["nima_story_stage"] = "find_case"
	snapshot["positions"] = {"explorer": WorldStateModel.NIMA_FIELD_CASE_POSITION}
	main.receive_snapshot(snapshot)
	assert(main.nima_field_case.visible and main.nima_case_marker.visible)
	assert("Recover Nima's field case" in main.interaction_prompt.text)
	assert("field case in Northwood" in main.objective_label.text)
	snapshot["nima_story_stage"] = "return_case"
	snapshot["positions"] = {"explorer": WorldStateModel.NIMA_ARRIVAL_POSITION}
	snapshot["player_relationships"] = {"explorer": {"mara": 0, "nima": 1}}
	main.receive_snapshot(snapshot)
	assert("Return Nima's field case" in main.interaction_prompt.text)
	assert("NIMA KNOWS YOU · Map acquaintance · 1" in main.relationship_label.text)
	snapshot["nima_story_stage"] = "complete"
	snapshot["nima_position"] = WorldStateModel.NIMA_MAP_TABLE_POSITION
	snapshot["nima_activity"] = "mapping at the homestead"
	snapshot["player_relationships"]["explorer"]["nima"] = 2
	main.receive_snapshot(snapshot)
	assert(not main.nima_field_case.visible)
	assert(main.nima_map_table.visible)
	assert("NIMA KNOWS YOU · Trusted field partner · 2" in main.relationship_label.text)

	snapshot["positions"] = {"explorer": snapshot["daily_survey_position"]}
	main.receive_snapshot(snapshot)
	assert(main.trail_survey_marker.visible)
	assert("DAY 1" in main.trail_survey_marker.get_node("SurveyMarker/Label").text)
	assert("Record today's Northwood trail survey" in main.interaction_prompt.text)
	assert("Survey D1 ready" in main.world_change_label.text)
	snapshot["player_survey_day"]["explorer"] = 1
	main.receive_snapshot(snapshot)
	assert(not main.trail_survey_marker.visible)
	assert("Survey D1 recorded" in main.world_change_label.text)

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
		"player_attack_recovery": {"explorer": 0.0},
		"player_brace_time": {"explorer": 0.0},
		"player_brace_cooldown": {"explorer": 0.0},
		"creature_position": WorldStateModel.CREATURE_SPAWN,
		"creature_health": 0,
		"creature_defeated": true,
		"reputation": 2,
		"map_rumor_unlocked": true,
		"mara_position": WorldStateModel.MARA_WELCOME_POSITION,
		"mara_activity": "meeting neighbors",
		"nima_story_stage": "locked",
		"nima_position": WorldStateModel.NIMA_ARRIVAL_POSITION,
		"nima_activity": "traveling beyond Northwood",
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
		"player_survey_day": {"explorer": 0},
		"player_relationships": {"explorer": {"mara": 0, "nima": 0}},
		"player_npc_check_in_day": {"explorer": {"mara": 0}},
		"daily_survey_position": WorldStateModel.DAILY_SURVEY_POSITIONS[0],
	}
