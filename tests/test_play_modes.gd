extends SceneTree

const MainScene = preload("res://main.tscn")
const WorldStateModel = preload("res://scripts/world_state.gd")


func _init() -> void:
	var test_save_path := "/tmp/project-hearth-play-mode-%d.json" % OS.get_process_id()
	var absolute_test_save_path := test_save_path
	for suffix: String in ["", ".tmp", ".bak"]:
		if FileAccess.file_exists(test_save_path + suffix):
			DirAccess.remove_absolute(absolute_test_save_path + suffix)

	var main = MainScene.instantiate()
	root.add_child(main)
	await process_frame

	assert(main.offline_button.text == "Play Offline")
	assert(main.host_button.text == "Host LAN Game")
	assert(main.connect_button.text == "Join Room")
	assert(main.OFFLINE_SAVE_PATH != main.HOSTED_SAVE_PATH, "Offline and hosted worlds must not share a save.")

	main.local_token = "offline-test-player"
	main.room_code_input.text = ""
	main._start_local_world(false, test_save_path)
	assert(main.is_server, "Offline play must run the authoritative simulation locally.")
	assert(main.local_authority_player)
	assert(main.client_connected)
	assert(not main.broadcasts_to_clients, "Offline play must not open or use a network listener.")
	assert(main.peer_to_token == {1: "offline-test-player"})
	assert(main.server_room_code == main.DEFAULT_ROOM_CODE)
	assert(not main.connection_panel.visible)
	assert(main.session_status_label.visible)
	assert("no internet" not in main.session_status_label.text.to_lower(), "Status should describe the mode, not imply connectivity.")
	assert(main.latest_snapshot.get("active_player_count") == 1)
	var created_seed: int = main.world_state.world_seed
	assert(created_seed >= 1 and created_seed <= WorldStateModel.MAX_WORLD_SEED)
	if "--world-seed=112358" in OS.get_cmdline_user_args():
		assert(created_seed == 112358, "Creation-only seed override must be respected.")
	assert(main.latest_snapshot["world_seed"] == created_seed)
	assert(main.rendered_world_seed == created_seed)

	var starting_position: Vector3 = main.world_state.positions[main.local_token]
	main.peer_inputs[1] = Vector2.RIGHT
	main._simulate_server(0.25)
	assert(main.world_state.positions[main.local_token] != starting_position, "The local authority player must use normal server movement rules.")

	main.world_state.quest_stage = "recover_supplies"
	main.world_state.positions[main.local_token] = main.world_state.COLLECTIBLE_POSITION
	main._request_collect()
	assert(main.world_state.collectible_collected, "Local interactions must pass through the authoritative world state.")
	assert(FileAccess.file_exists(test_save_path), "Offline progress must persist on the device.")
	assert(FileAccess.file_exists(test_save_path + ".bak"), "Saving must retain the previous valid checkpoint.")

	var corrupt_primary := FileAccess.open(test_save_path, FileAccess.WRITE)
	assert(corrupt_primary != null)
	corrupt_primary.store_string("not valid json")
	corrupt_primary.close()
	main.world_state = WorldStateModel.new()
	main._load_world()
	assert(main.save_recovered_from_backup, "An unreadable primary save must fall back to its backup.")
	assert(main.world_state.quest_stage == "meet_mara", "Recovery must load the previous valid checkpoint.")
	assert(main.world_state.world_seed == created_seed, "Backup recovery retains the original world seed.")
	main._save_world()
	assert(not main.save_recovered_from_backup)
	assert(main._read_world_dictionary(test_save_path) is Dictionary, "Recovery must restore a valid primary save.")
	main.world_state.quest_stage = "home_repaired"
	main.world_state.positions[main.local_token] = WorldStateModel.furnishing_position(Vector2i.ZERO) + Vector3(0, 0.6, 1)
	main.world_state.materials["wood"] = 2
	main._request_furnishing(Vector2i.ZERO, "bench", 2, false)
	assert(main.latest_snapshot["furnishings"]["0,0"]["rotation"] == 2)
	assert(main.world_state.materials["wood"] == 0)
	main._load_world()
	assert(main.world_state.furnishings["0,0"]["kind"] == "bench", "Offline furnishings survive local save/load.")
	main._request_furnishing(Vector2i.ZERO, "", 0, true)
	assert(main.world_state.furnishings.is_empty())
	assert(main.world_state.materials["wood"] == 2)
	main.set_physics_process(false)
	main.set_process(false)
	main.world_state.positions[main.local_token] = WorldStateModel.CREATURE_SPAWN
	main.world_state.creature_position = WorldStateModel.CREATURE_SPAWN
	main.world_state.creature_defeated = false
	main.world_state.creature_health = WorldStateModel.CREATURE_MAX_HEALTH
	main.homestead_builder.toggle_mode()
	Input.action_press("power_strike")
	main._update_local_authority_input()
	Input.action_release("power_strike")
	assert(main.world_state.creature_health == WorldStateModel.CREATURE_MAX_HEALTH, "The furnishing rotation key must not also attack.")
	main._request_attack()
	main._request_brace()
	assert(main.world_state.creature_health == WorldStateModel.CREATURE_MAX_HEALTH)
	assert(float(main.world_state.player_brace_time.get(main.local_token, 0.0)) == 0.0)
	main.homestead_builder.toggle_mode()
	main._request_power_strike()
	assert(main.world_state.creature_health == WorldStateModel.CREATURE_MAX_HEALTH - 2, "Combat resumes after closing furnishing mode.")

	root.remove_child(main)
	main.free()
	for suffix: String in ["", ".tmp", ".bak"]:
		if FileAccess.file_exists(test_save_path + suffix):
			DirAccess.remove_absolute(absolute_test_save_path + suffix)
	print("PASS: Offline, LAN host, and join play-mode foundations")
	quit()
