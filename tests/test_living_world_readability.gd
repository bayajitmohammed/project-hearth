extends SceneTree

const MainScene = preload("res://main.tscn")
const WorldStateModel = preload("res://scripts/world_state.gd")


func _init() -> void:
	var main = MainScene.instantiate()
	root.add_child(main)
	await process_frame

	assert(main.mara_node != null, "Mara's routine needs a movable world node.")
	assert(main.chronicle_panel != null, "Remembered changes need a visible chronicle panel.")
	assert(main.world_time_label != null, "The authoritative calendar needs a readable HUD label.")
	for lantern_id: String in WorldStateModel.WELCOME_LANTERN_POSITIONS:
		assert(main.welcome_lantern_markers.has(lantern_id))
		assert(main.welcome_lantern_lights.has(lantern_id))
		assert(main.welcome_lantern_markers[lantern_id].get_node_or_null("Label") != null)

	main.local_token = "reader"
	var lighting_snapshot := _base_snapshot()
	lighting_snapshot["positions"] = {"reader": WorldStateModel.WELCOME_LANTERN_POSITIONS["road"]}
	lighting_snapshot["neighborhood_event_stage"] = "lighting"
	lighting_snapshot["mara_position"] = WorldStateModel.MARA_WELCOME_POSITION
	lighting_snapshot["chronicle"] = ["The newcomers repaired the abandoned cottage and made it their home."]
	main.receive_snapshot(lighting_snapshot)
	assert(main.mara_node.position == WorldStateModel.MARA_WELCOME_POSITION)
	assert(main.welcome_lantern_markers["road"].visible)
	assert(main.interaction_prompt.visible)
	assert("Light Road Lantern" in main.interaction_prompt.text)
	assert(main.chronicle_panel.visible)
	assert(main.quest_title_label.text == "WELCOME LIGHTS")

	var complete_snapshot := _base_snapshot()
	complete_snapshot["positions"] = {"reader": WorldStateModel.WELCOME_LANTERN_POSITIONS["road"]}
	complete_snapshot["neighborhood_event_stage"] = "complete"
	complete_snapshot["mara_position"] = WorldStateModel.MARA_WELCOME_POSITION
	complete_snapshot["lit_welcome_lanterns"] = {"cottage": true, "road": true, "forest": true}
	complete_snapshot["neighborhood_morale"] = 1
	complete_snapshot["reputation"] = 2
	complete_snapshot["exploration_stage"] = "follow_rumor"
	complete_snapshot["chronicle"] = [
		"The newcomers repaired the abandoned cottage and made it their home.",
		"Together, the neighborhood lit welcome lanterns to celebrate its new residents.",
	]
	main.receive_snapshot(complete_snapshot)
	assert(main.welcome_lantern_lights.values().all(func(node: Node3D) -> bool: return node.visible))
	assert(not main.welcome_lantern_markers.values().any(func(node: Node3D) -> bool: return node.visible))
	assert(main.quest_title_label.text == "BEYOND THE ROAD")
	assert("northern road" in main.objective_label.text)
	assert("Chronicle entries: 2" in main.world_change_label.text)
	assert("repaired the abandoned cottage" in main.chronicle_label.text)
	assert("lit welcome lanterns" in main.chronicle_label.text)
	assert(main.world_time_label.visible)
	assert("Day 1" in main.world_time_label.text)
	assert("Mara:" in main.world_time_label.text)

	print("PASS: Living-world response is readable")
	quit()


func _base_snapshot() -> Dictionary:
	return {
		"positions": {},
		"collectible_collected": true,
		"quest_stage": "home_repaired",
		"materials": {"wood": 0, "herb": 0, "repair_kit": 0},
		"gathered_resources": {},
		"repaired_parts": {"door": true, "wall": true, "garden": true},
		"player_health": {"reader": WorldStateModel.PLAYER_MAX_HEALTH},
		"downed_players": {"reader": false},
		"creature_position": WorldStateModel.CREATURE_SPAWN,
		"creature_health": 0,
		"creature_defeated": true,
		"reputation": 1,
		"map_rumor_unlocked": true,
		"mara_position": WorldStateModel.MARA_POSITION,
		"mara_activity": "meeting neighbors",
		"world_day": 1,
		"world_minute": WorldStateModel.WORLD_START_MINUTE,
		"world_time_period": "Afternoon",
		"neighborhood_event_stage": "invitation",
		"lit_welcome_lanterns": {"cottage": false, "road": false, "forest": false},
		"neighborhood_morale": 0,
		"chronicle": [],
		"shared_map_discoveries": {"northwood": false, "old_stone_ruins": false},
		"exploration_stage": "locked",
		"ruin_guardian_position": WorldStateModel.RUIN_GUARDIAN_SPAWN,
		"ruin_guardian_health": WorldStateModel.RUIN_GUARDIAN_MAX_HEALTH,
		"ruin_guardian_defeated": false,
		"ruin_waystone_activated": false,
	}
