class_name WorldState
extends RefCounted

const SPAWN_POINT := Vector3(0.0, 0.6, 10.0)
const COLLECTIBLE_POSITION := Vector3(0.0, 0.5, -6.5)
const PICKUP_RADIUS := 1.15
const WORLD_MIN_X := -17.0
const WORLD_MAX_X := 17.0
const WORLD_MIN_Z := -14.0
const WORLD_MAX_Z := 14.0

var collectible_collected := false
var positions: Dictionary = {}


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
	if collectible_collected:
		return false
	if register_player(player_token).distance_to(COLLECTIBLE_POSITION) > PICKUP_RADIUS:
		return false
	collectible_collected = true
	return true


func to_dictionary() -> Dictionary:
	var encoded_positions := {}
	for player_token: String in positions:
		var position: Vector3 = positions[player_token]
		encoded_positions[player_token] = [position.x, position.y, position.z]
	return {
		"version": 1,
		"collectible_collected": collectible_collected,
		"positions": encoded_positions,
	}


func load_dictionary(data: Dictionary) -> void:
	collectible_collected = bool(data.get("collectible_collected", false))
	positions.clear()
	var encoded_positions: Dictionary = data.get("positions", {})
	for player_token: String in encoded_positions:
		var encoded: Array = encoded_positions[player_token]
		if encoded.size() == 3:
			positions[player_token] = Vector3(float(encoded[0]), float(encoded[1]), float(encoded[2]))
