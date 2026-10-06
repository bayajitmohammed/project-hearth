extends RefCounted

const ORIGIN := Vector3(-15, 0, 16)
const COLUMNS := 5
const ROWS := 3
const SPACING := 3.0
const KINDS := ["foundation", "wall", "doorway", "roof"]
const NAMES := {"foundation": "Foundation", "wall": "Wall", "doorway": "Doorway", "roof": "Roof"}
const PLAYER_RADIUS := 0.3


static func position(cell: Vector2i) -> Vector3:
	return ORIGIN + Vector3(cell.x, 0, cell.y) * SPACING


static func key(cell: Vector2i, kind: String, turns: int) -> String:
	var slot := "side%d" % turns if kind in ["wall", "doorway"] else kind
	return "%d,%d/%s" % [cell.x, cell.y, slot]


static func cell_for(slot: String) -> Vector2i:
	var parts := slot.get_slice("/", 0).split(",")
	return Vector2i(int(parts[0]), int(parts[1]))


static func _side_count(layout: Dictionary, cell: Vector2i) -> int:
	var count := 0
	for side in range(4):
		if layout.has(key(cell, "wall", side)):
			count += 1
	return count


static func change_error(layout: Dictionary, cell: Vector2i, kind: String, turns: int, remove: bool, players: Array = []) -> String:
	if cell.x < 0 or cell.x >= COLUMNS or cell.y < 0 or cell.y >= ROWS or kind not in KINDS or turns < 0 or turns > 3:
		return "Choose a valid structure slot."
	var slot := key(cell, kind, turns)
	if remove:
		if not layout.has(slot):
			return "This structure slot is empty."
		if kind == "foundation" and (_side_count(layout, cell) > 0 or layout.has(key(cell, "roof", 0))):
			return "Remove the walls and roof first."
		if kind in ["wall", "doorway"] and layout.has(key(cell, "roof", 0)) and _side_count(layout, cell) <= 2:
			return "Remove the roof before its supports."
		return ""
	if layout.has(slot):
		return "This structure slot is occupied."
	if kind != "foundation" and not layout.has(key(cell, "foundation", 0)):
		return "Place a foundation first."
	if kind == "roof" and _side_count(layout, cell) < 2:
		return "A roof needs at least two wall sides."
	for solid: Rect2 in solid_rects(cell, kind, turns):
		for point: Vector3 in players:
			if solid.grow(PLAYER_RADIUS).has_point(Vector2(point.x, point.z)):
				return "A player is standing in this wall."
	return ""


static func solid_rects(cell: Vector2i, kind: String, turns: int) -> Array[Rect2]:
	var result: Array[Rect2] = []
	if kind not in ["wall", "doorway"]:
		return result
	var offsets: Array = [-1.05, 1.05] if kind == "doorway" else [0.0]
	var width := 0.7 if kind == "doorway" else 2.8
	for x: float in offsets:
		var center := position(cell) + Vector3(x, 0, -1.4).rotated(Vector3.UP, turns * PI / 2)
		var size := Vector2(width, 0.16) if turns % 2 == 0 else Vector2(0.16, width)
		result.append(Rect2(Vector2(center.x, center.z) - size / 2, size))
	return result


static func constrain_movement(layout: Dictionary, start: Vector3, target: Vector3) -> Vector3:
	var solids: Array[Rect2] = []
	for slot: String in layout:
		var piece: Dictionary = layout[slot]
		for solid: Rect2 in solid_rects(cell_for(slot), piece["kind"], int(piece["rotation"])):
			solids.append(solid.grow(PLAYER_RADIUS))
	var result := start
	result.x = target.x
	for solid: Rect2 in solids:
		if start.z > solid.position.y and start.z < solid.end.y:
			if start.x <= solid.position.x and result.x > solid.position.x:
				result.x = solid.position.x
			elif start.x >= solid.end.x and result.x < solid.end.x:
				result.x = solid.end.x
	result.z = target.z
	for solid: Rect2 in solids:
		if result.x > solid.position.x and result.x < solid.end.x:
			if start.z <= solid.position.y and result.z > solid.position.y:
				result.z = solid.position.y
			elif start.z >= solid.end.y and result.z < solid.end.y:
				result.z = solid.end.y
	return result


static func sanitize(saved: Dictionary) -> Dictionary:
	var result: Dictionary = {}
	for kind: String in KINDS:
		for x in range(COLUMNS):
			for z in range(ROWS):
				var cell := Vector2i(x, z)
				for turns in range(4 if kind in ["wall", "doorway"] else 1):
					var slot := key(cell, kind, turns)
					var piece: Variant = saved.get(slot, {})
					if not piece is Dictionary or str(piece.get("kind", "")) != kind:
						continue
					var rotation := int(piece.get("rotation", -1))
					if rotation < 0 or rotation > 3 or key(cell, kind, rotation) != slot:
						continue
					if change_error(result, cell, kind, rotation, false).is_empty():
						result[slot] = {"kind": kind, "rotation": rotation}
	return result
