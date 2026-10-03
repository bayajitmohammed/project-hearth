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
	main._save_world()
	assert(not main.save_recovered_from_backup)
	assert(main._read_world_dictionary(test_save_path) is Dictionary, "Recovery must restore a valid primary save.")

	root.remove_child(main)
	main.free()
	for suffix: String in ["", ".tmp", ".bak"]:
		if FileAccess.file_exists(test_save_path + suffix):
			DirAccess.remove_absolute(absolute_test_save_path + suffix)
	print("PASS: Offline, LAN host, and join play-mode foundations")
	quit()
