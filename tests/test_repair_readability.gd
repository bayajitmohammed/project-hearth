extends SceneTree

const MainScene = preload("res://main.tscn")
const WorldStateModel = preload("res://scripts/world_state.gd")


func _init() -> void:
	var main = MainScene.instantiate()
	root.add_child(main)
	await process_frame

	assert(main.get("quest_card") != null, "The player HUD needs a compact quest card.")
	assert(main.get("debug_panel") != null, "Debug information needs its own hideable panel.")
	assert(not main.get("debug_panel").visible, "Debug information must be hidden during normal play.")

	for part_id: String in WorldStateModel.REPAIR_POSITIONS:
		var repair_position: Vector3 = WorldStateModel.REPAIR_POSITIONS[part_id]
		assert(repair_position.z >= 5.8, "%s interaction is obscured behind the cottage." % part_id)
		var marker: Node = main.repair_nodes[part_id]
		assert(marker.get_node_or_null("Label") != null, "%s marker needs a readable world label." % part_id)

	print("PASS: Repair objectives are readable")
	quit()
