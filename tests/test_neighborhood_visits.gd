extends SceneTree

const World = preload("res://scripts/world_state.gd")
const View = preload("res://scripts/neighborhood_visit_view.gd")


func _init() -> void:
	_run.call_deferred()


func _run() -> void:
	var world := World.new()
	world.world_seed = 112358
	world.register_player("a")
	world.register_player("b")
	assert(not world.refresh_neighborhood_visit())
	world.produce_stall_open = true
	world.world_seed = 2 # Day-one rain.
	assert(world.world_weather() == "gentle_rain")
	assert(world.refresh_neighborhood_visit())
	assert(world.neighborhood_visits.active == "travelers")
	world.world_seed = 112358
	world.world_day = 3
	assert(not world.refresh_neighborhood_visit(), "Weather/days cannot replace pending visitors.")
	world.materials["wood"] = 3
	world.player_provisions["b"] = 3
	assert(not world.try_neighborhood_visit("a"), "No remote contribution.")
	world.positions["a"] = World.Visits.JOB_POSITIONS[1]
	assert(not world.try_neighborhood_visit("a"), "A friend's provisions cannot fund your contribution.")
	assert(world.neighborhood_visits.jobs == [0, 0])
	world.positions["a"] = World.Visits.JOB_POSITIONS[0]
	world.downed_players["a"] = true
	assert(not world.try_neighborhood_visit("a"))
	world.downed_players["a"] = false
	assert(world.try_neighborhood_visit("a"))
	var restored := World.new()
	restored.load_dictionary(world.to_dictionary())
	world = restored
	assert(world.neighborhood_visits.jobs == [1, 0])
	assert(world.try_neighborhood_visit("a"))
	assert(not world.try_neighborhood_visit("a"), "Finished job cannot consume extra goods.")
	world.positions["b"] = World.Visits.JOB_POSITIONS[1]
	assert(world.try_neighborhood_visit("b"))
	assert(world.try_neighborhood_visit("b"))
	assert(world.materials["wood"] == 1 and world.player_provisions["b"] == 1)
	assert(world.neighborhood_visits.completed == {"travelers": 1})
	assert(world.reputation == 1 and world.neighborhood_morale == 1 and world.chronicle.size() == 1 and world.pantry_stock == 1)
	assert(not world.refresh_neighborhood_visit() and not world.try_neighborhood_visit("b"))
	world.homestead_guest = {"meals": 2}
	world.outpost_parts = {"shelter": true, "remedies": true, "meal": true}
	world.world_day += 1
	assert(world.refresh_neighborhood_visit())
	assert(world.neighborhood_visits.active == "seeds", "Unseen eligible events beat repeated ones.")
	world.materials["herb"] = 2
	world.materials["moonroot"] = 2
	for index in range(2):
		world.positions["a"] = World.Visits.JOB_POSITIONS[index]
		assert(world.try_neighborhood_visit("a") and world.try_neighborhood_visit("a"))
	assert(world.materials["herb"] == 0 and world.materials["moonroot"] == 0)
	assert(world.reputation == 2 and world.chronicle.size() == 2 and world.pantry_stock == 2)
	world.world_day += 1
	assert(world.refresh_neighborhood_visit())
	world.materials["wood"] = 4
	world.materials["herb"] = 4
	world.materials["moonroot"] = 4
	world.player_provisions["a"] = 4
	world.pantry_stock = World.PANTRY_MAX_STOCK
	for index in range(2):
		world.positions["a"] = World.Visits.JOB_POSITIONS[index]
		assert(world.try_neighborhood_visit("a") and world.try_neighborhood_visit("a"))
	assert(world.reputation == 2 and world.chronicle.size() == 2 and world.pantry_stock == World.PANTRY_MAX_STOCK)
	assert(world.player_mastery["a"]["building"] == 0 and world.player_coins["a"] == 0)
	var visit_save := world.neighborhood_visits.saved()
	var round_trip := World.new()
	round_trip.load_dictionary(world.to_dictionary())
	assert(round_trip.neighborhood_visits.saved() == visit_save)
	assert(not round_trip.refresh_neighborhood_visit(), "Reloading cannot skip the same-day cooldown.")
	world.last_world_empty_unix = 10
	world.apply_offline_catch_up(999999)
	assert(world.neighborhood_visits.saved() == visit_save, "Empty-world time neither selects nor contributes.")
	var view := View.new()
	root.add_child(view)
	var snapshot := world.to_dictionary()
	snapshot["positions"] = world.positions.duplicate()
	view.update_view(snapshot, "a")
	assert(view.canopy.visible and view.planter.visible and not view.visitors.visible)
	assert(not view.markers[0].visible)
	snapshot["neighborhood_visits"]["active"] = "seeds"
	snapshot["neighborhood_visits"]["jobs"] = [1, 0]
	view.update_view(snapshot, "a")
	assert(view.visitors.visible and view.markers[0].visible)
	assert("1/2" in view.markers[0].get_node("Label").text)
	assert("shared herb" in view.status.text and "shared moonroot" in view.status.text)
	view.free()
	var old := world.to_dictionary()
	old["version"] = 37
	world.load_dictionary(old)
	assert(world.neighborhood_visits.active.is_empty() and world.neighborhood_visits.completed.is_empty())
	assert(World.ActivityCatalog.IDS.has("visits"))
	var first := World.Visits.new()
	var second := World.Visits.new()
	var context := {"day": 1, "seed": 42, "stall": true, "weather": "clear", "outpost": false, "sera": false}
	assert(not first.select_visit(context), "Clear market without outpost has no travelers.")
	context["outpost"] = true
	context["sera"] = true
	assert(first.select_visit(context) and second.select_visit(context))
	assert(first.active == second.active)
	first.restore({"active": "invalid", "completed": {"invalid": 42}, "jobs": [99, -9], "finished_day": 999}, 3)
	assert(first.active.is_empty() and first.completed.is_empty() and first.finished_day == 3)
	print("PASS: condition-driven visits, persistent cooperative jobs, conservation, fair selection, bounded repeat rewards, no offline progression, migration and permanent scenery")
	quit()
