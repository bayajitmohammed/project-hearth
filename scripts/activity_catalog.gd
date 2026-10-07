extends RefCounted

const Wilderness = preload("res://scripts/wilderness_layout.gd")

const IDS := ["automatic", "home", "welcome", "fishing", "building", "northwood", "nima", "moonwell", "supper", "reedbank", "sunwheat", "food", "festival", "briarwatch", "wilderness", "outpost", "sparring"]


static func entries(state: Dictionary) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	var charted: Array[String] = []
	for x in range(Wilderness.COUNT):
		for z in range(Wilderness.COUNT):
			var cell := Vector2i(x, z)
			if state.get("wilderness_discoveries", {}).has(Wilderness.key(cell)):
				charted.append(Wilderness.title(cell))
	_add(result, "wilderness", "The Western Trails", "Exploration", false, "Explore west beyond the home and Northwood", "Nine seed-shaped woodland sections share map discoveries. Each trail stone holds one provision per player, once. Two wood piles and one herb patch per section renew each world day for shared projects and crafting. Use E nearby. Return east to reach home. Charted: %s." % (", ".join(charted) if not charted.is_empty() else "none yet"))
	var home := str(state.get("quest_stage", "meet_mara"))
	if not state.get("wilderness_discoveries", {}).is_empty():
		var outpost: Dictionary = state.get("outpost_parts", {})
		var site := Wilderness.outpost_position(int(state.get("world_seed", 1)))
		_add(result, "outpost", "Fartrail Outpost", "Shared project", outpost.size() == 3, "Fartrail offers rest and trailcraft" if outpost.size() == 3 else "Establish a wilderness outpost · %d / 3 jobs" % outpost.size(), "In %s, near %.0fm west / %.0fm north of home. Shelter: 3 shared wood; remedies: 2 shared herbs; meal: 2 personal/creel fish. Any order, any companion. Finished jobs: %s. Completion opens separate rest and supply-crafting stations." % [Wilderness.title(Wilderness.outpost_cell(int(state.get("world_seed", 1)))), -site.x, 10 - site.z, ", ".join(outpost.keys()) if not outpost.is_empty() else "none"])
	_add(result, "home", "A New Home", "Story", home == "home_repaired",
		str({"meet_mara": "Meet Mara beside the cottage", "recover_supplies": "Gather wood, herbs, and the lost forest supplies", "return_to_mara": "Return the supplies to Mara", "repair_cottage": "Craft a repair kit and repair the three cottage parts", "home_repaired": "Your shared cottage is repaired"}.get(home, "Meet Mara")),
		"Use E near people, supplies, and repair markers. Craft the repair kit with C; rest at the repaired cottage when injured.")
	if home == "home_repaired":
		var welcome := str(state.get("neighborhood_event_stage", "invitation"))
		_add(result, "welcome", "Welcome Lights", "Story", welcome == "complete", "The welcome lanterns are lit" if welcome == "complete" else ("Speak to Mara about the gathering" if welcome == "invitation" else "Light the three neighborhood lanterns"), "The gathering lives beside the home road. Any companion can contribute.")
		_add(result, "fishing", "Willowmere Fishing", "Livelihood", false, "Cast at Willowmere Pond", "West of the home road: E casts, then E during BITE reels in a riverfish. Cook it at the cottage fire or leave it in the shared creel.")
		_add(result, "building", "Make the Homestead Yours", "Building", false, "Build at home or claim a western clearing", "Use B to choose, rotate, place, and remove furniture or supported structures for two refundable wood. Western claim posts establish shared plots for two wood once; the outpost section stays protected. Briarwatch unlocks a Watch lantern; the Moonwell Supper unlocks a Gathering table for everyone.")
	var exploration := str(state.get("exploration_stage", "locked"))
	if exploration != "locked":
		_add(result, "northwood", "Beyond the Road", "Adventure", exploration == "complete", str({"follow_rumor": "Follow the road north into Northwood", "find_ruins": "Find the Old Stone Ruins", "defeat_guardian": "Overcome the ruin guardian", "restore_waystone": "Restore the ancient waystone", "complete": "The shared ruins route is restored"}.get(exploration, "Explore the Old Stone Ruins")), "Travel north. Brace with F, strike with Space, or use R for a committed power strike. The restored waystones connect the ruins and home.")
	var nima := str(state.get("nima_story_stage", "locked"))
	if bool(state.get("ruin_waystone_activated", false)):
		var watch_stage := str(state.get("briarwatch_stage", "rumor"))
		_add(result, "briarwatch", "The Briarwatch Signal", "Adventure", watch_stage == "complete", str({"rumor": "Follow the road beyond the ruins to Briarwatch", "bindings": "Break the three spirit bindings", "rekindle": "Rekindle the watch beacon", "complete": "Briarwatch is safe; its beacon returns travelers home"}.get(watch_stage, "Explore Briarwatch")), "Begin at the northern trail marker. Strikes cannot reach the spirit: use E at its bindings. Leave marked ground or time F to brace before the pulse. Bindings broken: %d / 3." % state.get("broken_briarwatch_bindings", {}).size())
	if nima != "locked":
		_add(result, "nima", "Nima's Bearings", "Story", nima == "complete", str({"arrival": "Meet Nima at the home waystone", "find_case": "Recover Nima's field case in eastern Northwood", "return_case": "Return the recovered case to Nima", "complete": "Nima has settled beside the homestead"}.get(nima, "Speak to Nima")), "Her charts and map table open new shared leads. Friends can continue each other's story steps.")
	var moonwell := str(state.get("moonwell_story_stage", "locked"))
	if moonwell != "locked":
		_add(result, "moonwell", "Moonwell Glade", "Adventure", moonwell == "complete", str({"map_clue": "Study the lead at Nima's home map table", "find_glade": "Find the glade west of the Old Stone Ruins", "attune_stones": "Attune the three dormant moonstones", "complete": "The luminous spring is a shared sanctuary"}.get(moonwell, "Explore Moonwell Glade")), "Use E at each dormant stone. The restored spring heals standing travelers; it does not revive downed companions.")
	var supper := str(state.get("moonwell_supper_stage", "locked"))
	if supper != "locked":
		_add(result, "supper", "Moonwell Supper", "Shared project", supper == "complete", "The glade table is ready for everyone" if supper == "complete" else "Prepare three courses at the Moonwell hearth", "Each course needs one shared moonroot and one personal or creel fish. Courses prepared: %d / 3." % int(state.get("moonwell_supper_courses", 0)))
	if nima == "complete":
		var reedbank := str(state.get("reedbank_stage", "meet_oren"))
		_add(result, "reedbank", "The Wind Returns", "Story", reedbank == "complete", str({"meet_oren": "Meet Oren on Northwood's eastern trail", "recover_sail": "Recover the sail in Reedbank's northern reeds", "repair_mill": "Fit the sail with two shared wood at the mill", "return_oren": "Tell Oren beside the mill it is ready", "complete": "Oren's windmill and rest shelter are open"}.get(reedbank, "Visit Reedbank Hollow")), "Follow the eastern branch beyond Northwood. Oren's repaired mill opens sunwheat farming and bread baking.")
		if reedbank == "complete":
			var bag: Dictionary = state.get("materials", {})
			_add(result, "sunwheat", "Sunwheat and Trail Bread", "Livelihood", false, "Sow, harvest, mill flour, and bake bread", "Reedbank beds ripen in two active minutes. Mill two grain into one flour; bake flour plus herb into two provisions. Shared grain %d · Flour %d · Herbs %d." % [int(bag.get("sunwheat", 0)), int(bag.get("flour", 0)), int(bag.get("herb", 0))])
	if str(state.get("livelihood_stage", "locked")) != "locked":
		var stall := bool(state.get("produce_stall_open", false))
		_add(result, "food", "Neighborhood Food", "Livelihood", false, "Fill today's market request" if bool(state.get("daily_food_order_active", false)) else ("Tend moonroot and prepare for the next market day" if stall else "Grow moonroot, cook stew, and open the produce stall"), "Use the cottage garden and cookfire, then deliver at the market crate. Each new day brings ripe moonroot and one new order after the stall opens.")
	if str(state.get("festival_stage", "locked")) != "locked" or bool(state.get("produce_stall_open", false)):
		_add(result, "festival", "Hearthlight Circuit", "Social activity", false, "Join the festival at the neighborhood arch", "Opt in with E, then interact again to start when your friends are ready. Follow the three ordered checkpoints; each finisher earns a cosmetic ribbon.")
	if bool(state.get("produce_stall_open", false)):
		_add(result, "sparring", "The Sparring Circle", "Social activity", false, "Find a volunteer at the southeast training circle", "Two players opt in with E. After the countdown, Space/R taps and F guards with equal training gear. Match pips are separate from world health. Leave the ring to cancel; decisive bouts award both finishers cosmetic ribbons.")
	return result


static func find_entry(state: Dictionary, activity_id: String) -> Dictionary:
	for entry: Dictionary in entries(state):
		if entry["id"] == activity_id:
			return entry
	return {}


static func _add(result: Array[Dictionary], activity_id: String, title: String, category: String, complete: bool, objective: String, description: String) -> void:
	result.append({"id": activity_id, "title": title, "category": category, "complete": complete, "objective": objective, "description": description})
