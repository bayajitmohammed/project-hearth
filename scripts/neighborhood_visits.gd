extends RefCounted

# The authority owns selection and contributions; presentation consumes this same catalogue.
const BOARD := Vector3(15, 0.6, 6)
const JOB_POSITIONS := [Vector3(15, 0.6, 2), Vector3(15, 0.6, -2)]
const TEMPLATES := {
	"travelers": {"title": "Travelers' Rest", "items": ["wood", "provision"], "jobs": ["Shelter", "Meals"], "reason": "The open market and rain or a restored outpost draw travelers.", "memory": "The neighborhood welcomed weary travelers and raised a permanent market-green canopy."},
	"seeds": {"title": "Seedkeepers' Exchange", "items": ["herb", "moonroot"], "jobs": ["Herb cuttings", "Moonroot starts"], "reason": "Sera's welcome has drawn fellow seedkeepers to the neighborhood.", "memory": "Sera's fellow seedkeepers visited the neighborhood and planted a lasting market-green seed garden."},
}
var active := ""
var jobs: Array[int] = [0, 0]
var completed: Dictionary = {}
var finished_day := 0


func select_visit(context: Dictionary) -> bool:
	if not active.is_empty() or finished_day >= int(context["day"]):
		return false
	var eligible: Array[String] = []
	if bool(context["stall"]) and (str(context["weather"]) == "gentle_rain" or bool(context["outpost"])):
		eligible.append("travelers")
	if bool(context["sera"]):
		eligible.append("seeds")
	if eligible.is_empty():
		return false
	# Rotate the stable catalogue before picking its least-completed candidate.
	if eligible.size() > 1 and posmod(int(context["seed"]) + int(context["day"]), 2) == 1:
		eligible.reverse()
	active = eligible[0]
	for candidate: String in eligible:
		if int(completed.get(candidate, 0)) < int(completed.get(active, 0)):
			active = candidate
	jobs = [0, 0]
	return true


func contribute(token: String, point: Vector3, downed: bool, materials: Dictionary, provisions: Dictionary, day: int) -> Dictionary:
	if active.is_empty() or downed:
		return {}
	for index in range(2):
		if point.distance_to(JOB_POSITIONS[index]) > 1.8 or jobs[index] >= 2:
			continue
		var item: String = TEMPLATES[active]["items"][index]
		var inventory := provisions if item == "provision" else materials
		var key := token if item == "provision" else item
		if int(inventory.get(key, 0)) <= 0:
			return {}
		inventory[key] -= 1
		jobs[index] += 1
		var result := {"changed": true, "finished": false, "first": false, "kind": active}
		if jobs[0] == 2 and jobs[1] == 2:
			result["finished"] = true
			result["first"] = int(completed.get(active, 0)) == 0
			completed[active] = int(completed.get(active, 0)) + 1
			finished_day = day
			active = ""
			jobs = [0, 0]
		return result
	return {}


func saved() -> Dictionary:
	return {"active": active, "jobs": jobs.duplicate(), "completed": completed.duplicate(), "finished_day": finished_day}


func restore(data: Dictionary, day: int) -> void:
	active = str(data.get("active", ""))
	if not TEMPLATES.has(active):
		active = ""
	completed.clear()
	var counts: Dictionary = data.get("completed", {})
	for kind: String in TEMPLATES:
		if int(counts.get(kind, 0)) > 0:
			completed[kind] = int(counts[kind])
	finished_day = clampi(int(data.get("finished_day", 0)), 0, day)
	jobs = [0, 0]
	var stored: Array = data.get("jobs", [])
	if not active.is_empty() and stored.size() == 2:
		jobs = [clampi(int(stored[0]), 0, 2), clampi(int(stored[1]), 0, 2)]
		# Fully delivered jobs cannot remain an actionable pending visit.
		if jobs == [2, 2]:
			active = ""
			jobs = [0, 0]
			finished_day = day


static func targets(state: Dictionary) -> Array[Dictionary]:
	var visit: Dictionary = state.get("neighborhood_visits", {})
	var kind := str(visit.get("active", ""))
	var result: Array[Dictionary] = []
	if not TEMPLATES.has(kind):
		return result
	for index in range(2):
		var count := int(visit.get("jobs", [0, 0])[index])
		var item: String = TEMPLATES[kind]["items"][index]
		var goods := "personal trail provision" if item == "provision" else "shared " + item
		result.append({"position": JOB_POSITIONS[index], "text": "%s · %d/2 · %s" % [TEMPLATES[kind]["jobs"][index], count, "ready" if count >= 2 else "give 1 " + goods], "ready": count >= 2})
	return result


static func summary(state: Dictionary) -> String:
	var visit: Dictionary = state.get("neighborhood_visits", {})
	var kind := str(visit.get("active", ""))
	if TEMPLATES.has(kind):
		return "%s · %d/4 contributions" % [TEMPLATES[kind]["title"], int(visit["jobs"][0]) + int(visit["jobs"][1])]
	if int(visit.get("finished_day", 0)) >= int(state.get("world_day", 1)):
		return "Visit complete · new opportunities from tomorrow"
	return "Visitors seek an open market in rain, a restored outpost, or Sera's welcome"
