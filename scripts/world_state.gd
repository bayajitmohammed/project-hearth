class_name WorldState
extends RefCounted

const SPAWN_POINT := Vector3(0.0, 0.6, 10.0)
const MARA_POSITION := Vector3(-4.0, 0.6, 4.0)
const COLLECTIBLE_POSITION := Vector3(0.0, 0.5, -6.5)
const PICKUP_RADIUS := 1.15
const INTERACTION_RADIUS := 1.8
const WORLD_MIN_X := -17.0
const WORLD_MAX_X := 17.0
const WORLD_MIN_Z := -14.0
const WORLD_MAX_Z := 14.0
const RESOURCE_POSITIONS := {
	"wood_1": Vector3(-8.0, 0.45, -8.5),
	"wood_2": Vector3(7.0, 0.45, -10.0),
	"wood_3": Vector3(12.0, 0.45, -7.5),
	"herb_1": Vector3(-4.5, 0.3, -9.0),
	"herb_2": Vector3(4.5, 0.3, -8.0),
}
const RESOURCE_TYPES := {
	"wood_1": "wood", "wood_2": "wood", "wood_3": "wood",
	"herb_1": "herb", "herb_2": "herb",
}
const REPAIR_POSITIONS := {
	"door": Vector3(-10.0, 0.6, 6.2),
	"wall": Vector3(-13.7, 0.6, 3.0),
	"garden": Vector3(-7.0, 0.6, 0.3),
}

var collectible_collected := false
var positions: Dictionary = {}
var quest_stage := "meet_mara"
var materials := {"wood": 0, "herb": 0, "repair_kit": 0}
var gathered_resources: Dictionary = {}
var repaired_parts := {"door": false, "wall": false, "garden": false}


func register_player(player_token: String) -> Vector3:
	if not positions.has(player_token):
		positions[player_token] = SPAWN_POINT
	return positions[player_token]


func move_player(player_token: String, input_vector: Vector2, delta: float) -> Vector3:
	var direction := Vector3(input_vector.x, 0.0, input_vector.y)
	if direction.length_squared() > 1.0:
		direction = direction.normalized()
	var next_position: Vector3 = register_player(player_token) + direction * 4.0 * delta
	next_position.x = clampf(next_position.x, WORLD_MIN_X, WORLD_MAX_X)
	next_position.z = clampf(next_position.z, WORLD_MIN_Z, WORLD_MAX_Z)
	positions[player_token] = next_position
	return next_position


func try_collect(player_token: String) -> bool:
	if collectible_collected or quest_stage != "recover_supplies":
		return false
	if register_player(player_token).distance_to(COLLECTIBLE_POSITION) > PICKUP_RADIUS:
		return false
	collectible_collected = true
	quest_stage = "return_to_mara"
	return true


func interact_with_mara(player_token: String) -> bool:
	if register_player(player_token).distance_to(MARA_POSITION) > INTERACTION_RADIUS:
		return false
	match quest_stage:
		"meet_mara":
			quest_stage = "recover_supplies"
			return true
		"return_to_mara":
			quest_stage = "repair_cottage"
			return true
	return false


func try_gather_resource(player_token: String) -> bool:
	if quest_stage == "meet_mara" or quest_stage == "home_repaired":
		return false
	var player_position: Vector3 = register_player(player_token)
	for resource_id: String in RESOURCE_POSITIONS:
		if bool(gathered_resources.get(resource_id, false)):
			continue
		if player_position.distance_to(RESOURCE_POSITIONS[resource_id]) <= INTERACTION_RADIUS:
			gathered_resources[resource_id] = true
			var resource_type: String = RESOURCE_TYPES[resource_id]
			materials[resource_type] = int(materials.get(resource_type, 0)) + 1
			return true
	return false


func craft_repair_kit() -> bool:
	if quest_stage != "repair_cottage" or int(materials.get("repair_kit", 0)) > 0:
		return false
	if int(materials.get("wood", 0)) < 2 or int(materials.get("herb", 0)) < 1:
		return false
	materials["wood"] = int(materials["wood"]) - 2
	materials["herb"] = int(materials["herb"]) - 1
	materials["repair_kit"] = 1
	return true


func try_repair_cottage(player_token: String) -> bool:
	if quest_stage != "repair_cottage" or int(materials.get("repair_kit", 0)) < 1:
		return false
	var player_position: Vector3 = register_player(player_token)
	for part_id: String in REPAIR_POSITIONS:
		if bool(repaired_parts.get(part_id, false)):
			continue
		if player_position.distance_to(REPAIR_POSITIONS[part_id]) <= INTERACTION_RADIUS:
			repaired_parts[part_id] = true
			if _all_repairs_complete():
				materials["repair_kit"] = 0
				quest_stage = "home_repaired"
			return true
	return false


func interact(player_token: String) -> bool:
	return (
		interact_with_mara(player_token)
		or try_gather_resource(player_token)
		or try_repair_cottage(player_token)
	)


func _all_repairs_complete() -> bool:
	for is_repaired: bool in repaired_parts.values():
		if not is_repaired:
			return false
	return true


func to_dictionary() -> Dictionary:
	var encoded_positions := {}
	for player_token: String in positions:
		var position: Vector3 = positions[player_token]
		encoded_positions[player_token] = [position.x, position.y, position.z]
	return {
		"version": 2,
		"collectible_collected": collectible_collected,
		"quest_stage": quest_stage,
		"materials": materials.duplicate(),
		"gathered_resources": gathered_resources.duplicate(),
		"repaired_parts": repaired_parts.duplicate(),
		"positions": encoded_positions,
	}


func load_dictionary(data: Dictionary) -> void:
	collectible_collected = bool(data.get("collectible_collected", false))
	quest_stage = str(data.get("quest_stage", "return_to_mara" if collectible_collected else "meet_mara"))
	var saved_materials: Dictionary = data.get("materials", {})
	materials = {
		"wood": int(saved_materials.get("wood", 0)),
		"herb": int(saved_materials.get("herb", 0)),
		"repair_kit": int(saved_materials.get("repair_kit", 0)),
	}
	gathered_resources = data.get("gathered_resources", {}).duplicate()
	var saved_repairs: Dictionary = data.get("repaired_parts", {})
	repaired_parts = {
		"door": bool(saved_repairs.get("door", false)),
		"wall": bool(saved_repairs.get("wall", false)),
		"garden": bool(saved_repairs.get("garden", false)),
	}
	positions.clear()
	var encoded_positions: Dictionary = data.get("positions", {})
	for player_token: String in encoded_positions:
		var encoded: Array = encoded_positions[player_token]
		if encoded.size() == 3:
			positions[player_token] = Vector3(float(encoded[0]), float(encoded[1]), float(encoded[2]))
