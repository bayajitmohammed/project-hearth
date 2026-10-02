class_name WorldState
extends RefCounted

const SPAWN_POINT := Vector3(0.0, 0.6, 10.0)
const MARA_POSITION := Vector3(-4.0, 0.6, 4.0)
const MARA_WELCOME_POSITION := Vector3(4.0, 0.6, 4.0)
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
	"door": Vector3(-10.0, 0.6, 6.5),
	"wall": Vector3(-13.8, 0.6, 6.5),
	"garden": Vector3(-6.2, 0.6, 6.5),
}
const REPAIR_LABELS := {"door": "DOOR", "wall": "WALL", "garden": "GARDEN"}
const WELCOME_LANTERN_POSITIONS := {
	"cottage": Vector3(-4.0, 0.6, 1.0),
	"road": Vector3(0.0, 0.6, 1.0),
	"forest": Vector3(4.0, 0.6, 1.0),
}
const WELCOME_LANTERN_LABELS := {
	"cottage": "COTTAGE LANTERN",
	"road": "ROAD LANTERN",
	"forest": "FOREST LANTERN",
}
const CREATURE_SPAWN := Vector3(9.0, 0.65, -6.5)
const CREATURE_MAX_HEALTH := 3
const PLAYER_MAX_HEALTH := 3

var collectible_collected := false
var positions: Dictionary = {}
var quest_stage := "meet_mara"
var materials := {"wood": 0, "herb": 0, "repair_kit": 0}
var gathered_resources: Dictionary = {}
var repaired_parts := {"door": false, "wall": false, "garden": false}
var player_health: Dictionary = {}
var downed_players: Dictionary = {}
var creature_position := CREATURE_SPAWN
var creature_health := CREATURE_MAX_HEALTH
var creature_defeated := false
var creature_attack_cooldown := 0.0
var reputation := 0
var map_rumor_unlocked := false
var mara_position := MARA_POSITION
var neighborhood_event_stage := "locked"
var lit_welcome_lanterns := {"cottage": false, "road": false, "forest": false}
var neighborhood_morale := 0
var chronicle: Array = []


func register_player(player_token: String) -> Vector3:
	if not positions.has(player_token):
		positions[player_token] = SPAWN_POINT
	if not player_health.has(player_token):
		player_health[player_token] = PLAYER_MAX_HEALTH
	if not downed_players.has(player_token):
		downed_players[player_token] = false
	return positions[player_token]


func move_player(player_token: String, input_vector: Vector2, delta: float) -> Vector3:
	register_player(player_token)
	if bool(downed_players.get(player_token, false)):
		return positions[player_token]
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
	if register_player(player_token).distance_to(mara_position) > INTERACTION_RADIUS:
		return false
	match quest_stage:
		"meet_mara":
			quest_stage = "recover_supplies"
			return true
		"return_to_mara":
			quest_stage = "repair_cottage"
			return true
		"home_repaired":
			if neighborhood_event_stage == "invitation":
				neighborhood_event_stage = "lighting"
				mara_position = MARA_WELCOME_POSITION
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
				reputation = 1
				map_rumor_unlocked = true
				neighborhood_event_stage = "invitation"
				chronicle.append("The newcomers repaired the abandoned cottage and made it their home.")
			return true
	return false


func try_light_welcome_lantern(player_token: String) -> bool:
	if neighborhood_event_stage != "lighting":
		return false
	var player_position: Vector3 = register_player(player_token)
	for lantern_id: String in WELCOME_LANTERN_POSITIONS:
		if bool(lit_welcome_lanterns.get(lantern_id, false)):
			continue
		if player_position.distance_to(WELCOME_LANTERN_POSITIONS[lantern_id]) <= INTERACTION_RADIUS:
			lit_welcome_lanterns[lantern_id] = true
			if _all_welcome_lanterns_lit():
				neighborhood_event_stage = "complete"
				neighborhood_morale = 1
				reputation += 1
				chronicle.append("Together, the neighborhood lit welcome lanterns to celebrate its new residents.")
			return true
	return false


func interact(player_token: String) -> bool:
	return (
		try_revive_player(player_token)
		or interact_with_mara(player_token)
		or try_gather_resource(player_token)
		or try_repair_cottage(player_token)
		or try_light_welcome_lantern(player_token)
	)


func attack_creature(player_token: String) -> bool:
	register_player(player_token)
	if creature_defeated or bool(downed_players.get(player_token, false)):
		return false
	if positions[player_token].distance_to(creature_position) > 2.0:
		return false
	creature_health -= 1
	if creature_health <= 0:
		creature_health = 0
		creature_defeated = true
	return true


func simulate_creature(delta: float, active_tokens: Array) -> bool:
	if creature_defeated:
		return false
	creature_attack_cooldown = maxf(creature_attack_cooldown - delta, 0.0)
	var target_token := ""
	var target_distance := INF
	for player_token: String in active_tokens:
		register_player(player_token)
		if bool(downed_players.get(player_token, false)):
			continue
		var distance := creature_position.distance_to(positions[player_token])
		if distance < target_distance:
			target_distance = distance
			target_token = player_token
	if target_token.is_empty() or target_distance > 6.0:
		return false
	var target_position: Vector3 = positions[target_token]
	if target_distance > 1.15:
		var direction := (target_position - creature_position).normalized()
		creature_position += direction * minf(1.5 * delta, target_distance - 1.0)
		creature_position.y = CREATURE_SPAWN.y
		return false
	if creature_attack_cooldown > 0.0:
		return false
	creature_attack_cooldown = 1.0
	player_health[target_token] = maxi(int(player_health[target_token]) - 1, 0)
	if int(player_health[target_token]) == 0:
		downed_players[target_token] = true
	return true


func try_revive_player(helper_token: String) -> bool:
	register_player(helper_token)
	if bool(downed_players.get(helper_token, false)):
		return false
	for player_token: String in downed_players:
		if player_token == helper_token or not bool(downed_players[player_token]):
			continue
		if positions[helper_token].distance_to(register_player(player_token)) <= INTERACTION_RADIUS:
			downed_players[player_token] = false
			player_health[player_token] = 2
			return true
	return false


func _all_repairs_complete() -> bool:
	for is_repaired: bool in repaired_parts.values():
		if not is_repaired:
			return false
	return true


func _all_welcome_lanterns_lit() -> bool:
	for is_lit: bool in lit_welcome_lanterns.values():
		if not is_lit:
			return false
	return true


func to_dictionary() -> Dictionary:
	var encoded_positions := {}
	for player_token: String in positions:
		var position: Vector3 = positions[player_token]
		encoded_positions[player_token] = [position.x, position.y, position.z]
	return {
		"version": 4,
		"collectible_collected": collectible_collected,
		"quest_stage": quest_stage,
		"materials": materials.duplicate(),
		"gathered_resources": gathered_resources.duplicate(),
		"repaired_parts": repaired_parts.duplicate(),
		"player_health": player_health.duplicate(),
		"downed_players": downed_players.duplicate(),
		"creature_position": [creature_position.x, creature_position.y, creature_position.z],
		"creature_health": creature_health,
		"creature_defeated": creature_defeated,
		"reputation": reputation,
		"map_rumor_unlocked": map_rumor_unlocked,
		"neighborhood_event_stage": neighborhood_event_stage,
		"lit_welcome_lanterns": lit_welcome_lanterns.duplicate(),
		"neighborhood_morale": neighborhood_morale,
		"chronicle": chronicle.duplicate(),
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
	player_health = data.get("player_health", {}).duplicate()
	downed_players = data.get("downed_players", {}).duplicate()
	var encoded_creature: Array = data.get("creature_position", [])
	if encoded_creature.size() == 3:
		creature_position = Vector3(float(encoded_creature[0]), float(encoded_creature[1]), float(encoded_creature[2]))
	else:
		creature_position = CREATURE_SPAWN
	creature_health = int(data.get("creature_health", CREATURE_MAX_HEALTH))
	creature_defeated = bool(data.get("creature_defeated", false))
	reputation = int(data.get("reputation", 1 if quest_stage == "home_repaired" else 0))
	map_rumor_unlocked = bool(data.get("map_rumor_unlocked", quest_stage == "home_repaired"))
	var save_version := int(data.get("version", 1))
	if save_version >= 4:
		neighborhood_event_stage = str(data.get("neighborhood_event_stage", "locked"))
		var saved_lanterns: Dictionary = data.get("lit_welcome_lanterns", {})
		lit_welcome_lanterns = {
			"cottage": bool(saved_lanterns.get("cottage", false)),
			"road": bool(saved_lanterns.get("road", false)),
			"forest": bool(saved_lanterns.get("forest", false)),
		}
		neighborhood_morale = int(data.get("neighborhood_morale", 0))
		chronicle = data.get("chronicle", []).duplicate()
	else:
		neighborhood_event_stage = "invitation" if quest_stage == "home_repaired" else "locked"
		lit_welcome_lanterns = {"cottage": false, "road": false, "forest": false}
		neighborhood_morale = 0
		chronicle = []
		if quest_stage == "home_repaired":
			chronicle.append("The newcomers repaired the abandoned cottage and made it their home.")
	mara_position = MARA_WELCOME_POSITION if neighborhood_event_stage in ["lighting", "complete"] else MARA_POSITION
	positions.clear()
	var encoded_positions: Dictionary = data.get("positions", {})
	for player_token: String in encoded_positions:
		var encoded: Array = encoded_positions[player_token]
		if encoded.size() == 3:
			positions[player_token] = Vector3(float(encoded[0]), float(encoded[1]), float(encoded[2]))
