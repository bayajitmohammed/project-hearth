extends SceneTree

const World = preload("res://scripts/world_state.gd")
const Circle = preload("res://scripts/sparring_circle.gd")


func _init() -> void:
	_run.call_deferred()


func _run() -> void:
	var world := World.new()
	for token in ["a", "b", "spectator"]:
		world.register_player(token)
		world.positions[token] = World.Sparring.CENTER
	assert(not world.try_sparring_interaction("a"))
	world.produce_stall_open = true
	assert(world.try_sparring_interaction("a"))
	assert(world.sparring.stage == "waiting" and not world.attack_creature("a"))
	assert(world.try_sparring_interaction("a") and world.sparring.participants.is_empty())
	assert(world.try_sparring_interaction("a"))
	assert(world.try_sparring_interaction("b"))
	assert(world.sparring.stage == "countdown")
	assert(not world.try_sparring_interaction("spectator"))
	assert(not world.power_strike_creature("a"))
	world.sparring.tick(3, world.positions, world.downed_players, ["a", "b", "spectator"])
	assert(not world.attack_creature("a"), "Equal starting positions are outside tap reach.")
	world.positions["a"] = World.Sparring.CENTER
	world.player_outing_kits["b"] = World.OUTING_KIT_GUARDIAN
	world.player_health["a"] = 1
	world.player_provisions["a"] = 2
	var health := world.player_health.duplicate()
	var mastery := world.player_mastery.duplicate(true)
	assert(not world.attack_creature("spectator"))
	assert(world.try_brace("b"))
	assert(world.sparring.guards["b"] == World.Sparring.GUARD_WINDOW, "Guardian gear cannot improve match guard.")
	assert(world.power_strike_creature("a"))
	assert(world.sparring.participants["b"] == 3 and world.sparring.guards["b"] == 0)
	assert(not world.attack_creature("a"))
	for hit in range(3):
		world.sparring.tick(0.71, world.positions, world.downed_players, ["a", "b"])
		assert(world.power_strike_creature("a"))
		if hit < 2:
			assert(world.sparring.participants["b"] == 2 - hit, "Power strike is normalized to one pip.")
	assert(world.sparring.stage == "results" and world.sparring.last_winner == "a")
	assert(world.sparring.ribbons == {"a": 1, "b": 1})
	assert(world.player_health == health and world.player_mastery == mastery and world.player_provisions["a"] == 2)
	assert(world.sparring.participants.is_empty())
	var restored := World.new()
	restored.load_dictionary(world.to_dictionary())
	assert(restored.sparring.ribbons == world.sparring.ribbons and restored.sparring.last_winner == "a")
	assert(restored.sparring.stage == "available" and restored.sparring.participants.is_empty())
	assert(restored.try_pin_activity("a", "sparring"))
	for reason in ["leave", "disconnect", "downed", "timeout", "reload"]:
		for token in ["a", "b"]:
			restored.positions[token] = World.Sparring.CENTER
			restored.downed_players[token] = false
			assert(restored.try_sparring_interaction(token))
		restored.sparring.tick(3, restored.positions, restored.downed_players, ["a", "b"])
		match reason:
			"leave":
				restored.positions["b"] = World.SPAWN_POINT
				restored.sparring.tick(0.1, restored.positions, restored.downed_players, ["a", "b"])
			"disconnect":
				restored.sparring.tick(0.1, restored.positions, restored.downed_players, ["a"])
			"downed":
				restored.downed_players["b"] = true
				restored.sparring.tick(0.1, restored.positions, restored.downed_players, ["a", "b"])
			"timeout":
				restored.sparring.tick(60, restored.positions, restored.downed_players, ["a", "b"])
			"reload":
				restored.load_dictionary(restored.to_dictionary())
		assert(restored.sparring.participants.is_empty() and restored.sparring.ribbons == {"a": 1, "b": 1})
	var circle := Circle.new()
	root.add_child(circle)
	var snapshot := {"produce_stall_open": true, "positions": {"a": World.Sparring.CENTER}, "sparring": world.sparring.snapshot()}
	circle.update_view(snapshot, "a")
	assert(circle.visible and circle.status.visible and "You won" in circle.status.text)
	restored.load_dictionary({"version": 34})
	assert(restored.sparring.ribbons.is_empty())
	print("PASS: explicit sparring consent, normalized taps/guard, safe spectators, preserved health/inventory/mastery, durable cosmetics and safe cancellation")
	quit()
