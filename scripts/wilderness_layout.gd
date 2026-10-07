extends RefCounted

const ORIGIN := Vector3(-113, 0, -74)
const SIZE := 32.0
const COUNT := 3
const NAMES := ["Fernwatch", "Silverleaves", "Moss Hollow", "Willow Reach", "Quiet Pines", "Starfern", "Amber Grove", "Dewfields", "Westwind"]
const OUTPOST_OFFSETS := {"shelter": Vector3(-3, 0, 0), "remedies": Vector3(3, 0, 0), "meal": Vector3(0, 0, 4), "rest": Vector3(-3, 0, 0), "craft": Vector3(3, 0, 0)}


static func outpost_cell(seed_value: int) -> Vector2i:
	return Vector2i(posmod(seed_value, 2), posmod(seed_value / 2, 2))


static func outpost_position(seed_value: int) -> Vector3:
	var cell := outpost_cell(seed_value)
	var offset := cache_position(seed_value, cell) - center(cell)
	return center(cell) + Vector3(-9 if offset.x >= 0 else 9, 0.6, -9 if offset.z >= 0 else 9)


static func outpost_station(seed_value: int, station: String) -> Vector3:
	return outpost_position(seed_value) + OUTPOST_OFFSETS[station]


static func cell_at(point: Vector3) -> Vector2i:
	return Vector2i(floori((point.x - ORIGIN.x) / SIZE), floori((point.z - ORIGIN.z) / SIZE))


static func valid(cell: Vector2i) -> bool:
	return cell.x >= 0 and cell.x < COUNT and cell.y >= 0 and cell.y < COUNT


static func key(cell: Vector2i) -> String:
	return "%d,%d" % [cell.x, cell.y]


static func title(cell: Vector2i) -> String:
	return NAMES[cell.y * COUNT + cell.x] if valid(cell) else "Western wilderness"


static func center(cell: Vector2i) -> Vector3:
	return ORIGIN + Vector3(cell.x + 0.5, 0, cell.y + 0.5) * SIZE


static func random_for(seed_value: int, cell: Vector2i) -> RandomNumberGenerator:
	var random := RandomNumberGenerator.new()
	random.seed = seed_value + (cell.x + 1) * 73856093 + (cell.y + 1) * 19349663
	return random


static func cache_position(seed_value: int, cell: Vector2i) -> Vector3:
	var random := random_for(seed_value, cell)
	return center(cell) + Vector3(random.randf_range(-8, 8), 0.6, random.randf_range(-8, 8))


static func scenery(seed_value: int, cell: Vector2i) -> Array[Vector3]:
	var random := random_for(seed_value, cell)
	var cache := cache_position(seed_value, cell)
	var result: Array[Vector3] = []
	var forage := forage_nodes(seed_value, cell)
	for index in range(18):
		var point := center(cell) + Vector3(random.randf_range(-14, 14), 0, random.randf_range(-14, 14))
		var clear := true
		if cell != outpost_cell(seed_value):
			var plot := plot_origin(seed_value, cell)
			if Rect2(Vector2(plot.x - 3, plot.z - 3), Vector2(24, 12)).has_point(Vector2(point.x, point.z)):
				clear = false
		for source: Dictionary in forage:
			if point.distance_to(source["position"]) <= 4:
				clear = false
		if clear and point.distance_to(cache) > 4 and (cell != outpost_cell(seed_value) or point.distance_to(outpost_position(seed_value)) > 8):
			result.append(point)
	return result


static func plot_origin(seed_value: int, cell: Vector2i) -> Vector3:
	var cache := cache_position(seed_value, cell) - center(cell)
	return center(cell) + Vector3(-6, 0, (-7 if cache.z >= 0 else 7) - 3)


static func claim_post(seed_value: int, cell: Vector2i) -> Vector3:
	return plot_origin(seed_value, cell) + Vector3(15, 0.6, 3)


static func forage_nodes(seed_value: int, cell: Vector2i) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	if not valid(cell):
		return result
	var corners := [Vector3(-12, 0.6, -12), Vector3(12, 0.6, -12), Vector3(-12, 0.6, 12), Vector3(12, 0.6, 12)]
	var omit := posmod(seed_value + cell.x * 7 + cell.y * 13, 4)
	if cell == outpost_cell(seed_value):
		var offset := outpost_position(seed_value) - center(cell)
		omit = (1 if offset.x > 0 else 0) + (2 if offset.z > 0 else 0)
	var random := random_for(seed_value + 104729, cell)
	for index in range(4):
		if index == omit:
			continue
		var kind := "wood" if result.size() < 2 else "herb"
		var point: Vector3 = center(cell) + corners[index] + Vector3(random.randf_range(-1, 1), 0, random.randf_range(-1, 1))
		result.append({"id": "%s/%d" % [key(cell), result.size()], "kind": kind, "position": point})
	return result
