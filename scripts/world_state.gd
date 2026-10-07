class_name WorldState
extends RefCounted

const ActivityCatalog = preload("res://scripts/activity_catalog.gd")
const Wilderness = preload("res://scripts/wilderness_layout.gd")
const Structures = preload("res://scripts/structure_layout.gd")
const Sparring = preload("res://scripts/sparring_rules.gd")

const SPAWN_POINT := Vector3(0.0, 0.6, 10.0)
const COTTAGE_REST_POSITION := Vector3(-10.0, 0.6, 3.8)
const CHRONICLE_BOARD_POSITION := Vector3(-13.0, 0.6, 3.5)
const MARA_POSITION := Vector3(-4.0, 0.6, 4.0)
const MARA_WELCOME_POSITION := Vector3(4.0, 0.6, 4.0)
const MARA_MARKET_POSITION := Vector3(7.0, 0.6, 4.0)
const NIMA_ARRIVAL_POSITION := Vector3(11.5, 0.6, 9.5)
const NIMA_FIELD_CASE_POSITION := Vector3(13.0, 0.6, -25.0)
const NIMA_MAP_TABLE_POSITION := Vector3(-10.0, 0.6, 12.0)
const NIMA_WAYSTONE_POSITION := Vector3(10.5, 0.6, 8.5)
const NIMA_GATHERING_POSITION := Vector3(6.5, 0.6, 5.5)
const NIMA_COTTAGE_POSITION := Vector3(-6.0, 0.6, 4.0)
const MOONWELL_CENTER := Vector3(-12.0, 0.6, -42.0)
const MOONWELL_REVEAL_RADIUS := 5.0
const MOONSTONE_POSITIONS := {
	"bough": Vector3(-12.0, 0.6, -45.0),
	"brook": Vector3(-9.2, 0.6, -41.5),
	"path": Vector3(-14.6, 0.6, -40.5),
}
const MOONWELL_SUPPER_POSITION := Vector3(-8.5, 0.6, -38.5)
const MOONWELL_SUPPER_REQUIRED_COURSES := 3
const GEAR_RACK_POSITION := Vector3(-10.0, 0.6, 7.2)
const TRAILWORK_BENCH_POSITION := Vector3(-14.8, 0.6, 7.0)
const HOMESTEAD_LANTERN_POSITIONS := {
	"west_garden": Vector3(-16.0, 0.6, 11.5),
	"east_garden": Vector3(-4.0, 0.6, 11.5),
	"pond_path": Vector3(-16.0, 0.6, -0.5),
}
const COLLECTIBLE_POSITION := Vector3(0.0, 0.5, -6.5)
const PICKUP_RADIUS := 1.15
const INTERACTION_RADIUS := 1.8
const WORLD_MIN_X := -17.0
const WORLD_MAX_X := 17.0
const WORLD_MIN_Z := -74.0
const WORLD_MAX_Z := 24.0
const REEDBANK_MAX_X := 43.0
const OREN_TRAIL_POSITION := Vector3(21.0, 0.6, -23.0)
const OREN_MILL_POSITION := Vector3(31.0, 0.6, -27.0)
const REEDBANK_SAIL_POSITION := Vector3(37.0, 0.6, -41.0)
const REEDBANK_REPAIR_POSITION := Vector3(34.0, 0.6, -30.0)
const REEDBANK_REST_POSITION := Vector3(30.0, 0.6, -33.0)
const SUNWHEAT_BEDS := {
	"south": Vector3(23, 0.6, -34),
	"middle": Vector3(23, 0.6, -38),
	"north": Vector3(23, 0.6, -42),
}
const SUNWHEAT_GROW_MINUTES := 120
const MILL_HOPPER_POSITION := Vector3(37, 0.6, -33)
const REEDBANK_OVEN_POSITION := Vector3(29, 0.6, -38)
const BRIARWATCH_ENTRANCE := Vector3(0, 0.6, -52)
const BRIARWATCH_BEACON := Vector3(0, 0.6, -66)
const BRIARWATCH_BINDINGS := {
	"west": Vector3(-8, 0.6, -59),
	"east": Vector3(8, 0.6, -59),
	"north": Vector3(0, 0.6, -71),
}
const BRIARWATCH_WARNING_SECONDS := 1.2
const BRIARWATCH_PULSE_RADIUS := 2.4
const FURNISHING_ORIGIN := Structures.ORIGIN
const FURNISHING_COLUMNS := Structures.COLUMNS
const FURNISHING_ROWS := Structures.ROWS
const FURNISHING_SPACING := Structures.SPACING
const FURNISHING_REACH := 4.5
const FURNISHING_WOOD_COST := 2
const DECORATIVE_KINDS := ["bench", "flower_box", "watch_lantern", "gathering_table"]
const CROP_BEDS := {"moonroot_bed": {"crop": "moonroot", "yield": 1}, "sunwheat_bed": {"crop": "sunwheat", "yield": 2}}
const HOMESTEAD_GROW_MINUTES := 120
const UTILITY_KINDS := ["bedroll", "trailwork_bench", "moonroot_bed", "sunwheat_bed", "cookhearth", "grain_mill", "bread_oven"]
const FURNISHING_KINDS := DECORATIVE_KINDS + UTILITY_KINDS
const BUILDING_KINDS := DECORATIVE_KINDS + Structures.KINDS + UTILITY_KINDS
const FURNISHING_NAMES := {"bench": "Bench", "flower_box": "Flower box", "watch_lantern": "Watch lantern", "gathering_table": "Gathering table", "bedroll": "Bedroll", "trailwork_bench": "Trailwork bench", "moonroot_bed": "Moonroot bed", "sunwheat_bed": "Sunwheat bed", "cookhearth": "Cookhearth", "grain_mill": "Grain mill", "bread_oven": "Bread oven"}
const REGION_SEED := 73021
const MAX_WORLD_SEED := 2147483647
const NORTHWOOD_REVEAL_Z := -16.0
const RUINS_POSITION := Vector3(0.0, 0.6, -40.0)
const RUINS_REVEAL_RADIUS := 7.0
const DAILY_SURVEY_POSITIONS := [
	Vector3(-10.0, 0.6, -24.0),
	Vector3(10.0, 0.6, -29.0),
	Vector3(-7.0, 0.6, -37.0),
]
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
const FISHING_POND_CENTER := Vector3(-13.8, 0.0, -5.5)
const FISHING_SPOT_POSITION := Vector3(-13.8, 0.6, -3.0)
const FISHING_WAIT_SECONDS := 1.5
const FISHING_BITE_SECONDS := 1.0
const MARKET_CRATE_POSITION := Vector3(5.5, 0.6, 3.5)
const RIVERFISH_CREEL_POSITION := Vector3(-3.5, 0.6, 5.0)
const RIVERFISH_CREEL_CAPACITY := 8
const MARA_KEEPSAKE_RAPPORT := 3
const SUPPLY_BASKET_POSITION := Vector3(11.0, 0.6, 3.5)
const TRAIL_PROVISION_PRICE := 2
const SUPPLY_BASKET_DAILY_STOCK := 3
const HEARTHBLOOM_POSITION := Vector3(-14.8, 0.6, 3.0)
const HEARTHBLOOM_REQUIRED_COINS := 4
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
const PLAYER_ATTACK_RECOVERY_SECONDS := 0.45
const PLAYER_POWER_STRIKE_RECOVERY_SECONDS := 1.1
const PLAYER_BRACE_WINDOW_SECONDS := 0.7
const PLAYER_BRACE_COOLDOWN_SECONDS := 1.6
const GUARDIAN_ATTACK_RECOVERY_PENALTY_SECONDS := 0.2
const GUARDIAN_BRACE_WINDOW_SECONDS := 1.0
const GUARDIAN_BRACE_COOLDOWN_SECONDS := 1.25
const GUARDIAN_INTERCEPT_RADIUS := 2.0
const GUARDIAN_INTERCEPT_FEEDBACK_SECONDS := 1.2
const OUTING_KIT_VANGUARD := "vanguard"
const OUTING_KIT_GUARDIAN := "guardian"
const ENEMY_ATTACK_WINDUP_SECONDS := 0.6
const CREATURE_AGGRO_RADIUS := 6.0
const CREATURE_LEASH_RADIUS := 8.0
const CREATURE_RETURN_SPEED := 2.2
const RUIN_GUARDIAN_AGGRO_RADIUS := 7.0
const RUIN_GUARDIAN_LEASH_RADIUS := 9.0
const RUIN_GUARDIAN_RETURN_SPEED := 2.5
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
var materials := {"wood": 0, "herb": 0, "repair_kit": 0, "moonroot": 0, "hearth_stew": 0, "sunwheat": 0, "flour": 0}
var gathered_resources: Dictionary = {}
var repaired_parts := {"door": false, "wall": false, "garden": false}
var player_health: Dictionary = {}
var downed_players: Dictionary = {}
var player_attack_recovery: Dictionary = {}
var player_brace_time: Dictionary = {}
var player_brace_cooldown: Dictionary = {}
var guardian_intercept_player := ""
var guardian_intercept_target := ""
var guardian_intercept_time := 0.0
var creature_position := CREATURE_SPAWN
var creature_health := CREATURE_MAX_HEALTH
var creature_defeated := false
var creature_attack_cooldown := 0.0
var creature_attack_windup := 0.0
var creature_attack_target := ""
var creature_returning := false
var reputation := 0
var map_rumor_unlocked := false
var mara_position := MARA_POSITION
var nima_story_stage := "locked"
var nima_position := NIMA_ARRIVAL_POSITION
var nima_activity := "traveling beyond Northwood"
var moonwell_story_stage := "locked"
var attuned_moonstones := {"bough": false, "brook": false, "path": false}
var moonwell_supper_stage := "locked"
var moonwell_supper_courses := 0
var furnishings: Dictionary = {}
var structures: Dictionary = {}
var wilderness_plots: Dictionary = {}
var sparring := Sparring.new()
var reedbank_stage := "meet_oren"
var sunwheat_planted_at: Dictionary = {}
var homestead_planted_at: Dictionary = {}
var player_activity_pins: Dictionary = {}
var wilderness_discoveries: Dictionary = {}
var wilderness_forage_days: Dictionary = {}
var outpost_parts: Dictionary = {}
var player_wilderness_caches: Dictionary = {}
var briarwatch_stage := "rumor"
var broken_briarwatch_bindings: Dictionary = {}
var briarwatch_windup := 0.0
var briarwatch_cooldown := 3.0
var briarwatch_pulse_positions: Array[Vector3] = []
var briarwatch_target_cursor := 0
var world_seed := REGION_SEED
var neighborhood_event_stage := "locked"
var lit_welcome_lanterns := {"cottage": false, "road": false, "forest": false}
var neighborhood_morale := 0
var chronicle: Array = []
var player_chronicle_read_count: Dictionary = {}
var shared_map_discoveries := {
	"northwood": false,
	"old_stone_ruins": false,
	"moonwell_glade": false,
}
var exploration_stage := "locked"
var ruin_guardian_position := RUIN_GUARDIAN_SPAWN
var ruin_guardian_health := RUIN_GUARDIAN_MAX_HEALTH
var ruin_guardian_defeated := false
var ruin_guardian_attack_cooldown := 0.0
var ruin_guardian_attack_windup := 0.0
var ruin_guardian_attack_target := ""
var ruin_guardian_returning := false
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
var player_relationships: Dictionary = {}
var player_npc_check_in_day: Dictionary = {}
var player_mara_keepsakes: Dictionary = {}
var player_survey_day: Dictionary = {}
var player_outing_kits: Dictionary = {}
var built_homestead_lanterns := {
	"west_garden": false,
	"east_garden": false,
	"pond_path": false,
}
var pantry_stock := 0
var last_world_empty_unix := 0
var last_catch_up_units := 0
var player_provisions: Dictionary = {}
var player_riverfish: Dictionary = {}
var player_fishing_phase: Dictionary = {}
var player_fishing_time: Dictionary = {}
var player_coins: Dictionary = {}
var shared_riverfish_stock := 0
var supply_basket_stock := 0
var recovery_packs: Dictionary = {}
var hearthbloom_contributions := 0
var hearthbloom_complete := false
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
	if not player_activity_pins.has(player_token):
		player_activity_pins[player_token] = "automatic"
	if not positions.has(player_token):
		positions[player_token] = SPAWN_POINT
	if not player_health.has(player_token):
		player_health[player_token] = PLAYER_MAX_HEALTH
	if not downed_players.has(player_token):
		downed_players[player_token] = false
	if not player_attack_recovery.has(player_token):
		player_attack_recovery[player_token] = 0.0
	if not player_brace_time.has(player_token):
		player_brace_time[player_token] = 0.0
	if not player_brace_cooldown.has(player_token):
		player_brace_cooldown[player_token] = 0.0
	if not player_mastery.has(player_token):
		player_mastery[player_token] = {
			"farming": 0,
			"cooking": 0,
			"trade": 0,
			"fishing": 0,
			"building": 0,
			"combat": 0,
			"exploration": 0,
		}
	else:
		var mastery: Dictionary = player_mastery[player_token]
		for track: String in ["farming", "cooking", "trade", "fishing", "building", "combat", "exploration"]:
			if not mastery.has(track):
				mastery[track] = 0
		player_mastery[player_token] = mastery
	if not player_relationships.has(player_token):
		player_relationships[player_token] = {"mara": 0, "nima": 0}
	else:
		var relationships: Dictionary = player_relationships[player_token]
		if not relationships.has("mara"):
			relationships["mara"] = 0
		if not relationships.has("nima"):
			relationships["nima"] = 0
		player_relationships[player_token] = relationships
	if not player_npc_check_in_day.has(player_token):
		player_npc_check_in_day[player_token] = {"mara": 0}
	else:
		var check_in_days: Dictionary = player_npc_check_in_day[player_token]
		if not check_in_days.has("mara"):
			check_in_days["mara"] = 0
		player_npc_check_in_day[player_token] = check_in_days
	if not player_mara_keepsakes.has(player_token):
		player_mara_keepsakes[player_token] = (
			int(player_relationships[player_token].get("mara", 0)) >= MARA_KEEPSAKE_RAPPORT
		)
	if not player_survey_day.has(player_token):
		player_survey_day[player_token] = 0
	player_chronicle_read_count[player_token] = clampi(
		int(player_chronicle_read_count.get(player_token, 0)), 0, chronicle.size()
	)
	if str(player_outing_kits.get(player_token, "")) not in [OUTING_KIT_VANGUARD, OUTING_KIT_GUARDIAN]:
		player_outing_kits[player_token] = OUTING_KIT_VANGUARD
	if not player_provisions.has(player_token):
		player_provisions[player_token] = 0
	if not player_riverfish.has(player_token):
		player_riverfish[player_token] = 0
	if not player_fishing_phase.has(player_token):
		player_fishing_phase[player_token] = "idle"
	if not player_fishing_time.has(player_token):
		player_fishing_time[player_token] = 0.0
	if not player_coins.has(player_token):
		player_coins[player_token] = 0
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
	next_position.x = clampf(next_position.x, Wilderness.ORIGIN.x, REEDBANK_MAX_X)
	next_position.z = clampf(next_position.z, WORLD_MIN_Z, WORLD_MAX_Z)
	if next_position.x < WORLD_MIN_X and next_position.z > 22.0:
		if positions[player_token].x < WORLD_MIN_X:
			next_position.z = 22.0
		else:
			next_position.x = WORLD_MIN_X
	# Reedbank is an eastern branch, not an expansion of the empty southern edge.
	if next_position.x > WORLD_MAX_X and next_position.z > -18.0:
		if register_player(player_token).x > WORLD_MAX_X:
			next_position.z = -18.0
		else:
			next_position.x = WORLD_MAX_X
	if next_position.x > WORLD_MAX_X and next_position.z < -48.0:
		if register_player(player_token).x > WORLD_MAX_X:
			next_position.z = -48.0
		else:
			next_position.x = WORLD_MAX_X
	next_position = Structures.constrain_movement(structures, positions[player_token], next_position)
	for plot_id: String in wilderness_plots:
		var shift := Wilderness.plot_origin(world_seed, Structures.cell_for(plot_id)) - FURNISHING_ORIGIN
		next_position = Structures.constrain_movement(wilderness_plots[plot_id]["structures"], positions[player_token] - shift, next_position - shift) + shift
	positions[player_token] = next_position
	return next_position


func update_exploration(player_token: String) -> bool:
	if not positions.has(player_token):
		return false
	var changed := false
	var player_position: Vector3 = positions[player_token]
	var wilderness_cell := Wilderness.cell_at(player_position)
	if Wilderness.valid(wilderness_cell) and not bool(downed_players.get(player_token, false)):
		var section_id := Wilderness.key(wilderness_cell)
		if not wilderness_discoveries.has(section_id):
			wilderness_discoveries[section_id] = true
			_add_mastery(player_token, "exploration")
			changed = true
	if exploration_stage != "locked" and player_position.x >= WORLD_MIN_X and player_position.z <= NORTHWOOD_REVEAL_Z and not bool(shared_map_discoveries["northwood"]):
		shared_map_discoveries["northwood"] = true
		exploration_stage = "find_ruins"
		_add_mastery(player_token, "exploration")
		changed = true
	if (
		exploration_stage != "locked"
		and
		player_position.distance_to(RUINS_POSITION) <= RUINS_REVEAL_RADIUS
		and not bool(shared_map_discoveries["old_stone_ruins"])
	):
		shared_map_discoveries["old_stone_ruins"] = true
		exploration_stage = "defeat_guardian"
		_add_mastery(player_token, "exploration")
		changed = true
	if (
		moonwell_story_stage == "find_glade"
		and player_position.distance_to(MOONWELL_CENTER) <= MOONWELL_REVEAL_RADIUS
	):
		shared_map_discoveries["moonwell_glade"] = true
		moonwell_story_stage = "attune_stones"
		_add_mastery(player_token, "exploration")
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
			_add_npc_rapport(player_token, "mara")
			return true
		"return_to_mara":
			quest_stage = "repair_cottage"
			_add_npc_rapport(player_token, "mara")
			return true
		"home_repaired":
			if neighborhood_event_stage == "invitation":
				neighborhood_event_stage = "lighting"
				mara_position = MARA_WELCOME_POSITION
				_add_npc_rapport(player_token, "mara")
				return true
			if neighborhood_event_stage == "complete":
				var check_in_days: Dictionary = player_npc_check_in_day[player_token]
				if int(check_in_days.get("mara", 0)) >= world_day:
					return false
				check_in_days["mara"] = world_day
				player_npc_check_in_day[player_token] = check_in_days
				_add_npc_rapport(player_token, "mara")
				return true
	return false


func interact_with_nima(player_token: String) -> bool:
	if nima_story_stage not in ["arrival", "return_case"]:
		return false
	if register_player(player_token).distance_to(nima_position) > INTERACTION_RADIUS:
		return false
	if bool(downed_players.get(player_token, false)):
		return false
	_add_npc_rapport(player_token, "nima")
	if nima_story_stage == "arrival":
		nima_story_stage = "find_case"
		nima_activity = "waiting for news of her field case"
	else:
		nima_story_stage = "complete"
		if moonwell_story_stage == "locked":
			moonwell_story_stage = "map_clue"
		neighborhood_morale += 1
		reputation += 1
		chronicle.append("Nima recovered her Northwood charts and made a map table beside the homestead.")
		_update_nima_routine()
	return true


func try_reveal_moonwell_from_map(player_token: String) -> bool:
	if moonwell_story_stage != "map_clue" or nima_story_stage != "complete":
		return false
	if register_player(player_token).distance_to(NIMA_MAP_TABLE_POSITION) > INTERACTION_RADIUS:
		return false
	if bool(downed_players.get(player_token, false)):
		return false
	moonwell_story_stage = "find_glade"
	return true


func try_attune_moonstone(player_token: String) -> bool:
	if moonwell_story_stage != "attune_stones":
		return false
	var player_position := register_player(player_token)
	if bool(downed_players.get(player_token, false)):
		return false
	for stone_id: String in MOONSTONE_POSITIONS:
		if bool(attuned_moonstones.get(stone_id, false)):
			continue
		if player_position.distance_to(MOONSTONE_POSITIONS[stone_id]) > INTERACTION_RADIUS:
			continue
		attuned_moonstones[stone_id] = true
		_add_mastery(player_token, "exploration")
		if _all_moonstones_attuned():
			moonwell_story_stage = "complete"
			neighborhood_morale += 1
			reputation += 1
			chronicle.append("The newcomers woke Moonwell Glade and made its luminous spring a shared sanctuary.")
			_refresh_moonwell_supper_stage()
		return true
	return false


static func furnishing_cell_valid(cell: Vector2i) -> bool:
	return cell.x >= 0 and cell.x < FURNISHING_COLUMNS and cell.y >= 0 and cell.y < FURNISHING_ROWS


static func furnishing_cell_key(cell: Vector2i) -> String:
	return "%d,%d" % [cell.x, cell.y]


static func furnishing_position(cell: Vector2i) -> Vector3:
	return FURNISHING_ORIGIN + Vector3(cell.x, 0.0, cell.y) * FURNISHING_SPACING


static func furnishing_requirement(kind: String, progress: Dictionary) -> String:
	if kind == "moonroot_bed" and not bool(progress.get("ruin_waystone_activated", false)):
		return "Restore the Old Stone Ruins waystone."
	if kind in ["sunwheat_bed", "grain_mill", "bread_oven"] and str(progress.get("reedbank_stage", "")) != "complete":
		return "Restore Oren's Reedbank mill."
	if kind == "watch_lantern" and str(progress.get("briarwatch_stage", "rumor")) != "complete":
		return "Rekindle the Briarwatch beacon."
	if kind == "gathering_table" and str(progress.get("moonwell_supper_stage", "locked")) != "complete":
		return "Complete the Moonwell Supper."
	return ""


func try_claim_plot(player_token: String) -> bool:
	if quest_stage != "home_repaired" or not positions.has(player_token) or bool(downed_players.get(player_token, false)):
		return false
	var cell := Wilderness.cell_at(positions[player_token])
	var plot_id := Wilderness.key(cell)
	if not Wilderness.valid(cell) or cell == Wilderness.outpost_cell(world_seed) or wilderness_plots.has(plot_id):
		return false
	if positions[player_token].distance_to(Wilderness.claim_post(world_seed, cell)) > INTERACTION_RADIUS or int(materials.get("wood", 0)) < 2:
		return false
	materials["wood"] -= 2
	wilderness_plots[plot_id] = {"furnishings": {}, "structures": {}}
	chronicle.append("The newcomers established a shared homestead in %s." % Wilderness.title(cell))
	return true


func try_change_furnishing(player_token: String, cell: Vector2i, kind: String, quarter_turns: int, remove: bool, active_tokens: Array = [], plot_id: String = "") -> bool:
	if quest_stage != "home_repaired" or not furnishing_cell_valid(cell):
		return false
	if not positions.has(player_token) or bool(downed_players.get(player_token, false)):
		return false
	if not plot_id.is_empty() and not wilderness_plots.has(plot_id):
		return false
	var shift := Vector3.ZERO if plot_id.is_empty() else Wilderness.plot_origin(world_seed, Structures.cell_for(plot_id)) - FURNISHING_ORIGIN
	var plot_structures: Dictionary = structures if plot_id.is_empty() else wilderness_plots[plot_id]["structures"]
	var plot_furnishings: Dictionary = furnishings if plot_id.is_empty() else wilderness_plots[plot_id]["furnishings"]
	if positions[player_token].distance_to(furnishing_position(cell) + shift) > FURNISHING_REACH:
		return false
	if kind in Structures.KINDS:
		var active_positions: Array = []
		for token: String in active_tokens:
			if positions.has(token):
				active_positions.append(positions[token] - shift)
		if active_positions.is_empty():
			active_positions.append(positions[player_token] - shift)
		if not Structures.change_error(plot_structures, cell, kind, quarter_turns, remove, active_positions).is_empty():
			return false
		var slot := Structures.key(cell, kind, quarter_turns)
		if remove:
			plot_structures.erase(slot)
			materials["wood"] = int(materials.get("wood", 0)) + FURNISHING_WOOD_COST
			return true
		if int(materials.get("wood", 0)) < FURNISHING_WOOD_COST:
			return false
		materials["wood"] -= FURNISHING_WOOD_COST
		plot_structures[slot] = {"kind": kind, "rotation": quarter_turns}
		return true
	var key := furnishing_cell_key(cell)
	if remove:
		if not plot_furnishings.has(key):
			return false
		plot_furnishings.erase(key)
		homestead_planted_at.erase(plot_id + "/" + key)
		materials["wood"] = int(materials.get("wood", 0)) + FURNISHING_WOOD_COST
		return true
	if kind not in FURNISHING_KINDS or quarter_turns < 0 or quarter_turns > 3:
		return false
	if not furnishing_requirement(kind, {"briarwatch_stage": briarwatch_stage, "moonwell_supper_stage": moonwell_supper_stage, "ruin_waystone_activated": ruin_waystone_activated, "reedbank_stage": reedbank_stage}).is_empty():
		return false
	if plot_furnishings.has(key) or int(materials.get("wood", 0)) < FURNISHING_WOOD_COST:
		return false
	materials["wood"] = int(materials.get("wood", 0)) - FURNISHING_WOOD_COST
	plot_furnishings[key] = {"kind": kind, "rotation": quarter_turns}
	return true


static func sanitize_furnishings(saved: Dictionary) -> Dictionary:
	var result: Dictionary = {}
	for x in range(FURNISHING_COLUMNS):
		for z in range(FURNISHING_ROWS):
			var key := furnishing_cell_key(Vector2i(x, z))
			var piece: Variant = saved.get(key, {})
			if not piece is Dictionary:
				continue
			var kind := str(piece.get("kind", ""))
			var turns := int(piece.get("rotation", -1))
			if kind in FURNISHING_KINDS and turns >= 0 and turns <= 3:
				result[key] = {"kind": kind, "rotation": turns}
	return result


static func furnishing_stations(progress: Dictionary) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	var plots: Dictionary = progress.get("wilderness_plots", {}).duplicate()
	plots[""] = {"furnishings": progress.get("furnishings", {}), "structures": progress.get("structures", {})}
	var plot_ids := plots.keys()
	plot_ids.sort()
	for plot_id: String in plot_ids:
		var shift := Vector3.ZERO if plot_id.is_empty() else Wilderness.plot_origin(int(progress.get("world_seed", REGION_SEED)), Structures.cell_for(plot_id)) - FURNISHING_ORIGIN
		var layout: Dictionary = plots[plot_id]["furnishings"]
		var supports: Dictionary = plots[plot_id]["structures"]
		var slots := layout.keys()
		slots.sort()
		for slot: String in slots:
			var kind := str(layout[slot]["kind"])
			if kind not in UTILITY_KINDS:
				continue
			var cell := Structures.cell_for(slot)
			var sheltered := supports.has(Structures.key(cell, "foundation", 0)) and supports.has(Structures.key(cell, "roof", 0))
			result.append({"id": plot_id + "/" + slot, "plot_id": plot_id, "kind": kind, "position": furnishing_position(cell) + shift + Vector3(0, 0.6, 0), "sheltered": sheltered, "text": ("Rest in sheltered bedroll" if sheltered else "Bedroll needs foundation and roof") if kind == "bedroll" else "Trailcraft · 1 wood + 1 herb"})
			match kind:
				"cookhearth":
					result.back()["text"] = "Cook requested stew (2 moonroot), else fish (1 provision)"
				"grain_mill":
					result.back()["text"] = "Mill 2 sunwheat into 1 flour"
				"bread_oven":
					result.back()["text"] = "Bake 1 flour + 1 herb into 2 provisions"
			if CROP_BEDS.has(kind):
				var station: Dictionary = result.back()
				var remaining := homestead_crop_remaining(progress, station["id"])
				var crop: String = CROP_BEDS[kind]["crop"]
				station["crop_phase"] = "empty" if remaining < 0 else ("ripe" if remaining == 0 else "growing")
				station["text"] = "Plant %s · reusable seeds" % crop if remaining < 0 else ("Harvest %d %s" % [CROP_BEDS[kind]["yield"], crop] if remaining == 0 else "%s growing · %d world min" % [crop.capitalize(), remaining])
	return result


static func homestead_crop_remaining(progress: Dictionary, bed_id: String) -> int:
	var plantings: Dictionary = progress.get("homestead_planted_at", {})
	if not plantings.has(bed_id):
		return -1
	var now := (int(progress.get("world_day", 1)) - 1) * WORLD_MINUTES_PER_DAY + int(progress.get("world_minute", 0))
	return maxi(0, int(plantings[bed_id]) + HOMESTEAD_GROW_MINUTES - now)


static func nearest_furnishing_station(progress: Dictionary, point: Vector3) -> Dictionary:
	var result: Dictionary = {}
	var distance := INTERACTION_RADIUS
	for station: Dictionary in furnishing_stations(progress):
		var candidate: float = point.distance_to(station["position"])
		if candidate <= distance and (result.is_empty() or candidate < distance):
			result = station
			distance = candidate
	return result


func try_use_furnishing(player_token: String) -> bool:
	if quest_stage != "home_repaired" or not positions.has(player_token) or bool(downed_players.get(player_token, false)):
		return false
	var station := nearest_furnishing_station({"world_seed": world_seed, "furnishings": furnishings, "structures": structures, "wilderness_plots": wilderness_plots, "homestead_planted_at": homestead_planted_at, "world_day": world_day, "world_minute": world_minute}, positions[player_token])
	if station.is_empty():
		return false
	match station["kind"]:
		"cookhearth":
			return try_cook_hearth_stew(player_token) or try_cook_riverfish(player_token)
		"grain_mill":
			return _mill_sunwheat()
		"bread_oven":
			return _bake_trail_bread(player_token)
	if CROP_BEDS.has(station["kind"]):
		if station["crop_phase"] == "empty":
			homestead_planted_at[station["id"]] = world_calendar_minutes()
			return true
		if station["crop_phase"] == "ripe":
			homestead_planted_at.erase(station["id"])
			var recipe: Dictionary = CROP_BEDS[station["kind"]]
			materials[recipe["crop"]] = int(materials.get(recipe["crop"], 0)) + int(recipe["yield"])
			_add_mastery(player_token, "farming")
			return true
		return false
	if station["kind"] == "bedroll":
		if not station["sheltered"] or int(player_health.get(player_token, PLAYER_MAX_HEALTH)) >= PLAYER_MAX_HEALTH:
			return false
		player_health[player_token] = PLAYER_MAX_HEALTH
		return true
	if int(materials.get("wood", 0)) < 1 or int(materials.get("herb", 0)) < 1:
		return false
	materials["wood"] -= 1
	materials["herb"] -= 1
	player_provisions[player_token] = int(player_provisions.get(player_token, 0)) + 1
	return true


func try_prepare_moonwell_supper(player_token: String) -> bool:
	if moonwell_supper_stage != "available":
		return false
	if register_player(player_token).distance_to(MOONWELL_SUPPER_POSITION) > INTERACTION_RADIUS:
		return false
	if bool(downed_players.get(player_token, false)) or int(materials.get("moonroot", 0)) < 1:
		return false
	var personal_fish := int(player_riverfish.get(player_token, 0))
	if personal_fish <= 0 and shared_riverfish_stock <= 0:
		return false
	materials["moonroot"] = int(materials.get("moonroot", 0)) - 1
	if personal_fish > 0:
		player_riverfish[player_token] = personal_fish - 1
	else:
		shared_riverfish_stock -= 1
	moonwell_supper_courses = mini(
		moonwell_supper_courses + 1, MOONWELL_SUPPER_REQUIRED_COURSES
	)
	_add_mastery(player_token, "cooking")
	if moonwell_supper_courses >= MOONWELL_SUPPER_REQUIRED_COURSES:
		moonwell_supper_stage = "complete"
		neighborhood_morale += 1
		reputation += 1
		chronicle.append("Farmers, anglers, and cooks shared a Moonwell Supper beneath the awakened spring.")
	return true


func _refresh_moonwell_supper_stage() -> void:
	if (
		moonwell_supper_stage == "locked"
		and moonwell_story_stage == "complete"
		and produce_stall_open
	):
		moonwell_supper_stage = "available"


func try_rest_at_moonwell(player_token: String) -> bool:
	if moonwell_story_stage != "complete":
		return false
	if register_player(player_token).distance_to(MOONWELL_CENTER) > INTERACTION_RADIUS:
		return false
	if bool(downed_players.get(player_token, false)):
		return false
	if int(player_health.get(player_token, PLAYER_MAX_HEALTH)) >= PLAYER_MAX_HEALTH:
		return false
	player_health[player_token] = PLAYER_MAX_HEALTH
	return true


func try_recover_nima_field_case(player_token: String) -> bool:
	if nima_story_stage != "find_case":
		return false
	if register_player(player_token).distance_to(NIMA_FIELD_CASE_POSITION) > INTERACTION_RADIUS:
		return false
	if bool(downed_players.get(player_token, false)):
		return false
	nima_story_stage = "return_case"
	nima_activity = "waiting to recover her Northwood charts"
	_add_mastery(player_token, "exploration")
	return true


func try_gather_resource(player_token: String) -> bool:
	if quest_stage == "meet_mara":
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


func craft(player_token: String) -> bool:
	if craft_repair_kit():
		return true
	return try_craft_trail_provision(player_token)


func try_craft_trail_provision(player_token: String) -> bool:
	if quest_stage != "home_repaired":
		return false
	if register_player(player_token).distance_to(TRAILWORK_BENCH_POSITION) > INTERACTION_RADIUS:
		return false
	if bool(downed_players.get(player_token, false)):
		return false
	if int(materials.get("wood", 0)) < 1 or int(materials.get("herb", 0)) < 1:
		return false
	materials["wood"] = int(materials["wood"]) - 1
	materials["herb"] = int(materials["herb"]) - 1
	player_provisions[player_token] = int(player_provisions.get(player_token, 0)) + 1
	return true


func try_build_homestead_lantern(player_token: String) -> bool:
	if quest_stage != "home_repaired":
		return false
	var player_position := register_player(player_token)
	if bool(downed_players.get(player_token, false)) or int(materials.get("wood", 0)) < 1:
		return false
	for socket_id: String in HOMESTEAD_LANTERN_POSITIONS:
		if bool(built_homestead_lanterns.get(socket_id, false)):
			continue
		if player_position.distance_to(HOMESTEAD_LANTERN_POSITIONS[socket_id]) <= INTERACTION_RADIUS:
			materials["wood"] = int(materials["wood"]) - 1
			built_homestead_lanterns[socket_id] = true
			_add_mastery(player_token, "building")
			return true
	return false


func unread_chronicle_count(player_token: String) -> int:
	return maxi(chronicle.size() - int(player_chronicle_read_count.get(player_token, 0)), 0)


func try_read_chronicle(player_token: String) -> bool:
	if quest_stage != "home_repaired" or chronicle.is_empty():
		return false
	if register_player(player_token).distance_to(CHRONICLE_BOARD_POSITION) > INTERACTION_RADIUS:
		return false
	if bool(downed_players.get(player_token, false)) or unread_chronicle_count(player_token) <= 0:
		return false
	player_chronicle_read_count[player_token] = chronicle.size()
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
			_add_mastery(player_token, "building")
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


func try_gather_wilderness(player_token: String) -> bool:
	if not positions.has(player_token) or bool(downed_players.get(player_token, false)):
		return false
	var point: Vector3 = positions[player_token]
	for source: Dictionary in Wilderness.forage_nodes(world_seed, Wilderness.cell_at(point)):
		if int(wilderness_forage_days.get(source["id"], 0)) >= world_day:
			continue
		if point.distance_to(source["position"]) <= INTERACTION_RADIUS:
			wilderness_forage_days[source["id"]] = world_day
			materials[source["kind"]] = int(materials.get(source["kind"], 0)) + 1
			return true
	return false


func try_outpost_interaction(player_token: String) -> bool:
	if not positions.has(player_token) or bool(downed_players.get(player_token, false)):
		return false
	var point: Vector3 = positions[player_token]
	if outpost_parts.size() == 3:
		if point.distance_to(Wilderness.outpost_station(world_seed, "rest")) <= INTERACTION_RADIUS:
			if int(player_health.get(player_token, PLAYER_MAX_HEALTH)) >= PLAYER_MAX_HEALTH:
				return false
			player_health[player_token] = PLAYER_MAX_HEALTH
			return true
		if point.distance_to(Wilderness.outpost_station(world_seed, "craft")) <= INTERACTION_RADIUS:
			if int(materials.get("wood", 0)) < 1 or int(materials.get("herb", 0)) < 1:
				return false
			materials["wood"] -= 1
			materials["herb"] -= 1
			player_provisions[player_token] = int(player_provisions.get(player_token, 0)) + 1
			return true
		return false
	for part: String in ["shelter", "remedies", "meal"]:
		if outpost_parts.has(part) or point.distance_to(Wilderness.outpost_station(world_seed, part)) > INTERACTION_RADIUS:
			continue
		match part:
			"shelter":
				if int(materials.get("wood", 0)) < 3:
					return false
				materials["wood"] -= 3
				_add_mastery(player_token, "building")
			"remedies":
				if int(materials.get("herb", 0)) < 2:
					return false
				materials["herb"] -= 2
			"meal":
				var personal := int(player_riverfish.get(player_token, 0))
				if personal + shared_riverfish_stock < 2:
					return false
				var used_personal := mini(personal, 2)
				player_riverfish[player_token] = personal - used_personal
				shared_riverfish_stock -= 2 - used_personal
				_add_mastery(player_token, "cooking", 2)
		outpost_parts[part] = true
		if outpost_parts.size() == 3:
			reputation += 1
			chronicle.append("The newcomers established Fartrail Outpost in %s, leaving shelter and a trailwork bench for every traveler." % Wilderness.title(Wilderness.outpost_cell(world_seed)))
		return true
	return false


func try_wilderness_cache(player_token: String) -> bool:
	if not positions.has(player_token) or bool(downed_players.get(player_token, false)):
		return false
	var cell := Wilderness.cell_at(positions[player_token])
	if not Wilderness.valid(cell):
		return false
	var section_id := Wilderness.key(cell)
	var claims: Dictionary = player_wilderness_caches.get(player_token, {})
	if claims.has(section_id) or positions[player_token].distance_to(Wilderness.cache_position(world_seed, cell)) > INTERACTION_RADIUS:
		return false
	claims[section_id] = true
	player_wilderness_caches[player_token] = claims
	player_provisions[player_token] = int(player_provisions.get(player_token, 0)) + 1
	return true


func try_briarwatch_interaction(player_token: String) -> bool:
	if not ruin_waystone_activated or bool(downed_players.get(player_token, false)):
		return false
	var player_position := register_player(player_token)
	if briarwatch_stage == "rumor":
		if player_position.distance_to(BRIARWATCH_ENTRANCE) > INTERACTION_RADIUS:
			return false
		briarwatch_stage = "bindings"
		briarwatch_cooldown = 3.0
		return true
	if briarwatch_stage == "bindings":
		for binding_id: String in BRIARWATCH_BINDINGS:
			if broken_briarwatch_bindings.has(binding_id):
				continue
			if player_position.distance_to(BRIARWATCH_BINDINGS[binding_id]) <= INTERACTION_RADIUS:
				broken_briarwatch_bindings[binding_id] = true
				_add_mastery(player_token, "exploration")
				if broken_briarwatch_bindings.size() == BRIARWATCH_BINDINGS.size():
					briarwatch_stage = "rekindle"
					briarwatch_windup = 0.0
					briarwatch_pulse_positions.clear()
				return true
		return false
	if player_position.distance_to(BRIARWATCH_BEACON) > INTERACTION_RADIUS:
		return false
	if briarwatch_stage == "rekindle":
		briarwatch_stage = "complete"
		reputation += 1
		neighborhood_morale += 1
		chronicle.append("The newcomers freed Briarwatch from its bound spirit and rekindled the watch beacon above Northwood.")
		return true
	if briarwatch_stage == "complete":
		positions[player_token] = HOME_WAYSTONE_ARRIVAL
		return true
	return false


func simulate_briarwatch(delta: float, active_tokens: Array) -> bool:
	if delta <= 0.0:
		return false
	var eligible: Array[String] = []
	for token: String in active_tokens:
		if not eligible.has(token) and positions.has(token) and not bool(downed_players.get(token, false)):
			var point: Vector3 = positions[token]
			if absf(point.x) <= 12.0 and point.z <= -55.0 and point.z >= WORLD_MIN_Z:
				eligible.append(token)
	eligible.sort()
	if not ruin_waystone_activated or briarwatch_stage != "bindings" or eligible.is_empty():
		briarwatch_windup = 0.0
		briarwatch_pulse_positions.clear()
		briarwatch_cooldown = 3.0
		return false
	if briarwatch_windup > 0.0:
		briarwatch_windup = maxf(0.0, briarwatch_windup - delta)
		if briarwatch_windup > 0.0:
			return false
		briarwatch_cooldown = 3.0
		var struck := false
		for token: String in eligible:
			for mark: Vector3 in briarwatch_pulse_positions:
				if (positions[token] as Vector3).distance_to(mark) <= BRIARWATCH_PULSE_RADIUS:
					_apply_enemy_hit(token, eligible, mark)
					struck = true
					break # Overlapping circles are one threat per player per wave.
		briarwatch_pulse_positions.clear()
		return struck
	briarwatch_cooldown = maxf(0.0, briarwatch_cooldown - delta)
	if briarwatch_cooldown <= 0.0:
		var count := 1 if eligible.size() == 1 else (2 if eligible.size() <= 4 else 3)
		briarwatch_pulse_positions.clear()
		for index in range(count):
			var target: String = eligible[(briarwatch_target_cursor + index) % eligible.size()]
			briarwatch_pulse_positions.append(positions[target])
		briarwatch_target_cursor += count
		briarwatch_windup = BRIARWATCH_WARNING_SECONDS
	return false


func try_pin_activity(player_token: String, activity_id: String) -> bool:
	if not positions.has(player_token):
		return false
	if activity_id != "automatic" and ActivityCatalog.find_entry(to_dictionary(), activity_id).is_empty():
		return false
	if str(player_activity_pins.get(player_token, "automatic")) == activity_id:
		return false
	player_activity_pins[player_token] = activity_id
	return true


func world_calendar_minutes() -> int:
	return (world_day - 1) * WORLD_MINUTES_PER_DAY + world_minute


func sunwheat_minutes_remaining(bed_id: String) -> int:
	if not sunwheat_planted_at.has(bed_id):
		return -1
	return maxi(0, int(sunwheat_planted_at[bed_id]) + SUNWHEAT_GROW_MINUTES - world_calendar_minutes())


func try_reedbank_livelihood(player_token: String) -> bool:
	if reedbank_stage != "complete" or bool(downed_players.get(player_token, false)):
		return false
	var player_position := register_player(player_token)
	for bed_id: String in SUNWHEAT_BEDS:
		if player_position.distance_to(SUNWHEAT_BEDS[bed_id]) > INTERACTION_RADIUS:
			continue
		var remaining := sunwheat_minutes_remaining(bed_id)
		if remaining < 0:
			sunwheat_planted_at[bed_id] = world_calendar_minutes()
			return true
		if remaining == 0:
			sunwheat_planted_at.erase(bed_id)
			materials["sunwheat"] = int(materials.get("sunwheat", 0)) + 2
			_add_mastery(player_token, "farming")
			return true
		return false
	if player_position.distance_to(MILL_HOPPER_POSITION) <= INTERACTION_RADIUS:
		return _mill_sunwheat()
	if player_position.distance_to(REEDBANK_OVEN_POSITION) <= INTERACTION_RADIUS:
		return _bake_trail_bread(player_token)
	return false


func _mill_sunwheat() -> bool:
	if int(materials.get("sunwheat", 0)) < 2:
		return false
	materials["sunwheat"] -= 2
	materials["flour"] = int(materials.get("flour", 0)) + 1
	return true


func _bake_trail_bread(player_token: String) -> bool:
	if int(materials.get("flour", 0)) < 1 or int(materials.get("herb", 0)) < 1:
		return false
	materials["flour"] -= 1
	materials["herb"] -= 1
	player_provisions[player_token] = int(player_provisions.get(player_token, 0)) + 2
	_add_mastery(player_token, "cooking")
	return true


func try_reedbank_interaction(player_token: String) -> bool:
	if nima_story_stage != "complete" or bool(downed_players.get(player_token, false)):
		return false
	var player_position := register_player(player_token)
	match reedbank_stage:
		"meet_oren":
			if player_position.distance_to(OREN_TRAIL_POSITION) > INTERACTION_RADIUS:
				return false
			reedbank_stage = "recover_sail"
		"recover_sail":
			if player_position.distance_to(REEDBANK_SAIL_POSITION) > INTERACTION_RADIUS:
				return false
			reedbank_stage = "repair_mill"
			_add_mastery(player_token, "exploration")
		"repair_mill":
			if player_position.distance_to(REEDBANK_REPAIR_POSITION) > INTERACTION_RADIUS or int(materials.get("wood", 0)) < 2:
				return false
			materials["wood"] -= 2
			reedbank_stage = "return_oren"
			_add_mastery(player_token, "building")
		"return_oren":
			if player_position.distance_to(OREN_MILL_POSITION) > INTERACTION_RADIUS:
				return false
			reedbank_stage = "complete"
			reputation += 1
			neighborhood_morale += 1
			chronicle.append("Together, the newcomers repaired Oren's windmill and opened a travelers' rest in Reedbank Hollow.")
		"complete":
			if player_position.distance_to(REEDBANK_REST_POSITION) > INTERACTION_RADIUS or int(player_health.get(player_token, PLAYER_MAX_HEALTH)) >= PLAYER_MAX_HEALTH:
				return false
			player_health[player_token] = PLAYER_MAX_HEALTH
		_:
			return false
	return true


func interact(player_token: String, active_tokens: Array = []) -> bool:
	return (
		try_revive_player(player_token, active_tokens)
		or try_aid_injured_friend(player_token, active_tokens)
		or try_return_to_safety(player_token)
		or try_recover_pack(player_token)
		or try_sparring_interaction(player_token, active_tokens)
		or try_use_furnishing(player_token)
		or try_outpost_interaction(player_token)
		or try_claim_plot(player_token)
		or try_wilderness_cache(player_token)
		or try_gather_wilderness(player_token)
		or try_briarwatch_interaction(player_token)
		or try_reedbank_interaction(player_token)
		or try_reedbank_livelihood(player_token)
		or try_rest_at_moonwell(player_token)
		or try_rest_at_cottage(player_token)
		or try_read_chronicle(player_token)
		or try_reveal_moonwell_from_map(player_token)
		or try_recover_nima_field_case(player_token)
		or interact_with_nima(player_token)
		or try_attune_moonstone(player_token)
		or try_prepare_moonwell_supper(player_token)
		or try_festival_interaction(player_token)
		or try_use_waystone(player_token)
		or try_record_trail_survey(player_token)
		or try_harvest_garden(player_token)
		or try_cook_hearth_stew(player_token)
		or try_cook_riverfish(player_token)
		or try_store_riverfish(player_token)
		or try_fishing_interaction(player_token)
		or try_deliver_fresh_moonroot(player_token)
		or try_deliver_hearth_stew(player_token)
		or try_take_pantry_provision(player_token)
		or try_buy_trail_provision(player_token)
		or try_contribute_hearthbloom(player_token)
		or try_build_homestead_lantern(player_token)
		or try_switch_outing_kit(player_token)
		or interact_with_mara(player_token)
		or try_gather_resource(player_token)
		or try_repair_cottage(player_token)
		or try_light_welcome_lantern(player_token)
		or try_give_trail_provision(player_token, active_tokens)
	)


func _all_moonstones_attuned() -> bool:
	for is_attuned: bool in attuned_moonstones.values():
		if not is_attuned:
			return false
	return true


func try_fishing_interaction(player_token: String) -> bool:
	if quest_stage != "home_repaired":
		return false
	if register_player(player_token).distance_to(FISHING_SPOT_POSITION) > INTERACTION_RADIUS:
		return false
	if bool(downed_players.get(player_token, false)):
		return false
	match str(player_fishing_phase.get(player_token, "idle")):
		"idle":
			player_fishing_phase[player_token] = "waiting"
			player_fishing_time[player_token] = FISHING_WAIT_SECONDS
		"waiting":
			# Reeling before the bite safely ends only this player's cast.
			reset_player_fishing(player_token)
		"bite":
			player_riverfish[player_token] = int(player_riverfish.get(player_token, 0)) + 1
			_add_mastery(player_token, "fishing")
			reset_player_fishing(player_token)
		_:
			reset_player_fishing(player_token)
	return true


func simulate_fishing(delta: float, active_tokens: Array) -> void:
	for player_token: String in active_tokens:
		register_player(player_token)
		var phase := str(player_fishing_phase.get(player_token, "idle"))
		if phase == "idle":
			continue
		var remaining := maxf(float(player_fishing_time.get(player_token, 0.0)) - delta, 0.0)
		player_fishing_time[player_token] = remaining
		if remaining > 0.0:
			continue
		if phase == "waiting":
			player_fishing_phase[player_token] = "bite"
			player_fishing_time[player_token] = FISHING_BITE_SECONDS
		else:
			# A missed bite is transient and never awards or removes inventory.
			reset_player_fishing(player_token)


func reset_player_fishing(player_token: String) -> void:
	player_fishing_phase[player_token] = "idle"
	player_fishing_time[player_token] = 0.0


func daily_survey_position() -> Vector3:
	var survey_index := posmod(world_seed + world_day * 17, DAILY_SURVEY_POSITIONS.size())
	return DAILY_SURVEY_POSITIONS[survey_index]


func try_record_trail_survey(player_token: String) -> bool:
	if not ruin_waystone_activated:
		return false
	if register_player(player_token).distance_to(daily_survey_position()) > INTERACTION_RADIUS:
		return false
	if bool(downed_players.get(player_token, false)):
		return false
	if int(player_survey_day.get(player_token, 0)) >= world_day:
		return false
	player_survey_day[player_token] = world_day
	_add_mastery(player_token, "exploration")
	return true


func try_cook_riverfish(player_token: String) -> bool:
	if quest_stage != "home_repaired":
		return false
	if not _at_cookhearth(player_token):
		return false
	if bool(downed_players.get(player_token, false)):
		return false
	var personal_fish := int(player_riverfish.get(player_token, 0))
	if personal_fish <= 0 and shared_riverfish_stock <= 0:
		return false
	if personal_fish > 0:
		player_riverfish[player_token] = personal_fish - 1
	else:
		shared_riverfish_stock -= 1
	player_provisions[player_token] = int(player_provisions.get(player_token, 0)) + 1
	_add_mastery(player_token, "cooking")
	return true


func try_store_riverfish(player_token: String) -> bool:
	if quest_stage != "home_repaired":
		return false
	if register_player(player_token).distance_to(RIVERFISH_CREEL_POSITION) > INTERACTION_RADIUS:
		return false
	if bool(downed_players.get(player_token, false)):
		return false
	if int(player_riverfish.get(player_token, 0)) <= 0:
		return false
	if shared_riverfish_stock >= RIVERFISH_CREEL_CAPACITY:
		return false
	player_riverfish[player_token] = int(player_riverfish[player_token]) - 1
	shared_riverfish_stock += 1
	return true


func try_aid_injured_friend(helper_token: String, active_tokens: Array = []) -> bool:
	var helper_position := register_player(helper_token)
	if bool(downed_players.get(helper_token, false)):
		return false
	if int(player_provisions.get(helper_token, 0)) <= 0:
		return false
	for target_token: String in positions:
		if target_token == helper_token or bool(downed_players.get(target_token, false)):
			continue
		if not active_tokens.is_empty() and target_token not in active_tokens:
			continue
		var target_health := int(player_health.get(target_token, PLAYER_MAX_HEALTH))
		if target_health >= PLAYER_MAX_HEALTH:
			continue
		if helper_position.distance_to(positions[target_token]) > INTERACTION_RADIUS:
			continue
		player_provisions[helper_token] = int(player_provisions[helper_token]) - 1
		player_health[target_token] = mini(target_health + 1, PLAYER_MAX_HEALTH)
		return true
	return false


func try_give_trail_provision(giver_token: String, active_tokens: Array) -> bool:
	var giver_position := register_player(giver_token)
	if bool(downed_players.get(giver_token, false)):
		return false
	if int(player_provisions.get(giver_token, 0)) <= 0:
		return false
	var ordered_tokens := active_tokens.duplicate()
	ordered_tokens.sort()
	var recipient_token := ""
	var recipient_distance := INF
	for candidate_token: String in ordered_tokens:
		if candidate_token == giver_token or not positions.has(candidate_token):
			continue
		if bool(downed_players.get(candidate_token, false)):
			continue
		if int(player_health.get(candidate_token, PLAYER_MAX_HEALTH)) < PLAYER_MAX_HEALTH:
			continue
		var distance := giver_position.distance_to(positions[candidate_token])
		if distance > INTERACTION_RADIUS or distance >= recipient_distance:
			continue
		recipient_token = candidate_token
		recipient_distance = distance
	if recipient_token.is_empty():
		return false
	player_provisions[giver_token] = int(player_provisions[giver_token]) - 1
	player_provisions[recipient_token] = int(player_provisions.get(recipient_token, 0)) + 1
	return true


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


func try_switch_outing_kit(player_token: String) -> bool:
	if quest_stage != "home_repaired":
		return false
	if register_player(player_token).distance_to(GEAR_RACK_POSITION) > INTERACTION_RADIUS:
		return false
	if bool(downed_players.get(player_token, false)):
		return false
	player_outing_kits[player_token] = (
		OUTING_KIT_GUARDIAN
		if str(player_outing_kits.get(player_token, OUTING_KIT_VANGUARD)) == OUTING_KIT_VANGUARD
		else OUTING_KIT_VANGUARD
	)
	return true


func outing_kit_label(player_token: String) -> String:
	register_player(player_token)
	return "Guardian" if player_outing_kits[player_token] == OUTING_KIT_GUARDIAN else "Vanguard"


func attack_creature(player_token: String) -> bool:
	return _damage_creature(player_token, 1, PLAYER_ATTACK_RECOVERY_SECONDS)


func power_strike_creature(player_token: String) -> bool:
	return _damage_creature(player_token, 2, PLAYER_POWER_STRIKE_RECOVERY_SECONDS)


func _damage_creature(player_token: String, damage: int, recovery_seconds: float) -> bool:
	register_player(player_token)
	if bool(downed_players.get(player_token, false)):
		return false
	if sparring.participants.has(player_token):
		return sparring.attack(player_token, positions, downed_players)
	if float(player_attack_recovery.get(player_token, 0.0)) > 0.0:
		return false
	if (
		exploration_stage in ["defeat_guardian", "restore_waystone"]
		and not ruin_guardian_defeated
		and positions[player_token].distance_to(ruin_guardian_position) <= 2.0
	):
		player_attack_recovery[player_token] = _recovery_for_outing_kit(player_token, recovery_seconds)
		ruin_guardian_health -= damage
		_add_mastery(player_token, "combat")
		if ruin_guardian_health <= 0:
			ruin_guardian_health = 0
			ruin_guardian_defeated = true
			ruin_guardian_attack_windup = 0.0
			ruin_guardian_attack_target = ""
			exploration_stage = "restore_waystone"
		return true
	if creature_defeated:
		return false
	if positions[player_token].distance_to(creature_position) > 2.0:
		return false
	player_attack_recovery[player_token] = _recovery_for_outing_kit(player_token, recovery_seconds)
	creature_health -= damage
	_add_mastery(player_token, "combat")
	if creature_health <= 0:
		creature_health = 0
		creature_defeated = true
		creature_attack_windup = 0.0
		creature_attack_target = ""
	return true


func try_brace(player_token: String) -> bool:
	register_player(player_token)
	if bool(downed_players.get(player_token, false)):
		return false
	if sparring.participants.has(player_token):
		return sparring.brace(player_token)
	if float(player_brace_time.get(player_token, 0.0)) > 0.0:
		return false
	if float(player_brace_cooldown.get(player_token, 0.0)) > 0.0:
		return false
	var uses_guardian_kit: bool = str(player_outing_kits[player_token]) == OUTING_KIT_GUARDIAN
	player_brace_time[player_token] = (
		GUARDIAN_BRACE_WINDOW_SECONDS if uses_guardian_kit else PLAYER_BRACE_WINDOW_SECONDS
	)
	player_brace_cooldown[player_token] = (
		GUARDIAN_BRACE_COOLDOWN_SECONDS if uses_guardian_kit else PLAYER_BRACE_COOLDOWN_SECONDS
	)
	return true


func _recovery_for_outing_kit(player_token: String, base_recovery: float) -> float:
	return base_recovery + (
		GUARDIAN_ATTACK_RECOVERY_PENALTY_SECONDS
		if player_outing_kits[player_token] == OUTING_KIT_GUARDIAN
		else 0.0
	)


func reset_player_combat_timers(player_token: String) -> void:
	register_player(player_token)
	player_attack_recovery[player_token] = 0.0
	player_brace_time[player_token] = 0.0
	player_brace_cooldown[player_token] = 0.0


func simulate_creature(delta: float, active_tokens: Array) -> bool:
	_update_player_combat_timers(delta, active_tokens)
	_update_guardian_intercept_feedback(delta)
	var changed := _simulate_forest_creature(delta, active_tokens)
	if _simulate_ruin_guardian(delta, active_tokens):
		changed = true
	return changed


func _update_player_combat_timers(delta: float, active_tokens: Array) -> void:
	for player_token: String in active_tokens:
		register_player(player_token)
		player_attack_recovery[player_token] = maxf(
			float(player_attack_recovery.get(player_token, 0.0)) - delta,
			0.0
		)
		player_brace_time[player_token] = maxf(
			float(player_brace_time.get(player_token, 0.0)) - delta,
			0.0
		)
		player_brace_cooldown[player_token] = maxf(
			float(player_brace_cooldown.get(player_token, 0.0)) - delta,
			0.0
		)


func _update_guardian_intercept_feedback(delta: float) -> void:
	guardian_intercept_time = maxf(guardian_intercept_time - delta, 0.0)
	if guardian_intercept_time <= 0.0:
		guardian_intercept_player = ""
		guardian_intercept_target = ""


func simulate_world_clock(delta: float) -> bool:
	if delta <= 0.0:
		return false
	var previous_day := world_day
	var previous_checkpoint := floori(float(world_minute) / float(WORLD_SAVE_INTERVAL_MINUTES))
	var previous_activity := mara_activity
	var previous_nima_activity := nima_activity
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
		or nima_activity != previous_nima_activity
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
	if world_day > previous_day:
		_renew_daily_forest_encounter()
		_renew_daily_forest_resources()
		if livelihood_stage == "complete" and produce_stall_open:
			supply_basket_stock = SUPPLY_BASKET_DAILY_STOCK
			_begin_daily_food_order()
	_update_mara_routine()
	_update_nima_routine()


func _renew_daily_forest_encounter() -> void:
	if not creature_defeated:
		return
	creature_defeated = false
	creature_position = CREATURE_SPAWN
	creature_health = CREATURE_MAX_HEALTH
	creature_attack_cooldown = 0.0
	creature_attack_windup = 0.0
	creature_attack_target = ""
	creature_returning = false


func _renew_daily_forest_resources() -> void:
	if quest_stage != "home_repaired":
		return
	for resource_id: String in RESOURCE_POSITIONS:
		gathered_resources[resource_id] = false


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
	var forecast_roll := posmod(world_seed + world_day * 37, 10)
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


func _update_nima_routine() -> void:
	if nima_story_stage == "locked":
		nima_position = NIMA_ARRIVAL_POSITION
		nima_activity = "traveling beyond Northwood"
		return
	if nima_story_stage != "complete":
		nima_position = NIMA_ARRIVAL_POSITION
		if nima_story_stage == "arrival":
			nima_activity = "newly arrived at the home waystone"
		elif nima_story_stage == "find_case":
			nima_activity = "waiting for news of her field case"
		else:
			nima_activity = "waiting to recover her Northwood charts"
		return
	match world_time_period():
		"Morning":
			nima_position = NIMA_MAP_TABLE_POSITION
			nima_activity = "mapping at the homestead"
		"Afternoon":
			nima_position = NIMA_WAYSTONE_POSITION
			nima_activity = "studying the home waystone"
		"Evening":
			nima_position = NIMA_GATHERING_POSITION
			nima_activity = "meeting neighbors"
		_:
			nima_position = NIMA_COTTAGE_POSITION
			nima_activity = "resting by the cottage"


func _simulate_forest_creature(delta: float, active_tokens: Array) -> bool:
	if creature_defeated:
		creature_attack_windup = 0.0
		creature_attack_target = ""
		creature_returning = false
		return false
	creature_attack_cooldown = maxf(creature_attack_cooldown - delta, 0.0)
	if creature_attack_windup > 0.0:
		if _enemy_target_is_eligible(
			creature_attack_target, active_tokens, CREATURE_SPAWN, CREATURE_LEASH_RADIUS
		):
			creature_attack_windup = maxf(creature_attack_windup - delta, 0.0)
			if creature_attack_windup > 0.0:
				return false
			var committed_target := creature_attack_target
			creature_attack_target = ""
			if not _enemy_target_in_strike_range(committed_target, active_tokens, creature_position, 1.15):
				return false
			creature_attack_cooldown = 1.0
			_apply_enemy_hit(committed_target, active_tokens, creature_position)
			return true
		creature_attack_windup = 0.0
		creature_attack_target = ""
	var target_token := ""
	var target_distance := INF
	for player_token: String in active_tokens:
		register_player(player_token)
		if not _enemy_target_is_eligible(
			player_token, active_tokens, CREATURE_SPAWN, CREATURE_LEASH_RADIUS
		):
			continue
		var distance := creature_position.distance_to(positions[player_token])
		if distance < target_distance:
			target_distance = distance
			target_token = player_token
	if target_token.is_empty() or target_distance > CREATURE_AGGRO_RADIUS:
		return _return_forest_creature_home(delta)
	creature_returning = false
	var target_position: Vector3 = positions[target_token]
	if target_distance > 1.15:
		var direction := (target_position - creature_position).normalized()
		creature_position += direction * minf(1.5 * delta, target_distance - 1.0)
		creature_position.y = CREATURE_SPAWN.y
		return false
	if creature_attack_cooldown > 0.0:
		return false
	creature_attack_windup = ENEMY_ATTACK_WINDUP_SECONDS
	creature_attack_target = target_token
	return false


func _simulate_ruin_guardian(delta: float, active_tokens: Array) -> bool:
	if ruin_guardian_defeated or exploration_stage != "defeat_guardian":
		ruin_guardian_attack_windup = 0.0
		ruin_guardian_attack_target = ""
		ruin_guardian_returning = false
		return false
	ruin_guardian_attack_cooldown = maxf(ruin_guardian_attack_cooldown - delta, 0.0)
	if ruin_guardian_attack_windup > 0.0:
		if _enemy_target_is_eligible(
			ruin_guardian_attack_target,
			active_tokens,
			RUIN_GUARDIAN_SPAWN,
			RUIN_GUARDIAN_LEASH_RADIUS
		):
			ruin_guardian_attack_windup = maxf(ruin_guardian_attack_windup - delta, 0.0)
			if ruin_guardian_attack_windup > 0.0:
				return false
			var committed_target := ruin_guardian_attack_target
			ruin_guardian_attack_target = ""
			if not _enemy_target_in_strike_range(committed_target, active_tokens, ruin_guardian_position, 1.3):
				return false
			ruin_guardian_attack_cooldown = 1.1
			_apply_enemy_hit(committed_target, active_tokens, ruin_guardian_position)
			return true
		ruin_guardian_attack_windup = 0.0
		ruin_guardian_attack_target = ""
	var target_token := ""
	var target_distance := INF
	for player_token: String in active_tokens:
		register_player(player_token)
		if not _enemy_target_is_eligible(
			player_token, active_tokens, RUIN_GUARDIAN_SPAWN, RUIN_GUARDIAN_LEASH_RADIUS
		):
			continue
		var distance := ruin_guardian_position.distance_to(positions[player_token])
		if distance < target_distance:
			target_distance = distance
			target_token = player_token
	if target_token.is_empty() or target_distance > RUIN_GUARDIAN_AGGRO_RADIUS:
		return _return_ruin_guardian_home(delta)
	ruin_guardian_returning = false
	var target_position: Vector3 = positions[target_token]
	if target_distance > 1.3:
		var direction := (target_position - ruin_guardian_position).normalized()
		ruin_guardian_position += direction * minf(1.8 * delta, target_distance - 1.1)
		ruin_guardian_position.y = RUIN_GUARDIAN_SPAWN.y
		return false
	if ruin_guardian_attack_cooldown > 0.0:
		return false
	ruin_guardian_attack_windup = ENEMY_ATTACK_WINDUP_SECONDS
	ruin_guardian_attack_target = target_token
	return false


func _return_forest_creature_home(delta: float) -> bool:
	creature_attack_windup = 0.0
	creature_attack_target = ""
	var distance_home := creature_position.distance_to(CREATURE_SPAWN)
	if distance_home > 0.05:
		creature_returning = true
		creature_position = creature_position.move_toward(
			CREATURE_SPAWN, CREATURE_RETURN_SPEED * delta
		)
		creature_position.y = CREATURE_SPAWN.y
		if creature_position.distance_to(CREATURE_SPAWN) > 0.05:
			return false
	var reset_changed := (
		creature_position != CREATURE_SPAWN
		or creature_health != CREATURE_MAX_HEALTH
		or creature_returning
	)
	creature_position = CREATURE_SPAWN
	creature_health = CREATURE_MAX_HEALTH
	creature_attack_cooldown = 0.0
	creature_returning = false
	return reset_changed


func _return_ruin_guardian_home(delta: float) -> bool:
	ruin_guardian_attack_windup = 0.0
	ruin_guardian_attack_target = ""
	var distance_home := ruin_guardian_position.distance_to(RUIN_GUARDIAN_SPAWN)
	if distance_home > 0.05:
		ruin_guardian_returning = true
		ruin_guardian_position = ruin_guardian_position.move_toward(
			RUIN_GUARDIAN_SPAWN, RUIN_GUARDIAN_RETURN_SPEED * delta
		)
		ruin_guardian_position.y = RUIN_GUARDIAN_SPAWN.y
		if ruin_guardian_position.distance_to(RUIN_GUARDIAN_SPAWN) > 0.05:
			return false
	var reset_changed := (
		ruin_guardian_position != RUIN_GUARDIAN_SPAWN
		or ruin_guardian_health != RUIN_GUARDIAN_MAX_HEALTH
		or ruin_guardian_returning
	)
	ruin_guardian_position = RUIN_GUARDIAN_SPAWN
	ruin_guardian_health = RUIN_GUARDIAN_MAX_HEALTH
	ruin_guardian_attack_cooldown = 0.0
	ruin_guardian_returning = false
	return reset_changed


func _enemy_target_is_eligible(
	player_token: String,
	active_tokens: Array,
	home_position: Vector3,
	leash_radius: float
) -> bool:
	return (
		not player_token.is_empty()
		and player_token in active_tokens
		and positions.has(player_token)
		and not bool(downed_players.get(player_token, false))
		and home_position.distance_to(positions[player_token]) <= leash_radius
	)


func _enemy_target_in_strike_range(
	player_token: String,
	active_tokens: Array,
	enemy_position: Vector3,
	strike_range: float
) -> bool:
	return (
		not player_token.is_empty()
		and player_token in active_tokens
		and positions.has(player_token)
		and not bool(downed_players.get(player_token, false))
		and enemy_position.distance_to(positions[player_token]) <= strike_range
	)


func _apply_enemy_hit(player_token: String, active_tokens: Array, enemy_position: Vector3) -> void:
	if float(player_brace_time.get(player_token, 0.0)) > 0.0:
		player_brace_time[player_token] = 0.0
		return
	var interceptor := _guardian_interceptor_for(player_token, active_tokens, enemy_position)
	if not interceptor.is_empty():
		player_brace_time[interceptor] = 0.0
		guardian_intercept_player = interceptor
		guardian_intercept_target = player_token
		guardian_intercept_time = GUARDIAN_INTERCEPT_FEEDBACK_SECONDS
		return
	player_health[player_token] = maxi(int(player_health[player_token]) - 1, 0)
	if int(player_health[player_token]) == 0:
		downed_players[player_token] = true
		player_brace_time[player_token] = 0.0


func _guardian_interceptor_for(
	target_token: String,
	active_tokens: Array,
	enemy_position: Vector3
) -> String:
	if not positions.has(target_token):
		return ""
	var target_position: Vector3 = positions[target_token]
	var ordered_tokens := active_tokens.duplicate()
	ordered_tokens.sort()
	var nearest_token := ""
	var nearest_distance := INF
	for candidate_token: String in ordered_tokens:
		if candidate_token == target_token:
			continue
		if not positions.has(candidate_token):
			continue
		if bool(downed_players.get(candidate_token, false)):
			continue
		if str(player_outing_kits.get(candidate_token, OUTING_KIT_VANGUARD)) != OUTING_KIT_GUARDIAN:
			continue
		if float(player_brace_time.get(candidate_token, 0.0)) <= 0.0:
			continue
		var candidate_position: Vector3 = positions[candidate_token]
		var target_distance := candidate_position.distance_to(target_position)
		if target_distance > GUARDIAN_INTERCEPT_RADIUS:
			continue
		if candidate_position.distance_to(enemy_position) > GUARDIAN_INTERCEPT_RADIUS:
			continue
		if target_distance < nearest_distance:
			nearest_distance = target_distance
			nearest_token = candidate_token
	return nearest_token


func try_revive_player(helper_token: String, active_tokens: Array = []) -> bool:
	register_player(helper_token)
	if bool(downed_players.get(helper_token, false)):
		return false
	for player_token: String in downed_players:
		if player_token == helper_token or not bool(downed_players[player_token]):
			continue
		if not active_tokens.is_empty() and player_token not in active_tokens:
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


func try_buy_trail_provision(player_token: String) -> bool:
	if livelihood_stage != "complete" or not produce_stall_open:
		return false
	if supply_basket_stock <= 0:
		return false
	if register_player(player_token).distance_to(SUPPLY_BASKET_POSITION) > INTERACTION_RADIUS:
		return false
	if int(player_coins.get(player_token, 0)) < TRAIL_PROVISION_PRICE:
		return false
	player_coins[player_token] = int(player_coins[player_token]) - TRAIL_PROVISION_PRICE
	player_provisions[player_token] = int(player_provisions.get(player_token, 0)) + 1
	supply_basket_stock -= 1
	return true


func try_contribute_hearthbloom(player_token: String) -> bool:
	if livelihood_stage != "complete" or not produce_stall_open or hearthbloom_complete:
		return false
	if register_player(player_token).distance_to(HEARTHBLOOM_POSITION) > INTERACTION_RADIUS:
		return false
	if int(player_coins.get(player_token, 0)) < 1:
		return false
	player_coins[player_token] = int(player_coins[player_token]) - 1
	hearthbloom_contributions = mini(hearthbloom_contributions + 1, HEARTHBLOOM_REQUIRED_COINS)
	if hearthbloom_contributions >= HEARTHBLOOM_REQUIRED_COINS:
		hearthbloom_complete = true
		neighborhood_morale += 1
		reputation += 1
		chronicle.append("The neighborhood pooled its earnings to bloom a Hearthbloom planter beside the cottage.")
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
			nima_story_stage = "arrival"
			reputation += 1
			chronicle.append("The group found the Old Stone Ruins and restored its ancient waystone route.")
			_update_nima_routine()
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
	if livelihood_stage not in ["food_need", "complete"]:
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
	if bool(downed_players.get(player_token, false)):
		return false
	if not has_active_food_order():
		return false
	if daily_food_order_active and daily_food_order_kind != DAILY_ORDER_HEARTH_STEW:
		return false
	if not _at_cookhearth(player_token):
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


func _at_cookhearth(player_token: String) -> bool:
	var point := register_player(player_token)
	if point.distance_to(COOKFIRE_POSITION) <= INTERACTION_RADIUS:
		return true
	if quest_stage != "home_repaired":
		return false
	var station := nearest_furnishing_station({"world_seed": world_seed, "furnishings": furnishings, "structures": structures, "wilderness_plots": wilderness_plots}, point)
	return station.get("kind", "") == "cookhearth"


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
	_add_coins(player_token, delivery_count)
	if daily_food_order_active:
		daily_food_deliveries += delivery_count
		if daily_food_deliveries >= REQUIRED_STEW_DELIVERIES:
			_complete_daily_food_order()
	else:
		stews_delivered += delivery_count
		if stews_delivered >= REQUIRED_STEW_DELIVERIES:
			livelihood_stage = "complete"
			produce_stall_open = true
			supply_basket_stock = SUPPLY_BASKET_DAILY_STOCK
			festival_stage = "available"
			neighborhood_morale += 1
			reputation += 1
			chronicle.append("The newcomers grew, cooked, and traded enough food to open the neighborhood produce stall.")
			_update_mara_routine()
			_refresh_moonwell_supper_stage()
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
	_add_coins(player_token, delivery_count)
	if daily_food_deliveries >= DAILY_FRESH_MOONROOT_DELIVERIES:
		_complete_daily_food_order()
	return true


func _complete_daily_food_order() -> void:
	daily_food_order_active = false
	pantry_stock = mini(pantry_stock + 1, PANTRY_MAX_STOCK)


func try_festival_interaction(player_token: String) -> bool:
	if sparring.participants.has(player_token):
		return false
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


func try_sparring_interaction(player_token: String, active_tokens: Array = []) -> bool:
	if festival_participants.has(player_token) and festival_stage in ["signup", "racing"]:
		return false
	if not active_tokens.is_empty():
		sparring.tick(0, positions, downed_players, active_tokens)
	return sparring.join(player_token, positions, downed_players, produce_stall_open)


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


func _add_npc_rapport(player_token: String, npc_id: String, amount: int = 1) -> void:
	register_player(player_token)
	var relationships: Dictionary = player_relationships[player_token]
	relationships[npc_id] = int(relationships.get(npc_id, 0)) + maxi(amount, 0)
	player_relationships[player_token] = relationships
	if npc_id == "mara" and int(relationships[npc_id]) >= MARA_KEEPSAKE_RAPPORT:
		player_mara_keepsakes[player_token] = true


func _add_coins(player_token: String, amount: int = 1) -> void:
	register_player(player_token)
	player_coins[player_token] = int(player_coins.get(player_token, 0)) + maxi(amount, 0)


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
		"version": 36,
		"homestead_planted_at": homestead_planted_at.duplicate(),
		"sparring": sparring.saved(),
		"wilderness_plots": wilderness_plots.duplicate(true),
		"structures": structures.duplicate(true),
		"wilderness_forage_days": wilderness_forage_days.duplicate(),
		"outpost_parts": outpost_parts.duplicate(),
		"wilderness_discoveries": wilderness_discoveries.duplicate(),
		"player_wilderness_caches": player_wilderness_caches.duplicate(true),
		"briarwatch_stage": briarwatch_stage,
		"broken_briarwatch_bindings": broken_briarwatch_bindings.duplicate(),
		"player_activity_pins": player_activity_pins.duplicate(),
		"sunwheat_planted_at": sunwheat_planted_at.duplicate(),
		"reedbank_stage": reedbank_stage,
		"furnishings": furnishings.duplicate(true),
		"world_seed": world_seed,
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
		"nima_story_stage": nima_story_stage,
		"moonwell_story_stage": moonwell_story_stage,
		"attuned_moonstones": attuned_moonstones.duplicate(),
		"moonwell_supper_stage": moonwell_supper_stage,
		"moonwell_supper_courses": moonwell_supper_courses,
		"neighborhood_event_stage": neighborhood_event_stage,
		"lit_welcome_lanterns": lit_welcome_lanterns.duplicate(),
		"neighborhood_morale": neighborhood_morale,
		"chronicle": chronicle.duplicate(),
		"player_chronicle_read_count": player_chronicle_read_count.duplicate(),
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
		"player_relationships": player_relationships.duplicate(true),
		"player_npc_check_in_day": player_npc_check_in_day.duplicate(true),
		"player_mara_keepsakes": player_mara_keepsakes.duplicate(),
		"player_survey_day": player_survey_day.duplicate(),
		"player_outing_kits": player_outing_kits.duplicate(),
		"built_homestead_lanterns": built_homestead_lanterns.duplicate(),
		"pantry_stock": pantry_stock,
		"last_world_empty_unix": last_world_empty_unix,
		"player_provisions": player_provisions.duplicate(),
		"player_riverfish": player_riverfish.duplicate(),
		"player_coins": player_coins.duplicate(),
		"shared_riverfish_stock": shared_riverfish_stock,
		"supply_basket_stock": supply_basket_stock,
		"recovery_packs": encoded_recovery_packs,
		"hearthbloom_contributions": hearthbloom_contributions,
		"hearthbloom_complete": hearthbloom_complete,
		"festival_completed": festival_completed,
		"festival_ribbons": festival_ribbons.duplicate(),
		"festival_last_winner": festival_last_winner,
		"world_day": world_day,
		"world_minute": world_minute,
		"positions": encoded_positions,
	}


func load_dictionary(data: Dictionary) -> void:
	world_seed = int(data.get("world_seed", REGION_SEED))
	if world_seed < 1 or world_seed > MAX_WORLD_SEED:
		world_seed = REGION_SEED
	collectible_collected = bool(data.get("collectible_collected", false))
	quest_stage = str(data.get("quest_stage", "return_to_mara" if collectible_collected else "meet_mara"))
	var saved_materials: Dictionary = data.get("materials", {})
	materials = {
		"wood": int(saved_materials.get("wood", 0)),
		"herb": int(saved_materials.get("herb", 0)),
		"repair_kit": int(saved_materials.get("repair_kit", 0)),
		"moonroot": int(saved_materials.get("moonroot", 0)),
		"hearth_stew": int(saved_materials.get("hearth_stew", 0)),
		"sunwheat": maxi(0, int(saved_materials.get("sunwheat", 0))) if int(data.get("version", 1)) >= 27 else 0,
		"flour": maxi(0, int(saved_materials.get("flour", 0))) if int(data.get("version", 1)) >= 27 else 0,
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
	sparring.load_saved(data.get("sparring", {}) if save_version >= 35 else {})
	structures = Structures.sanitize(data.get("structures", {})) if save_version >= 33 else {}
	wilderness_plots.clear()
	if save_version >= 34:
		var saved_plots: Dictionary = data.get("wilderness_plots", {})
		for x in range(Wilderness.COUNT):
			for z in range(Wilderness.COUNT):
				var cell := Vector2i(x, z)
				var plot_id := Wilderness.key(cell)
				if cell == Wilderness.outpost_cell(world_seed) or not saved_plots.get(plot_id) is Dictionary:
					continue
				wilderness_plots[plot_id] = {"structures": Structures.sanitize(saved_plots[plot_id].get("structures", {})), "furnishings": sanitize_furnishings(saved_plots[plot_id].get("furnishings", {}))}
	wilderness_forage_days.clear()
	if save_version >= 32:
		var saved_forage: Dictionary = data.get("wilderness_forage_days", {})
		for x in range(Wilderness.COUNT):
			for z in range(Wilderness.COUNT):
				for source: Dictionary in Wilderness.forage_nodes(world_seed, Vector2i(x, z)):
					if saved_forage.has(source["id"]):
						wilderness_forage_days[source["id"]] = clampi(int(saved_forage[source["id"]]), 0, maxi(int(data.get("world_day", 1)), 1))
	outpost_parts.clear()
	if save_version >= 31:
		var saved_outpost: Dictionary = data.get("outpost_parts", {})
		for part: String in ["shelter", "remedies", "meal"]:
			if bool(saved_outpost.get(part, false)):
				outpost_parts[part] = true
	wilderness_discoveries.clear()
	player_wilderness_caches.clear()
	if save_version >= 30:
		var saved_sections: Dictionary = data.get("wilderness_discoveries", {})
		var saved_claims: Dictionary = data.get("player_wilderness_caches", {})
		for x in range(Wilderness.COUNT):
			for z in range(Wilderness.COUNT):
				var section_id := Wilderness.key(Vector2i(x, z))
				if bool(saved_sections.get(section_id, false)):
					wilderness_discoveries[section_id] = true
				for token: String in saved_claims:
					if saved_claims[token] is Dictionary and bool(saved_claims[token].get(section_id, false)):
						if not player_wilderness_caches.has(token):
							player_wilderness_caches[token] = {}
						player_wilderness_caches[token][section_id] = true
	briarwatch_stage = str(data.get("briarwatch_stage", "rumor")) if save_version >= 29 else "rumor"
	if briarwatch_stage not in ["rumor", "bindings", "rekindle", "complete"]:
		briarwatch_stage = "rumor"
	broken_briarwatch_bindings.clear()
	if save_version >= 29:
		var saved_bindings: Dictionary = data.get("broken_briarwatch_bindings", {})
		for binding_id: String in BRIARWATCH_BINDINGS:
			if bool(saved_bindings.get(binding_id, false)) or briarwatch_stage in ["rekindle", "complete"]:
				broken_briarwatch_bindings[binding_id] = true
		if broken_briarwatch_bindings.size() == BRIARWATCH_BINDINGS.size() and briarwatch_stage == "bindings":
			briarwatch_stage = "rekindle"
	briarwatch_windup = 0.0
	briarwatch_cooldown = 3.0
	briarwatch_target_cursor = 0
	briarwatch_pulse_positions.clear()
	player_activity_pins.clear()
	if save_version >= 28:
		var saved_pins: Dictionary = data.get("player_activity_pins", {})
		for player_token: String in saved_pins:
			var activity_id := str(saved_pins[player_token])
			if activity_id in ActivityCatalog.IDS:
				player_activity_pins[player_token] = activity_id
	reedbank_stage = str(data.get("reedbank_stage", "meet_oren")) if save_version >= 26 else "meet_oren"
	if reedbank_stage not in ["meet_oren", "recover_sail", "repair_mill", "return_oren", "complete"]:
		reedbank_stage = "meet_oren"
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
			"moonwell_glade": bool(saved_discoveries.get("moonwell_glade", false)),
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
		shared_map_discoveries = {"northwood": false, "old_stone_ruins": false, "moonwell_glade": false}
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
	if save_version >= 22:
		nima_story_stage = str(data.get("nima_story_stage", "arrival" if ruin_waystone_activated else "locked"))
		if nima_story_stage not in ["locked", "arrival", "find_case", "return_case", "complete"]:
			nima_story_stage = "arrival" if ruin_waystone_activated else "locked"
	else:
		nima_story_stage = "arrival" if ruin_waystone_activated else "locked"
	if save_version >= 23:
		moonwell_story_stage = str(data.get("moonwell_story_stage", "map_clue" if nima_story_stage == "complete" else "locked"))
		if moonwell_story_stage not in ["locked", "map_clue", "find_glade", "attune_stones", "complete"]:
			moonwell_story_stage = "map_clue" if nima_story_stage == "complete" else "locked"
		var saved_moonstones: Dictionary = data.get("attuned_moonstones", {})
		attuned_moonstones = {
			"bough": bool(saved_moonstones.get("bough", false)),
			"brook": bool(saved_moonstones.get("brook", false)),
			"path": bool(saved_moonstones.get("path", false)),
		}
		if moonwell_story_stage == "complete":
			for stone_id: String in attuned_moonstones:
				attuned_moonstones[stone_id] = true
	else:
		moonwell_story_stage = "map_clue" if nima_story_stage == "complete" else "locked"
		attuned_moonstones = {"bough": false, "brook": false, "path": false}
	furnishings = sanitize_furnishings(data.get("furnishings", {})) if save_version >= 25 else {}
	if save_version >= 24:
		moonwell_supper_stage = str(data.get("moonwell_supper_stage", "locked"))
		if moonwell_supper_stage not in ["locked", "available", "complete"]:
			moonwell_supper_stage = "locked"
		moonwell_supper_courses = clampi(
			int(data.get("moonwell_supper_courses", 0)), 0, MOONWELL_SUPPER_REQUIRED_COURSES
		)
		if moonwell_supper_stage == "complete":
			moonwell_supper_courses = MOONWELL_SUPPER_REQUIRED_COURSES
	else:
		moonwell_supper_stage = "locked"
		moonwell_supper_courses = 0
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
	if save_version >= 12:
		player_coins = data.get("player_coins", {}).duplicate()
	else:
		player_coins = {}
	if save_version >= 13:
		hearthbloom_contributions = clampi(
			int(data.get("hearthbloom_contributions", 0)), 0, HEARTHBLOOM_REQUIRED_COINS
		)
		hearthbloom_complete = (
			bool(data.get("hearthbloom_complete", false))
			or hearthbloom_contributions >= HEARTHBLOOM_REQUIRED_COINS
		)
		if hearthbloom_complete:
			hearthbloom_contributions = HEARTHBLOOM_REQUIRED_COINS
	else:
		hearthbloom_contributions = 0
		hearthbloom_complete = false
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
	player_relationships = data.get("player_relationships", {}).duplicate(true)
	player_npc_check_in_day = data.get("player_npc_check_in_day", {}).duplicate(true)
	if save_version >= 21:
		player_chronicle_read_count = data.get("player_chronicle_read_count", {}).duplicate()
	else:
		player_chronicle_read_count = {}
	if save_version >= 18:
		player_mara_keepsakes = data.get("player_mara_keepsakes", {}).duplicate()
	else:
		player_mara_keepsakes = {}
		for player_token: String in player_relationships:
			player_mara_keepsakes[player_token] = (
				int(player_relationships[player_token].get("mara", 0)) >= MARA_KEEPSAKE_RAPPORT
			)
	if save_version >= 19:
		player_survey_day = data.get("player_survey_day", {}).duplicate()
	else:
		player_survey_day = {}
	if save_version >= 14:
		player_outing_kits = data.get("player_outing_kits", {}).duplicate()
	else:
		player_outing_kits = {}
	if save_version >= 20:
		var saved_homestead_lanterns: Dictionary = data.get("built_homestead_lanterns", {})
		for socket_id: String in HOMESTEAD_LANTERN_POSITIONS:
			built_homestead_lanterns[socket_id] = bool(saved_homestead_lanterns.get(socket_id, false))
	else:
		for socket_id: String in HOMESTEAD_LANTERN_POSITIONS:
			built_homestead_lanterns[socket_id] = false
	if save_version >= 15:
		player_riverfish = data.get("player_riverfish", {}).duplicate()
	else:
		player_riverfish = {}
	if save_version >= 17:
		shared_riverfish_stock = clampi(
			int(data.get("shared_riverfish_stock", 0)), 0, RIVERFISH_CREEL_CAPACITY
		)
	else:
		shared_riverfish_stock = 0
	if save_version >= 16:
		supply_basket_stock = clampi(
			int(data.get("supply_basket_stock", 0)), 0, SUPPLY_BASKET_DAILY_STOCK
		)
	else:
		supply_basket_stock = (
			SUPPLY_BASKET_DAILY_STOCK
			if livelihood_stage == "complete" and produce_stall_open
			else 0
		)
	sunwheat_planted_at.clear()
	homestead_planted_at.clear()
	if save_version >= 36:
		var stored_crops: Dictionary = data.get("homestead_planted_at", {})
		for station: Dictionary in furnishing_stations({"world_seed": world_seed, "furnishings": furnishings, "structures": structures, "wilderness_plots": wilderness_plots}):
			if CROP_BEDS.has(station["kind"]) and stored_crops.has(station["id"]):
				homestead_planted_at[station["id"]] = clampi(int(stored_crops[station["id"]]), 0, world_calendar_minutes())
	if save_version >= 27:
		var saved_plantings: Dictionary = data.get("sunwheat_planted_at", {})
		for bed_id: String in SUNWHEAT_BEDS:
			if saved_plantings.has(bed_id):
				sunwheat_planted_at[bed_id] = clampi(int(saved_plantings[bed_id]), 0, world_calendar_minutes())
	# Cast timing is intentionally session-only and never resumes after a restart.
	player_fishing_phase = {}
	player_fishing_time = {}
	_refresh_moonwell_supper_stage()
	world_clock_fraction = 0.0
	# Active festival runs are intentionally ephemeral so a restart cannot strand entrants.
	festival_stage = "available" if livelihood_stage == "complete" and produce_stall_open else "locked"
	festival_participants = {}
	festival_finishers = []
	_update_mara_routine()
	_update_nima_routine()
	positions.clear()
	var encoded_positions: Dictionary = data.get("positions", {})
	for player_token: String in encoded_positions:
		var encoded: Array = encoded_positions[player_token]
		if encoded.size() == 3:
			positions[player_token] = Vector3(float(encoded[0]), float(encoded[1]), float(encoded[2]))
