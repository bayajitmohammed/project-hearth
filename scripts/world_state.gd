class_name WorldState
extends RefCounted

const SPAWN_POINT := Vector3(0.0, 0.6, 10.0)
const COTTAGE_REST_POSITION := Vector3(-10.0, 0.6, 3.8)
const MARA_POSITION := Vector3(-4.0, 0.6, 4.0)
const MARA_WELCOME_POSITION := Vector3(4.0, 0.6, 4.0)
const MARA_MARKET_POSITION := Vector3(7.0, 0.6, 4.0)
const COLLECTIBLE_POSITION := Vector3(0.0, 0.5, -6.5)
const PICKUP_RADIUS := 1.15
const INTERACTION_RADIUS := 1.8
const WORLD_MIN_X := -17.0
const WORLD_MAX_X := 17.0
const WORLD_MIN_Z := -48.0
const WORLD_MAX_Z := 14.0
const REGION_SEED := 73021
const NORTHWOOD_REVEAL_Z := -16.0
const RUINS_POSITION := Vector3(0.0, 0.6, -40.0)
const RUINS_REVEAL_RADIUS := 7.0
const RUIN_GUARDIAN_SPAWN := Vector3(0.0, 0.65, -34.0)
const RUIN_GUARDIAN_MAX_HEALTH := 5
const HOME_WAYSTONE_POSITION := Vector3(8.0, 0.6, 8.5)
const RUIN_WAYSTONE_POSITION := Vector3(0.0, 0.6, -39.0)
const HOME_WAYSTONE_ARRIVAL := Vector3(8.0, 0.6, 6.5)
const RUIN_WAYSTONE_ARRIVAL := Vector3(0.0, 0.6, -37.0)
const GARDEN_PLOT_POSITIONS := {
	"moonroot_1": Vector3(-14.0, 0.35, 9.0),
	"moonroot_2": Vector3(-11.0, 0.35, 9.0),
	"moonroot_3": Vector3(-8.0, 0.35, 9.0),
	"moonroot_4": Vector3(-5.0, 0.35, 9.0),
}
const COOKFIRE_POSITION := Vector3(-6.5, 0.6, 5.0)
const MARKET_CRATE_POSITION := Vector3(5.5, 0.6, 3.5)
const REQUIRED_STEW_DELIVERIES := 2
const DAILY_FRESH_MOONROOT_DELIVERIES := 3
const DAILY_ORDER_FRESH_MOONROOT := "fresh_moonroot"
const DAILY_ORDER_HEARTH_STEW := "hearth_stew"
const FARMING_TIER_TWO_MASTERY := 8
const COOKING_TIER_TWO_MASTERY := 4
const TRADE_TIER_TWO_MASTERY := 4
const PANTRY_CATCH_UP_INTERVAL_SECONDS := 60
const PANTRY_MAX_STOCK := 3
const FESTIVAL_ARCH_POSITION := Vector3(10.5, 0.6, 6.0)
const FESTIVAL_CHECKPOINT_POSITIONS := {
	"forest_turn": Vector3(12.0, 0.6, -6.0),
	"road_lantern": Vector3(0.0, 0.6, 1.0),
	"festival_finish": FESTIVAL_ARCH_POSITION,
}
const FESTIVAL_CHECKPOINT_ORDER := ["forest_turn", "road_lantern", "festival_finish"]
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
const WORLD_MINUTES_PER_DAY := 1440
const WORLD_MINUTES_PER_REAL_SECOND := 1.0
const WORLD_START_MINUTE := 13 * 60
const OFFLINE_CALENDAR_MAX_MINUTES := 6 * 60
const WORLD_SAVE_INTERVAL_MINUTES := 30
const WEATHER_LABELS := {
	"clear": "Clear skies",
	"overcast": "Overcast",
	"gentle_rain": "Gentle rain",
}

var collectible_collected := false
var positions: Dictionary = {}
var quest_stage := "meet_mara"
var materials := {"wood": 0, "herb": 0, "repair_kit": 0, "moonroot": 0, "hearth_stew": 0}
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
var shared_map_discoveries := {"northwood": false, "old_stone_ruins": false}
var exploration_stage := "locked"
var ruin_guardian_position := RUIN_GUARDIAN_SPAWN
var ruin_guardian_health := RUIN_GUARDIAN_MAX_HEALTH
var ruin_guardian_defeated := false
var ruin_guardian_attack_cooldown := 0.0
var ruin_waystone_activated := false
var livelihood_stage := "locked"
var harvested_garden_plots := {
	"moonroot_1": false,
	"moonroot_2": false,
	"moonroot_3": false,
	"moonroot_4": false,
}
var stews_delivered := 0
var produce_stall_open := false
var daily_food_order_active := false
var daily_food_order_day := 0
var daily_food_order_kind := ""
var daily_food_deliveries := 0
var player_mastery: Dictionary = {}
var pantry_stock := 0
var last_world_empty_unix := 0
var last_catch_up_units := 0
var player_provisions: Dictionary = {}
var recovery_packs: Dictionary = {}
var festival_stage := "locked"
var festival_completed := false
var festival_ribbons: Dictionary = {}
var festival_last_winner := ""
var festival_participants: Dictionary = {}
var festival_finishers: Array = []
var world_day := 1
var world_minute := WORLD_START_MINUTE
var world_clock_fraction := 0.0
var mara_activity := "waiting by the cottage"


func register_player(player_token: String) -> Vector3:
	if not positions.has(player_token):
		positions[player_token] = SPAWN_POINT
	if not player_health.has(player_token):
		player_health[player_token] = PLAYER_MAX_HEALTH
	if not downed_players.has(player_token):
		downed_players[player_token] = false
	if not player_mastery.has(player_token):
		player_mastery[player_token] = {"farming": 0, "cooking": 0, "trade": 0}
	if not player_provisions.has(player_token):
		player_provisions[player_token] = 0
	if not festival_ribbons.has(player_token):
		festival_ribbons[player_token] = 0
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


func update_exploration(player_token: String) -> bool:
	if exploration_stage == "locked" or not positions.has(player_token):
		return false
	var changed := false
	var player_position: Vector3 = positions[player_token]
	if player_position.z <= NORTHWOOD_REVEAL_Z and not bool(shared_map_discoveries["northwood"]):
		shared_map_discoveries["northwood"] = true
		exploration_stage = "find_ruins"
		changed = true
	if (
		player_position.distance_to(RUINS_POSITION) <= RUINS_REVEAL_RADIUS
		and not bool(shared_map_discoveries["old_stone_ruins"])
	):
		shared_map_discoveries["old_stone_ruins"] = true
		exploration_stage = "defeat_guardian"
		changed = true
	return changed


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
				exploration_stage = "follow_rumor"
				chronicle.append("Together, the neighborhood lit welcome lanterns to celebrate its new residents.")
				_update_mara_routine()
			return true
	return false


func interact(player_token: String) -> bool:
	return (
		try_revive_player(player_token)
		or try_return_to_safety(player_token)
		or try_recover_pack(player_token)
		or try_rest_at_cottage(player_token)
		or try_festival_interaction(player_token)
		or try_use_waystone(player_token)
		or try_harvest_garden(player_token)
		or try_cook_hearth_stew(player_token)
		or try_deliver_fresh_moonroot(player_token)
		or try_deliver_hearth_stew(player_token)
		or try_take_pantry_provision(player_token)
		or interact_with_mara(player_token)
		or try_gather_resource(player_token)
		or try_repair_cottage(player_token)
		or try_light_welcome_lantern(player_token)
	)


func try_rest_at_cottage(player_token: String) -> bool:
	if quest_stage != "home_repaired":
		return false
	if register_player(player_token).distance_to(COTTAGE_REST_POSITION) > INTERACTION_RADIUS:
		return false
	if bool(downed_players.get(player_token, false)):
		return false
	if int(player_health.get(player_token, PLAYER_MAX_HEALTH)) >= PLAYER_MAX_HEALTH:
		return false
	player_health[player_token] = PLAYER_MAX_HEALTH
	return true


func attack_creature(player_token: String) -> bool:
	register_player(player_token)
	if bool(downed_players.get(player_token, false)):
		return false
	if (
		exploration_stage in ["defeat_guardian", "restore_waystone"]
		and not ruin_guardian_defeated
		and positions[player_token].distance_to(ruin_guardian_position) <= 2.0
	):
		ruin_guardian_health -= 1
		if ruin_guardian_health <= 0:
			ruin_guardian_health = 0
			ruin_guardian_defeated = true
			exploration_stage = "restore_waystone"
		return true
	if creature_defeated:
		return false
	if positions[player_token].distance_to(creature_position) > 2.0:
		return false
	creature_health -= 1
	if creature_health <= 0:
		creature_health = 0
		creature_defeated = true
	return true


func simulate_creature(delta: float, active_tokens: Array) -> bool:
	var changed := _simulate_forest_creature(delta, active_tokens)
	if _simulate_ruin_guardian(delta, active_tokens):
		changed = true
	return changed


func simulate_world_clock(delta: float) -> bool:
	if delta <= 0.0:
		return false
	var previous_day := world_day
	var previous_checkpoint := floori(float(world_minute) / float(WORLD_SAVE_INTERVAL_MINUTES))
	var previous_activity := mara_activity
	world_clock_fraction += delta * WORLD_MINUTES_PER_REAL_SECOND
	var elapsed_minutes := floori(world_clock_fraction)
	if elapsed_minutes <= 0:
		return false
	world_clock_fraction -= elapsed_minutes
	_advance_world_minutes(elapsed_minutes)
	return (
		world_day != previous_day
		or floori(float(world_minute) / float(WORLD_SAVE_INTERVAL_MINUTES)) != previous_checkpoint
		or mara_activity != previous_activity
	)


func _advance_world_minutes(elapsed_minutes: int) -> void:
	if elapsed_minutes <= 0:
		return
	var previous_day := world_day
	var total_minutes := (
		(world_day - 1) * WORLD_MINUTES_PER_DAY
		+ world_minute
		+ elapsed_minutes
	)
	world_day = floori(float(total_minutes) / float(WORLD_MINUTES_PER_DAY)) + 1
	world_minute = posmod(total_minutes, WORLD_MINUTES_PER_DAY)
	if world_day > previous_day and livelihood_stage == "complete" and produce_stall_open:
		_begin_daily_food_order()
	_update_mara_routine()


func _begin_daily_food_order() -> void:
	if daily_food_order_day == world_day:
		return
	daily_food_order_day = world_day
	daily_food_order_active = true
	daily_food_order_kind = recommended_daily_food_order_kind()
	daily_food_deliveries = 0
	for plot_id: String in harvested_garden_plots:
		harvested_garden_plots[plot_id] = false


func has_active_food_order() -> bool:
	return livelihood_stage == "food_need" or daily_food_order_active


func daily_food_order_required() -> int:
	if daily_food_order_kind == DAILY_ORDER_FRESH_MOONROOT:
		return DAILY_FRESH_MOONROOT_DELIVERIES
	return REQUIRED_STEW_DELIVERIES


func daily_food_order_label() -> String:
	if daily_food_order_kind == DAILY_ORDER_FRESH_MOONROOT:
		return "Fresh moonroot"
	return "Hearth stew"


func recommended_daily_food_order_kind() -> String:
	match world_weather():
		"clear":
			return DAILY_ORDER_FRESH_MOONROOT
		"gentle_rain":
			return DAILY_ORDER_HEARTH_STEW
		_:
			return DAILY_ORDER_FRESH_MOONROOT if world_day % 2 == 0 else DAILY_ORDER_HEARTH_STEW


func daily_food_order_reason() -> String:
	if (
		daily_food_order_active
		and not daily_food_order_kind.is_empty()
		and daily_food_order_kind != recommended_daily_food_order_kind()
	):
		return "Existing request continues safely"
	match world_weather():
		"clear":
			return "Clear skies favor fresh harvests"
		"gentle_rain":
			return "Gentle rain calls for warming stew"
		_:
			return "Overcast market rotation"


func world_time_period() -> String:
	if world_minute >= 6 * 60 and world_minute < 12 * 60:
		return "Morning"
	if world_minute >= 12 * 60 and world_minute < 18 * 60:
		return "Afternoon"
	if world_minute >= 18 * 60 and world_minute < 22 * 60:
		return "Evening"
	return "Night"


func world_weather() -> String:
	var forecast_roll := posmod(REGION_SEED + world_day * 37, 10)
	if forecast_roll <= 5:
		return "clear"
	if forecast_roll <= 8:
		return "overcast"
	return "gentle_rain"


func world_weather_label() -> String:
	return str(WEATHER_LABELS.get(world_weather(), "Clear skies"))


func _update_mara_routine() -> void:
	if neighborhood_event_stage == "lighting":
		mara_position = MARA_WELCOME_POSITION
		mara_activity = "hosting Welcome Lights"
		return
	if neighborhood_event_stage != "complete":
		mara_position = MARA_POSITION
		mara_activity = "waiting by the cottage"
		return
	match world_time_period():
		"Morning":
			mara_position = MARA_POSITION
			mara_activity = "tending the cottage"
		"Afternoon":
			if produce_stall_open:
				mara_position = MARA_MARKET_POSITION
				mara_activity = "helping at the market"
			else:
				mara_position = MARA_WELCOME_POSITION
				mara_activity = "meeting neighbors"
		"Evening":
			mara_position = MARA_WELCOME_POSITION
			mara_activity = "at the gathering place"
		_:
			mara_position = MARA_POSITION
			mara_activity = "resting at the cottage"


func _simulate_forest_creature(delta: float, active_tokens: Array) -> bool:
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


func _simulate_ruin_guardian(delta: float, active_tokens: Array) -> bool:
	if ruin_guardian_defeated or exploration_stage != "defeat_guardian":
		return false
	ruin_guardian_attack_cooldown = maxf(ruin_guardian_attack_cooldown - delta, 0.0)
	var target_token := ""
	var target_distance := INF
	for player_token: String in active_tokens:
		register_player(player_token)
		if bool(downed_players.get(player_token, false)):
			continue
		var distance := ruin_guardian_position.distance_to(positions[player_token])
		if distance < target_distance:
			target_distance = distance
			target_token = player_token
	if target_token.is_empty() or target_distance > 7.0:
		return false
	var target_position: Vector3 = positions[target_token]
	if target_distance > 1.3:
		var direction := (target_position - ruin_guardian_position).normalized()
		ruin_guardian_position += direction * minf(1.8 * delta, target_distance - 1.1)
		ruin_guardian_position.y = RUIN_GUARDIAN_SPAWN.y
		return false
	if ruin_guardian_attack_cooldown > 0.0:
		return false
	ruin_guardian_attack_cooldown = 1.1
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


func try_return_to_safety(player_token: String) -> bool:
	register_player(player_token)
	if not bool(downed_players.get(player_token, false)):
		return false
	_drop_recovery_pack(player_token)
	downed_players[player_token] = false
	player_health[player_token] = PLAYER_MAX_HEALTH
	positions[player_token] = SPAWN_POINT
	return true


func mark_world_empty(now_unix: int) -> void:
	last_world_empty_unix = maxi(now_unix, 0)
	last_catch_up_units = 0


func apply_offline_catch_up(now_unix: int) -> int:
	last_catch_up_units = 0
	if last_world_empty_unix <= 0:
		return 0
	var elapsed_seconds := maxi(now_unix - last_world_empty_unix, 0)
	last_world_empty_unix = 0
	_advance_world_minutes(mini(elapsed_seconds, OFFLINE_CALENDAR_MAX_MINUTES))
	if livelihood_stage != "complete" or not produce_stall_open:
		return 0
	var available_space := PANTRY_MAX_STOCK - pantry_stock
	if available_space <= 0:
		return 0
	last_catch_up_units = mini(
		floori(float(elapsed_seconds) / float(PANTRY_CATCH_UP_INTERVAL_SECONDS)),
		available_space
	)
	pantry_stock += last_catch_up_units
	return last_catch_up_units


func try_take_pantry_provision(player_token: String) -> bool:
	if livelihood_stage != "complete" or not produce_stall_open or pantry_stock <= 0:
		return false
	if register_player(player_token).distance_to(MARKET_CRATE_POSITION) > INTERACTION_RADIUS:
		return false
	pantry_stock -= 1
	player_provisions[player_token] = int(player_provisions.get(player_token, 0)) + 1
	return true


func try_use_trail_provision(player_token: String) -> bool:
	register_player(player_token)
	if bool(downed_players.get(player_token, false)):
		return false
	var health := int(player_health.get(player_token, PLAYER_MAX_HEALTH))
	if health >= PLAYER_MAX_HEALTH or int(player_provisions.get(player_token, 0)) <= 0:
		return false
	player_provisions[player_token] = int(player_provisions.get(player_token, 0)) - 1
	player_health[player_token] = mini(health + 1, PLAYER_MAX_HEALTH)
	return true


func try_recover_pack(helper_token: String) -> bool:
	var helper_position := register_player(helper_token)
	for owner_token: String in recovery_packs.keys():
		var pack: Dictionary = recovery_packs[owner_token]
		var pack_position: Vector3 = pack.get("position", Vector3.INF)
		if helper_position.distance_to(pack_position) > INTERACTION_RADIUS:
			continue
		register_player(owner_token)
		player_provisions[owner_token] = (
			int(player_provisions.get(owner_token, 0)) + int(pack.get("count", 0))
		)
		recovery_packs.erase(owner_token)
		return true
	return false


func _drop_recovery_pack(player_token: String) -> void:
	var carried := int(player_provisions.get(player_token, 0))
	if carried <= 0:
		return
	var previous_count := 0
	if recovery_packs.has(player_token):
		previous_count = int(recovery_packs[player_token].get("count", 0))
	recovery_packs[player_token] = {
		"owner": player_token,
		"count": previous_count + carried,
		"position": positions[player_token],
	}
	player_provisions[player_token] = 0


func try_use_waystone(player_token: String) -> bool:
	register_player(player_token)
	if bool(downed_players.get(player_token, false)) or not ruin_guardian_defeated:
		return false
	var player_position: Vector3 = positions[player_token]
	if player_position.distance_to(RUIN_WAYSTONE_POSITION) <= INTERACTION_RADIUS:
		if not ruin_waystone_activated:
			ruin_waystone_activated = true
			exploration_stage = "complete"
			livelihood_stage = "food_need"
			reputation += 1
			chronicle.append("The group found the Old Stone Ruins and restored its ancient waystone route.")
		else:
			positions[player_token] = HOME_WAYSTONE_ARRIVAL
		return true
	if (
		ruin_waystone_activated
		and player_position.distance_to(HOME_WAYSTONE_POSITION) <= INTERACTION_RADIUS
	):
		positions[player_token] = RUIN_WAYSTONE_ARRIVAL
		return true
	return false


func try_harvest_garden(player_token: String) -> bool:
	if not has_active_food_order():
		return false
	var player_position: Vector3 = register_player(player_token)
	var target_plot := ""
	for plot_id: String in GARDEN_PLOT_POSITIONS:
		if bool(harvested_garden_plots.get(plot_id, false)):
			continue
		if player_position.distance_to(GARDEN_PLOT_POSITIONS[plot_id]) <= INTERACTION_RADIUS:
			target_plot = plot_id
			break
	if target_plot.is_empty():
		return false
	var harvested_count := 1
	harvested_garden_plots[target_plot] = true
	if _mastery_level(player_token, "farming") >= FARMING_TIER_TWO_MASTERY:
		for adjacent_plot: String in GARDEN_PLOT_POSITIONS:
			if bool(harvested_garden_plots.get(adjacent_plot, false)):
				continue
			if GARDEN_PLOT_POSITIONS[target_plot].distance_to(GARDEN_PLOT_POSITIONS[adjacent_plot]) <= 3.1:
				harvested_garden_plots[adjacent_plot] = true
				harvested_count += 1
				break
	materials["moonroot"] = int(materials.get("moonroot", 0)) + harvested_count
	_add_mastery(player_token, "farming", harvested_count)
	return true


func try_cook_hearth_stew(player_token: String) -> bool:
	if not has_active_food_order():
		return false
	if daily_food_order_active and daily_food_order_kind != DAILY_ORDER_HEARTH_STEW:
		return false
	if register_player(player_token).distance_to(COOKFIRE_POSITION) > INTERACTION_RADIUS:
		return false
	if int(materials.get("moonroot", 0)) < 2:
		return false
	var delivered_count := daily_food_deliveries if daily_food_order_active else stews_delivered
	var remaining_capacity := REQUIRED_STEW_DELIVERIES - int(materials.get("hearth_stew", 0)) - delivered_count
	if remaining_capacity <= 0:
		return false
	var cook_count := 1
	if _mastery_level(player_token, "cooking") >= COOKING_TIER_TWO_MASTERY:
		cook_count = mini(remaining_capacity, floori(float(materials.get("moonroot", 0)) / 2.0))
	materials["moonroot"] = int(materials.get("moonroot", 0)) - 2 * cook_count
	materials["hearth_stew"] = int(materials.get("hearth_stew", 0)) + cook_count
	_add_mastery(player_token, "cooking", cook_count)
	return true


func try_deliver_hearth_stew(player_token: String) -> bool:
	if not has_active_food_order():
		return false
	if daily_food_order_active and daily_food_order_kind != DAILY_ORDER_HEARTH_STEW:
		return false
	if register_player(player_token).distance_to(MARKET_CRATE_POSITION) > INTERACTION_RADIUS:
		return false
	if int(materials.get("hearth_stew", 0)) < 1:
		return false
	var remaining_deliveries := (
		REQUIRED_STEW_DELIVERIES - daily_food_deliveries
		if daily_food_order_active
		else REQUIRED_STEW_DELIVERIES - stews_delivered
	)
	var delivery_count := 1
	if _mastery_level(player_token, "trade") >= TRADE_TIER_TWO_MASTERY:
		delivery_count = mini(int(materials.get("hearth_stew", 0)), remaining_deliveries)
	materials["hearth_stew"] = int(materials.get("hearth_stew", 0)) - delivery_count
	_add_mastery(player_token, "trade", delivery_count)
	if daily_food_order_active:
		daily_food_deliveries += delivery_count
		if daily_food_deliveries >= REQUIRED_STEW_DELIVERIES:
			_complete_daily_food_order()
	else:
		stews_delivered += delivery_count
		if stews_delivered >= REQUIRED_STEW_DELIVERIES:
			livelihood_stage = "complete"
			produce_stall_open = true
			festival_stage = "available"
			neighborhood_morale += 1
			reputation += 1
			chronicle.append("The newcomers grew, cooked, and traded enough food to open the neighborhood produce stall.")
			_update_mara_routine()
	return true


func try_deliver_fresh_moonroot(player_token: String) -> bool:
	if not daily_food_order_active or daily_food_order_kind != DAILY_ORDER_FRESH_MOONROOT:
		return false
	if register_player(player_token).distance_to(MARKET_CRATE_POSITION) > INTERACTION_RADIUS:
		return false
	if int(materials.get("moonroot", 0)) < 1:
		return false
	var delivery_count := 1
	if _mastery_level(player_token, "trade") >= TRADE_TIER_TWO_MASTERY:
		delivery_count = mini(
			int(materials.get("moonroot", 0)),
			DAILY_FRESH_MOONROOT_DELIVERIES - daily_food_deliveries
		)
	materials["moonroot"] = int(materials.get("moonroot", 0)) - delivery_count
	daily_food_deliveries += delivery_count
	_add_mastery(player_token, "trade", delivery_count)
	if daily_food_deliveries >= DAILY_FRESH_MOONROOT_DELIVERIES:
		_complete_daily_food_order()
	return true


func _complete_daily_food_order() -> void:
	daily_food_order_active = false
	pantry_stock = mini(pantry_stock + 1, PANTRY_MAX_STOCK)


func try_festival_interaction(player_token: String) -> bool:
	if livelihood_stage != "complete" or not produce_stall_open or festival_stage == "locked":
		return false
	var player_position := register_player(player_token)
	if festival_stage in ["available", "results"]:
		if player_position.distance_to(FESTIVAL_ARCH_POSITION) > INTERACTION_RADIUS:
			return false
		festival_stage = "signup"
		festival_participants = {player_token: 0}
		festival_finishers.clear()
		festival_last_winner = ""
		return true
	if festival_stage == "signup":
		if player_position.distance_to(FESTIVAL_ARCH_POSITION) > INTERACTION_RADIUS:
			return false
		if festival_participants.has(player_token):
			festival_stage = "racing"
		else:
			festival_participants[player_token] = 0
		return true
	if festival_stage != "racing" or not festival_participants.has(player_token):
		return false
	var progress := int(festival_participants[player_token])
	if progress >= FESTIVAL_CHECKPOINT_ORDER.size():
		return false
	var checkpoint_id: String = FESTIVAL_CHECKPOINT_ORDER[progress]
	if player_position.distance_to(FESTIVAL_CHECKPOINT_POSITIONS[checkpoint_id]) > INTERACTION_RADIUS:
		return false
	progress += 1
	festival_participants[player_token] = progress
	if progress == FESTIVAL_CHECKPOINT_ORDER.size():
		festival_finishers.append(player_token)
		festival_ribbons[player_token] = int(festival_ribbons.get(player_token, 0)) + 1
		if festival_last_winner.is_empty():
			festival_last_winner = player_token
			if not festival_completed:
				festival_completed = true
				neighborhood_morale += 1
				reputation += 1
				chronicle.append("The neighborhood gathered for the first Hearthlight Circuit and made the festival its own.")
		if festival_finishers.size() >= festival_participants.size():
			festival_stage = "results"
	return true


func remove_festival_participant(player_token: String) -> bool:
	if not festival_participants.has(player_token):
		return false
	festival_participants.erase(player_token)
	festival_finishers.erase(player_token)
	if festival_participants.is_empty():
		festival_stage = "available"
	elif festival_stage == "racing" and festival_finishers.size() >= festival_participants.size():
		festival_stage = "results"
	return true


func _mastery_level(player_token: String, track: String) -> int:
	register_player(player_token)
	return int(player_mastery[player_token].get(track, 0))


func _add_mastery(player_token: String, track: String, amount: int = 1) -> void:
	register_player(player_token)
	var mastery: Dictionary = player_mastery[player_token]
	mastery[track] = int(mastery.get(track, 0)) + maxi(amount, 0)
	player_mastery[player_token] = mastery


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
	var encoded_recovery_packs := {}
	for owner_token: String in recovery_packs:
		var pack: Dictionary = recovery_packs[owner_token]
		var pack_position: Vector3 = pack.get("position", SPAWN_POINT)
		encoded_recovery_packs[owner_token] = {
			"owner": owner_token,
			"count": int(pack.get("count", 0)),
			"position": [pack_position.x, pack_position.y, pack_position.z],
		}
	return {
		"version": 11,
		"world_seed": REGION_SEED,
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
		"shared_map_discoveries": shared_map_discoveries.duplicate(),
		"exploration_stage": exploration_stage,
		"ruin_guardian_position": [ruin_guardian_position.x, ruin_guardian_position.y, ruin_guardian_position.z],
		"ruin_guardian_health": ruin_guardian_health,
		"ruin_guardian_defeated": ruin_guardian_defeated,
		"ruin_waystone_activated": ruin_waystone_activated,
		"livelihood_stage": livelihood_stage,
		"harvested_garden_plots": harvested_garden_plots.duplicate(),
		"stews_delivered": stews_delivered,
		"produce_stall_open": produce_stall_open,
		"daily_food_order_active": daily_food_order_active,
		"daily_food_order_day": daily_food_order_day,
		"daily_food_order_kind": daily_food_order_kind,
		"daily_food_deliveries": daily_food_deliveries,
		"player_mastery": player_mastery.duplicate(true),
		"pantry_stock": pantry_stock,
		"last_world_empty_unix": last_world_empty_unix,
		"player_provisions": player_provisions.duplicate(),
		"recovery_packs": encoded_recovery_packs,
		"festival_completed": festival_completed,
		"festival_ribbons": festival_ribbons.duplicate(),
		"festival_last_winner": festival_last_winner,
		"world_day": world_day,
		"world_minute": world_minute,
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
		"moonroot": int(saved_materials.get("moonroot", 0)),
		"hearth_stew": int(saved_materials.get("hearth_stew", 0)),
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
	if save_version >= 5:
		var saved_discoveries: Dictionary = data.get("shared_map_discoveries", {})
		shared_map_discoveries = {
			"northwood": bool(saved_discoveries.get("northwood", false)),
			"old_stone_ruins": bool(saved_discoveries.get("old_stone_ruins", false)),
		}
		exploration_stage = str(data.get("exploration_stage", "locked"))
		var encoded_guardian: Array = data.get("ruin_guardian_position", [])
		if encoded_guardian.size() == 3:
			ruin_guardian_position = Vector3(
				float(encoded_guardian[0]), float(encoded_guardian[1]), float(encoded_guardian[2])
			)
		else:
			ruin_guardian_position = RUIN_GUARDIAN_SPAWN
		ruin_guardian_health = int(data.get("ruin_guardian_health", RUIN_GUARDIAN_MAX_HEALTH))
		ruin_guardian_defeated = bool(data.get("ruin_guardian_defeated", false))
		ruin_waystone_activated = bool(data.get("ruin_waystone_activated", false))
	else:
		shared_map_discoveries = {"northwood": false, "old_stone_ruins": false}
		exploration_stage = "follow_rumor" if neighborhood_event_stage == "complete" else "locked"
		ruin_guardian_position = RUIN_GUARDIAN_SPAWN
		ruin_guardian_health = RUIN_GUARDIAN_MAX_HEALTH
		ruin_guardian_defeated = false
		ruin_waystone_activated = false
	if save_version >= 6:
		livelihood_stage = str(data.get("livelihood_stage", "locked"))
		var saved_garden: Dictionary = data.get("harvested_garden_plots", {})
		harvested_garden_plots = {
			"moonroot_1": bool(saved_garden.get("moonroot_1", false)),
			"moonroot_2": bool(saved_garden.get("moonroot_2", false)),
			"moonroot_3": bool(saved_garden.get("moonroot_3", false)),
			"moonroot_4": bool(saved_garden.get("moonroot_4", false)),
		}
		stews_delivered = int(data.get("stews_delivered", 0))
		produce_stall_open = bool(data.get("produce_stall_open", false))
		player_mastery = data.get("player_mastery", {}).duplicate(true)
	else:
		livelihood_stage = "food_need" if ruin_waystone_activated else "locked"
		harvested_garden_plots = {
			"moonroot_1": false,
			"moonroot_2": false,
			"moonroot_3": false,
			"moonroot_4": false,
		}
		stews_delivered = 0
		produce_stall_open = false
		player_mastery = {}
	if save_version >= 7:
		pantry_stock = clampi(int(data.get("pantry_stock", 0)), 0, PANTRY_MAX_STOCK)
		last_world_empty_unix = maxi(int(data.get("last_world_empty_unix", 0)), 0)
		player_provisions = data.get("player_provisions", {}).duplicate()
		recovery_packs = {}
		var saved_recovery_packs: Dictionary = data.get("recovery_packs", {})
		for owner_token: String in saved_recovery_packs:
			var saved_pack: Dictionary = saved_recovery_packs[owner_token]
			var encoded_pack_position: Array = saved_pack.get("position", [])
			if encoded_pack_position.size() != 3 or int(saved_pack.get("count", 0)) <= 0:
				continue
			recovery_packs[owner_token] = {
				"owner": owner_token,
				"count": int(saved_pack.get("count", 0)),
				"position": Vector3(
					float(encoded_pack_position[0]),
					float(encoded_pack_position[1]),
					float(encoded_pack_position[2])
				),
			}
	else:
		pantry_stock = 0
		last_world_empty_unix = 0
		player_provisions = {}
		recovery_packs = {}
	if save_version >= 8:
		festival_completed = bool(data.get("festival_completed", false))
		festival_ribbons = data.get("festival_ribbons", {}).duplicate()
		festival_last_winner = str(data.get("festival_last_winner", ""))
	else:
		festival_completed = false
		festival_ribbons = {}
		festival_last_winner = ""
	if save_version >= 9:
		world_day = maxi(int(data.get("world_day", 1)), 1)
		world_minute = clampi(int(data.get("world_minute", WORLD_START_MINUTE)), 0, WORLD_MINUTES_PER_DAY - 1)
	else:
		world_day = 1
		world_minute = WORLD_START_MINUTE
	if save_version >= 11:
		daily_food_order_active = bool(data.get("daily_food_order_active", false))
		daily_food_order_day = clampi(int(data.get("daily_food_order_day", 0)), 0, world_day)
		daily_food_order_kind = str(data.get("daily_food_order_kind", ""))
		if daily_food_order_kind not in [DAILY_ORDER_FRESH_MOONROOT, DAILY_ORDER_HEARTH_STEW]:
			daily_food_order_kind = DAILY_ORDER_HEARTH_STEW if daily_food_order_active else ""
		daily_food_deliveries = clampi(
			int(data.get("daily_food_deliveries", 0)), 0, daily_food_order_required()
		)
	elif save_version >= 10:
		daily_food_order_active = bool(data.get("daily_food_order_active", false))
		daily_food_order_day = clampi(int(data.get("daily_food_order_day", 0)), 0, world_day)
		daily_food_order_kind = DAILY_ORDER_HEARTH_STEW if daily_food_order_active else ""
		daily_food_deliveries = clampi(stews_delivered, 0, REQUIRED_STEW_DELIVERIES) if daily_food_order_active else 0
		if livelihood_stage == "complete":
			stews_delivered = REQUIRED_STEW_DELIVERIES
	else:
		daily_food_order_active = false
		daily_food_order_day = 0
		daily_food_order_kind = ""
		daily_food_deliveries = 0
	world_clock_fraction = 0.0
	# Active festival runs are intentionally ephemeral so a restart cannot strand entrants.
	festival_stage = "available" if livelihood_stage == "complete" and produce_stall_open else "locked"
	festival_participants = {}
	festival_finishers = []
	_update_mara_routine()
	positions.clear()
	var encoded_positions: Dictionary = data.get("positions", {})
	for player_token: String in encoded_positions:
		var encoded: Array = encoded_positions[player_token]
		if encoded.size() == 3:
			positions[player_token] = Vector3(float(encoded[0]), float(encoded[1]), float(encoded[2]))
