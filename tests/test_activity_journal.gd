extends SceneTree

const State = preload("res://scripts/world_state.gd")
const Catalog = preload("res://scripts/activity_catalog.gd")
const Main = preload("res://main.tscn")


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var world := State.new()
	world.register_player("a")
	world.register_player("b")
	assert(Catalog.entries(world.to_dictionary()).size() == 2)
	assert(not Catalog.find_entry(world.to_dictionary(), "wilderness").is_empty())
	assert(not world.try_pin_activity("a", "sunwheat"))
	assert(not world.try_pin_activity("unknown", "home"))
	assert(not world.try_pin_activity("a", "invented"))
	assert(world.try_pin_activity("a", "home"))
	assert(world.player_activity_pins["b"] == "automatic")
	world.quest_stage = "home_repaired"
	assert(world.try_pin_activity("b", "fishing"))
	assert(not world.try_pin_activity("b", "fishing"))
	assert(Catalog.find_entry(world.to_dictionary(), "home")["complete"])
	world.nima_story_stage = "complete"
	world.reedbank_stage = "complete"
	assert(world.try_pin_activity("a", "sunwheat"))
	var restored := State.new()
	restored.load_dictionary(world.to_dictionary())
	assert(restored.player_activity_pins == world.player_activity_pins)
	assert(restored.try_pin_activity("a", "automatic"))
	assert(restored.player_activity_pins["b"] == "fishing")
	var legacy: Dictionary = world.to_dictionary()
	legacy["version"] = 27
	restored.load_dictionary(legacy)
	restored.register_player("a")
	assert(restored.player_activity_pins["a"] == "automatic")
	var main = Main.instantiate()
	root.add_child(main)
	main.local_input_enabled = false
	main.local_token = "a"
	main.client_connected = true
	main.world_state = world
	main.peer_to_token[1] = "a"
	main.receive_snapshot(main._snapshot_for_clients())
	assert(main.objective_label.text.contains("Sow, harvest"))
	assert(main.activity_journal.rows.has("sunwheat"))
	world.festival_stage = "racing"
	world.festival_participants = {"a": 1}
	world.player_activity_pins["a"] = "festival"
	main.receive_snapshot(main._snapshot_for_clients())
	assert(main.objective_label.text == "Reach festival checkpoint 2 of 3")
	world.player_activity_pins["a"] = "sunwheat"
	main.receive_snapshot(main._snapshot_for_clients())
	main.activity_journal.toggle_mode()
	assert(main.activity_journal.active)
	world.positions["a"] = State.TRAILWORK_BENCH_POSITION
	world.materials["wood"] = 1
	world.materials["herb"] = 1
	main.local_authority_player = true
	main._request_craft()
	assert(world.materials["wood"] == 1 and world.materials["herb"] == 1)
	Input.action_press("move_forward")
	main._update_local_authority_input()
	Input.action_release("move_forward")
	assert(main.peer_inputs[1] == Vector2.ZERO)
	main.homestead_builder.toggle_mode()
	assert(not main.activity_journal.active and main.homestead_builder.active)
	main.activity_journal.toggle_mode()
	assert(main.activity_journal.active and not main.homestead_builder.active)
	main.activity_journal.toggle_mode()
	main.activity_journal._process(0)
	main.local_authority_player = false # Avoid writing a test world on teardown.
	main.client_connected = false
	main.queue_free()
	await process_frame
	print("PASS: journal availability, independent pins, persistence, guidance, and panel input isolation")
	quit()
