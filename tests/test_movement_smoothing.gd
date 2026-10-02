extends SceneTree

const MainScene = preload("res://main.tscn")
const WorldStateModel = preload("res://scripts/world_state.gd")


func _init() -> void:
	var main = MainScene.instantiate()
	root.add_child(main)
	await process_frame
	main.local_token = "moving-player"

	var snapshot := _snapshot_at(Vector3(0.0, 0.6, 8.0))
	main.receive_snapshot(snapshot)
	var player: MeshInstance3D = main.player_nodes[main.local_token]
	assert(player.position == Vector3(0.0, 0.6, 8.0), "A newly seen player must begin at the authoritative position.")

	snapshot["positions"][main.local_token] = Vector3(0.0, 0.6, 7.8)
	main.receive_snapshot(snapshot)
	assert(player.position == Vector3(0.0, 0.6, 8.0), "A snapshot must not snap an existing player mesh.")
	assert(main.player_target_positions[main.local_token] == Vector3(0.0, 0.6, 7.8))

	main._process(1.0 / 60.0)
	assert(player.position.z < 8.0 and player.position.z > 7.8, "Rendered movement must advance smoothly toward the server position.")
	for frame: int in 30:
		main._process(1.0 / 60.0)
	assert(player.position.distance_to(Vector3(0.0, 0.6, 7.8)) < 0.001, "Interpolation must converge on the server position.")

	main.receive_snapshot(_snapshot_without_players())
	assert(not main.player_nodes.has(main.local_token))
	assert(not main.player_target_positions.has(main.local_token), "Disconnected players must not leave interpolation targets behind.")

	print("PASS: Networked player movement is smoothed")
	quit()


func _snapshot_at(position: Vector3) -> Dictionary:
	var snapshot := _snapshot_without_players()
	snapshot["positions"] = {"moving-player": position}
	snapshot["player_health"] = {"moving-player": WorldStateModel.PLAYER_MAX_HEALTH}
	snapshot["downed_players"] = {"moving-player": false}
	return snapshot


func _snapshot_without_players() -> Dictionary:
	return {
		"positions": {},
		"collectible_collected": false,
		"quest_stage": "meet_mara",
		"materials": {"wood": 0, "herb": 0, "repair_kit": 0},
		"gathered_resources": {},
		"repaired_parts": {"door": false, "wall": false, "garden": false},
		"player_health": {},
		"downed_players": {},
		"creature_position": WorldStateModel.CREATURE_SPAWN,
		"creature_health": WorldStateModel.CREATURE_MAX_HEALTH,
		"creature_defeated": false,
		"reputation": 0,
		"map_rumor_unlocked": false,
		"mara_position": WorldStateModel.MARA_POSITION,
		"neighborhood_event_stage": "locked",
		"lit_welcome_lanterns": {"cottage": false, "road": false, "forest": false},
		"neighborhood_morale": 0,
		"chronicle": [],
	}
