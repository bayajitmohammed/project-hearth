extends SceneTree

const World = preload("res://scripts/world_state.gd")
const View = preload("res://scripts/spell_view.gd")


func _init() -> void:
	_run.call_deferred()


func _run() -> void:
	var world := World.new()
	world.quest_stage = "home_repaired"
	world.register_player("a")
	world.register_player("b")
	world.positions["a"] = World.GEAR_RACK_POSITION
	assert(world.try_switch_outing_kit("a") and world.try_switch_outing_kit("a"))
	assert(world.player_outing_kits["a"] == "vanguard", "Legacy worlds keep their two-kit cycle.")
	world.moonwell_story_stage = "complete"
	assert(world.try_switch_outing_kit("a") and world.try_switch_outing_kit("a"))
	assert(world.outing_kit_label("a") == "Moonweaver" and world.outing_kit_label("b") == "Vanguard")
	assert(world.try_pin_activity("a", "moonweaver"))
	var restored := World.new()
	restored.load_dictionary(world.to_dictionary())
	world = restored
	assert(world.outing_kit_label("a") == "Moonweaver")
	world.positions["a"] = World.CREATURE_SPAWN + Vector3(0, 0, 6)
	assert(not world.attack_creature("a"))
	assert(world.player_attack_recovery["a"] == 0 and world.spell_traces.is_empty())
	world.positions["a"] = World.CREATURE_SPAWN + Vector3(0, 0, 5)
	world.positions["b"] = world.positions["a"]
	assert(not world.attack_creature("b"), "Melee does not gain magic range.")
	world.downed_players["a"] = true
	assert(not world.attack_creature("a"))
	world.downed_players["a"] = false
	world.creature_returning = true
	assert(not world.attack_creature("a"), "Returning enemies cannot be sniped.")
	world.creature_returning = false
	assert(world.attack_creature("a"))
	assert(world.creature_health == 2 and world.player_mastery["a"]["combat"] == 1)
	assert(is_equal_approx(world.player_attack_recovery["a"], 0.9))
	assert(world.spell_traces.has("a") and not world.spell_traces["a"]["heavy"])
	assert(not world.power_strike_creature("a"), "Basic and burst share recovery.")
	var view := View.new()
	root.add_child(view)
	var snapshot := world.to_dictionary()
	snapshot["spell_traces"] = world.spell_traces.duplicate(true)
	snapshot["positions"] = world.positions.duplicate()
	snapshot["creature_position"] = world.creature_position
	snapshot["ruin_guardian_position"] = world.ruin_guardian_position
	view.update_view(snapshot, "a")
	assert(view.beams.size() == 1 and view.hint.visible)
	assert(is_equal_approx(view.beams["a"].mesh.size.z, 4.55))
	snapshot["spell_traces"]["a"]["to"] = snapshot["spell_traces"]["a"]["from"] + Vector3.UP * 0.05
	view.update_view(snapshot, "a")
	assert(view.beams["a"].basis.is_finite(), "Overlapping caster/target positions still render a valid trace.")
	var persisted := World.new()
	persisted.load_dictionary(world.to_dictionary())
	assert(persisted.spell_traces.is_empty() and persisted.outing_kit_label("a") == "Moonweaver")
	world._update_player_combat_timers(0.9, ["a", "b"])
	assert(world.spell_traces.is_empty())
	assert(world.power_strike_creature("a"))
	assert(world.creature_defeated and world.player_mastery["a"]["combat"] == 2)
	assert(is_equal_approx(world.player_attack_recovery["a"], 2.2) and world.spell_traces["a"]["heavy"])
	assert(world.try_brace("a"))
	assert(world.player_brace_time["a"] == 0.45 and world.player_brace_cooldown["a"] == 1.8)
	world._update_player_combat_timers(0.01, ["b"])
	assert(world.spell_traces.is_empty(), "Disconnected casters leave no lingering trace.")
	snapshot["spell_traces"] = {}
	view.update_view(snapshot, "a")
	assert(view.beams.is_empty())
	view.free()
	world.reset_player_combat_timers("a")
	world.creature_defeated = false
	world.creature_health = 3
	world.creature_position = World.CREATURE_SPAWN + Vector3(0, 0, 5)
	world.positions["a"] = World.CREATURE_SPAWN + Vector3(0, 0, 8.1)
	assert(not world.attack_creature("a"), "Casting from outside the encounter cannot exploit reach.")
	# Wall and doorway geometry is shared with authority, including shifted wilderness plots.
	world.structures = {"0,0/foundation": {"kind": "foundation", "rotation": 0}, "0,0/side0": {"kind": "wall", "rotation": 0}}
	var point := World.Structures.position(Vector2i.ZERO) + Vector3(0, 0.6, 0)
	world.positions["a"] = point
	assert(not world._can_reach_enemy("a", point + Vector3(0, 0, -3), point, 8, false))
	world.structures["0,0/side0"]["kind"] = "doorway"
	assert(world._can_reach_enemy("a", point + Vector3(0, 0, -3), point, 8, false))
	world.positions["a"] = point + Vector3(1.05, 0, 0)
	assert(not world._can_reach_enemy("a", point + Vector3(1.05, 0, -3), point, 8, false))
	world.wilderness_plots["2,2"] = {"structures": {"0,0/side0": {"kind": "wall", "rotation": 0}}, "furnishings": {}}
	point = World.Wilderness.plot_origin(world.world_seed, Vector2i(2, 2)) + Vector3(0, 0.6, 0)
	world.positions["a"] = point
	assert(not world._can_reach_enemy("a", point + Vector3(0, 0, -3), point, 8, false))
	world.positions["a"] = World.Sparring.CENTER
	world.positions["b"] = World.Sparring.CENTER + Vector3(3, 0, 0)
	world.sparring.stage = "active"
	world.sparring.participants = {"a": 3, "b": 3}
	assert(not world.attack_creature("a"), "Sparring never inherits magic reach.")
	world.positions["b"] = World.Sparring.CENTER + Vector3(1, 0, 0)
	assert(world.power_strike_creature("a"))
	assert(world.sparring.participants["b"] == 2 and world.spell_traces.is_empty())
	assert(world.try_brace("a") and world.sparring.guards["a"] == World.Sparring.GUARD_WINDOW)
	assert(world.player_mastery["a"]["combat"] == 2)
	world.sparring.participants.clear()
	world.positions["a"] = World.GEAR_RACK_POSITION
	assert(world.try_switch_outing_kit("a") and world.outing_kit_label("a") == "Vanguard")
	world.player_outing_kits["a"] = "moonweaver"
	world.moonwell_story_stage = "locked"
	assert(world.outing_kit_label("a") == "Vanguard", "An unavailable saved kit is not an unlock bypass.")
	var guardian_world := World.new()
	guardian_world.moonwell_story_stage = "complete"
	guardian_world.exploration_stage = "defeat_guardian"
	guardian_world.register_player("caster")
	guardian_world.player_outing_kits["caster"] = "moonweaver"
	guardian_world.positions["caster"] = World.RUIN_GUARDIAN_SPAWN + Vector3(0, 0, 5)
	assert(guardian_world.attack_creature("caster"))
	assert(guardian_world.ruin_guardian_health == 4 and guardian_world.creature_health == 3)
	assert(guardian_world.spell_traces["caster"]["to"] == World.RUIN_GUARDIAN_SPAWN + Vector3(0, 0.4, 0))
	print("PASS: Moonweaver unlock/cycle, ranged trade-offs, guarded authority, wall/doorway sight, shared transient traces, persistence and normalized sparring")
	quit()
