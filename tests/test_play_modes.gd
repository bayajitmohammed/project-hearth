extends SceneTree

const MainScene = preload("res://main.tscn")


func _init() -> void:
	var test_save_path := "/tmp/project-hearth-play-mode-%d.json" % OS.get_process_id()
	var absolute_test_save_path := test_save_path
	if FileAccess.file_exists(test_save_path):
		DirAccess.remove_absolute(absolute_test_save_path)

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

	root.remove_child(main)
	main.free()
	DirAccess.remove_absolute(absolute_test_save_path)
	print("PASS: Offline, LAN host, and join play-mode foundations")
	quit()
