extends SceneTree

const MainScene = preload("res://main.tscn")
const WorldStateModel = preload("res://scripts/world_state.gd")


func _init() -> void:
	var main = MainScene.instantiate()
	root.add_child(main)
	await process_frame
	main.local_token = "runner"

	var snapshot := _snapshot()
	main.receive_snapshot(snapshot)
	assert(main.quest_title_label.text == "GATHER AND CELEBRATE")
	assert("Join the Hearthlight Circuit" in main.objective_label.text)
	assert("Players 2/8" in main.progress_label.text)
	assert("Your ribbons 0" in main.progress_label.text)
	assert(main.festival_arch.visible)
	assert(not main.festival_decorations.visible)
	assert(main.interaction_prompt.visible)
	assert("Join the Hearthlight Circuit" in main.interaction_prompt.text)

	snapshot["festival_stage"] = "signup"
	snapshot["festival_participants"] = {"runner": 0, "friend": 0}
	main.receive_snapshot(snapshot)
	assert("Start the Hearthlight Circuit" in main.objective_label.text)
	assert("Entrants 2" in main.progress_label.text)
	assert("Start the circuit" in main.interaction_prompt.text)

	snapshot["festival_stage"] = "racing"
	snapshot["positions"]["runner"] = WorldStateModel.FESTIVAL_CHECKPOINT_POSITIONS["forest_turn"]
	main.receive_snapshot(snapshot)
	assert("checkpoint 1 of 3" in main.objective_label.text)
	assert("Checkpoint 0/3" in main.progress_label.text)
	assert("Claim checkpoint 1/3" in main.interaction_prompt.text)
	for checkpoint: Node3D in main.festival_checkpoint_nodes.values():
		assert(checkpoint.visible)

	snapshot["festival_stage"] = "results"
	snapshot["festival_completed"] = true
	snapshot["festival_last_winner"] = "runner"
	snapshot["festival_ribbons"] = {"runner": 1}
	snapshot["positions"]["runner"] = WorldStateModel.FESTIVAL_ARCH_POSITION
	main.receive_snapshot(snapshot)
	assert("Winner you" in main.progress_label.text)
	assert("Your ribbons 1" in main.progress_label.text)
	assert(main.festival_decorations.visible)
	assert("another run" in main.dialogue_label.text)

	var main_source := FileAccess.get_file_as_string("res://scripts/main.gd")
	var state_source := FileAccess.get_file_as_string("res://scripts/world_state.gd")
	assert(state_source.contains("func try_festival_interaction"), "The circuit must be authoritative world state.")
	assert(state_source.contains("festival_ribbons"), "Cosmetic festival rewards must persist per player.")
	assert(main_source.contains("Gear, mastery, and provisions grant no advantage"), "Normalized play needs explicit player-facing guidance.")
	print("PASS: Project Hearth festival readability")
	quit()


func _snapshot() -> Dictionary:
	return {
		"positions": {"runner": WorldStateModel.FESTIVAL_ARCH_POSITION, "friend": Vector3.ZERO},
		"collectible_collected": true,
		"quest_stage": "home_repaired",
		"materials": {"wood": 0, "herb": 0, "repair_kit": 0, "moonroot": 0, "hearth_stew": 0},
		"gathered_resources": {},
		"repaired_parts": {"door": true, "wall": true, "garden": true},
		"player_health": {"runner": WorldStateModel.PLAYER_MAX_HEALTH},
		"downed_players": {"runner": false},
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
		"player_mastery": {"runner": {"farming": 1, "cooking": 1, "trade": 1}},
		"pantry_stock": 1,
		"last_catch_up_units": 0,
		"player_provisions": {"runner": 0},
		"recovery_packs": {},
		"festival_stage": "available",
		"festival_completed": false,
		"festival_ribbons": {"runner": 0},
		"festival_last_winner": "",
		"festival_participants": {},
		"festival_finishers": [],
		"active_player_count": 2,
		"max_players": 8,
	}
