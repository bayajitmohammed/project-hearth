extends RefCounted

const MOONWEAVER := "moonweaver"
const DATA := {
	"vanguard": {"name": "Vanguard", "reach": 2.0, "recovery_factor": 1.0, "recovery_penalty": 0.0, "brace": 0.7, "brace_cooldown": 1.6},
	"guardian": {"name": "Guardian", "reach": 2.0, "recovery_factor": 1.0, "recovery_penalty": 0.2, "brace": 1.0, "brace_cooldown": 1.25},
	"moonweaver": {"name": "Moonweaver", "reach": 5.5, "recovery_factor": 2.0, "recovery_penalty": 0.0, "brace": 0.45, "brace_cooldown": 1.8},
}


static func available(moonwell_complete: bool) -> Array[String]:
	var result: Array[String] = ["vanguard", "guardian"]
	if moonwell_complete:
		result.append(MOONWEAVER)
	return result


static func next(current: String, moonwell_complete: bool) -> String:
	var choices := available(moonwell_complete)
	return choices[posmod(choices.find(current) + 1, choices.size())]


static func stats(kit: String) -> Dictionary:
	return DATA.get(kit, DATA["vanguard"])


static func recovery(kit: String, base: float) -> float:
	var values := stats(kit)
	return base * float(values["recovery_factor"]) + float(values["recovery_penalty"])


static func clear_tether(start: Vector3, finish: Vector3, walls: Array[Rect2]) -> bool:
	var a := Vector2(start.x, start.z)
	var b := Vector2(finish.x, finish.z)
	for wall: Rect2 in walls:
		var solid := wall.grow(0.025)
		if solid.has_point(a) or solid.has_point(b):
			return false
		var corners := [solid.position, Vector2(solid.end.x, solid.position.y), solid.end, Vector2(solid.position.x, solid.end.y)]
		for index in range(4):
			if Geometry2D.segment_intersects_segment(a, b, corners[index], corners[(index + 1) % 4]) != null:
				return false
	return true
