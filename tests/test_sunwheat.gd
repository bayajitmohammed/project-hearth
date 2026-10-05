extends SceneTree

const State = preload("res://scripts/world_state.gd")
const Reedbank = preload("res://scripts/reedbank_hollow.gd")


func _init() -> void:
	var world := State.new()
	world.register_player("farmer")
	world.register_player("baker")
	world.positions["farmer"] = State.SUNWHEAT_BEDS["south"]
	assert(not world.try_reedbank_livelihood("farmer"))
	world.reedbank_stage = "complete"
	assert(world.try_reedbank_livelihood("farmer"))
	assert(world.sunwheat_minutes_remaining("south") == 120)
	assert(not world.try_reedbank_livelihood("farmer"))
	world._advance_world_minutes(119)
	assert(not world.try_reedbank_livelihood("farmer"))
	var restored := State.new()
	restored.load_dictionary(world.to_dictionary())
	assert(restored.sunwheat_minutes_remaining("south") == 1)
	restored._advance_world_minutes(1)
	restored.positions["baker"] = State.SUNWHEAT_BEDS["south"]
	restored.downed_players["baker"] = true
	assert(not restored.try_reedbank_livelihood("baker"))
	restored.downed_players["baker"] = false
	assert(restored.try_reedbank_livelihood("baker"))
	assert(restored.materials["sunwheat"] == 2)
	assert(restored.player_mastery["baker"]["farming"] == 1)
	assert(restored.player_mastery["farmer"]["farming"] == 0)
	assert(restored.try_reedbank_livelihood("farmer")) # Replant, never duplicate a harvest.
	assert(restored.materials["sunwheat"] == 2)
	restored.positions["baker"] = State.MILL_HOPPER_POSITION
	assert(restored.try_reedbank_livelihood("baker"))
	assert(not restored.try_reedbank_livelihood("baker"))
	assert(restored.materials["flour"] == 1 and restored.materials["sunwheat"] == 0)
	world.load_dictionary(restored.to_dictionary())
	assert(world.materials["flour"] == 1, "Intermediate flour survives a companion returning later.")
	restored.positions["baker"] = State.REEDBANK_OVEN_POSITION
	assert(not restored.try_reedbank_livelihood("baker"))
	assert(restored.materials["flour"] == 1)
	restored.materials["herb"] = 1
	assert(restored.try_reedbank_livelihood("baker"))
	assert(restored.materials["flour"] == 0 and restored.materials["herb"] == 0)
	assert(restored.player_provisions["baker"] == 2)
	assert(restored.player_mastery["baker"]["cooking"] == 1)
	assert(not restored.try_reedbank_livelihood("baker"))
	restored.mark_world_empty(1000)
	restored.apply_offline_catch_up(1000 + 600)
	assert(restored.sunwheat_minutes_remaining("south") == 0)
	assert(restored.materials["sunwheat"] == 0, "Catch-up ripens but never harvests.")
	assert(restored.chronicle.is_empty() and restored.reputation == 0)
	world.load_dictionary(restored.to_dictionary())
	assert(world.sunwheat_minutes_remaining("south") == 0)
	assert(world.player_provisions["baker"] == 2)
	var legacy: Dictionary = restored.to_dictionary()
	legacy["version"] = 26
	world.load_dictionary(legacy)
	assert(world.sunwheat_planted_at.is_empty())
	assert(world.materials["sunwheat"] == 0 and world.materials["flour"] == 0)
	var snapshot := {"reedbank_stage": "complete", "world_day": restored.world_day, "world_minute": restored.world_minute, "sunwheat_planted_at": restored.sunwheat_planted_at, "materials": restored.materials}
	var targets := Reedbank.livelihood_targets(snapshot)
	assert(targets[0]["label"] == "Harvest 2 sunwheat")
	assert(targets[1]["label"] == "Sow sunwheat")
	assert(not targets[3]["ready"] and not targets[4]["ready"])
	print("PASS: sunwheat growth, shared handoff, bread conservation, persistence, safe catch-up, and prompts")
	quit()
