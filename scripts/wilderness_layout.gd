extends RefCounted

const ORIGIN := Vector3(-113, 0, -74)
const SIZE := 32.0
const COUNT := 3
const NAMES := ["Fernwatch", "Silverleaves", "Moss Hollow", "Willow Reach", "Quiet Pines", "Starfern", "Amber Grove", "Dewfields", "Westwind"]


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
	for index in range(18):
		var point := center(cell) + Vector3(random.randf_range(-14, 14), 0, random.randf_range(-14, 14))
		if point.distance_to(cache) > 4:
			result.append(point)
	return result
