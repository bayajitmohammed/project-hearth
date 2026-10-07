extends SceneTree

const World = preload("res://scripts/world_state.gd")
const View = preload("res://scripts/briarwatch.gd")


func _init() -> void:
	_run.call_deferred()


func _run() -> void:
	for count in range(1, 9):
		var world := World.new()
		world.ruin_waystone_activated = true
		world.briarwatch_stage = "bindings"
		var active: Array = []
		for index in range(count):
			var token := "p%d" % index
			world.register_player(token)
			world.positions[token] = Vector3(-7 + index * 2, 0.6, -60)
			active.append(token)
		active.reverse()
		world.simulate_briarwatch(3.1, active)
		var expected := 1 if count == 1 else (2 if count <= 4 else 3)
		assert(world.briarwatch_pulse_positions.size() == expected)
		for index in range(expected):
			assert(world.briarwatch_pulse_positions[index] == world.positions["p%d" % index])
		var locked := world.briarwatch_pulse_positions.duplicate()
		for token: String in active:
			world.positions[token].z -= 4
		world.simulate_briarwatch(0.3, ["p0"])
		assert(world.briarwatch_pulse_positions == locked, "Drop-out never moves an already shown mark.")
		assert(not world.simulate_briarwatch(1, ["p0"]))
		world.simulate_briarwatch(3.1, ["p0", "p0"])
		assert(world.briarwatch_pulse_positions.size() == 1, "Only distinct current participants scale the next wave.")
		var restored := World.new()
		restored.load_dictionary(world.to_dictionary())
		assert(restored.briarwatch_pulse_positions.is_empty() and restored.briarwatch_windup == 0)
		world.simulate_briarwatch(0.1, [])
		assert(world.briarwatch_pulse_positions.is_empty())
	var overlap := World.new()
	overlap.ruin_waystone_activated = true
	overlap.briarwatch_stage = "bindings"
	for token in ["a", "b"]:
		overlap.register_player(token)
		overlap.positions[token] = Vector3(0, 0.6, -60)
	overlap.simulate_briarwatch(3.1, ["a", "b"])
	assert(overlap.try_brace("a"))
	overlap.simulate_briarwatch(1.3, ["a", "b"])
	assert(overlap.player_health["a"] == 3 and overlap.player_health["b"] == 2, "Overlapping circles cannot consume brace then double-hit.")
	var view := View.new()
	root.add_child(view)
	var snapshot := {"briarwatch_windup": 1.0, "briarwatch_pulse_positions": [Vector3(0, 0.6, -60), Vector3(6, 0.6, -60), Vector3(-6, 0.6, -60)], "positions": {"a": Vector3(6, 0.6, -60)}}
	view.update_view(snapshot, "a")
	assert(view.pulses.all(func(pulse: MeshInstance3D) -> bool: return pulse.visible))
	assert(view.warning.visible and "LEAVE" in view.warning.text and "3 marks" in view.warning.text)
	snapshot["positions"]["a"] = Vector3(-60, 0.6, -60)
	view.update_view(snapshot, "a")
	assert(not view.warning.visible)
	snapshot["briarwatch_pulse_positions"] = []
	view.update_view(snapshot, "a")
	assert(view.pulses.all(func(pulse: MeshInstance3D) -> bool: return not pulse.visible))
	print("PASS: 1–8 participant pressure, stable targeting, drop-out, overlap-safe defense, transient saves and all-circle presentation")
	quit()
