extends SceneTree

const World = preload("res://scripts/world_state.gd")
const Scene = preload("res://main.tscn")


func _init() -> void:
	_run.call_deferred()


func _run() -> void:
	var world := World.new()
	for token in ["a", "b", "stranger"]:
		world.register_player(token)
	world.positions["b"] = world.positions["a"] + Vector3(1, 0, 0)
	world.player_coins["a"] = 5
	world.player_riverfish["b"] = 3
	var active := ["a", "b", "stranger"]
	var offer := {"action": "propose", "to": "b", "give": "coin", "give_count": 2, "take": "riverfish", "take_count": 1}
	assert(not world.try_personal_trade("a", offer, active))
	var id: int = world.trades.for_player("a")["id"]
	assert(world.player_coins["a"] == 5 and world.player_riverfish["b"] == 3, "Proposal transfers nothing.")
	assert(not world.try_personal_trade("a", {"action": "accept", "id": id}, active))
	assert(not world.try_personal_trade("stranger", {"action": "accept", "id": id}, active))
	assert(not world.try_personal_trade("b", {"action": "accept", "id": [id]}, active))
	assert(world.try_personal_trade("b", {"action": "accept", "id": id}, active))
	assert(world.player_coins == {"a": 3, "b": 2, "stranger": 0})
	assert(world.player_riverfish == {"a": 1, "b": 2, "stranger": 0})
	assert(not world.try_personal_trade("b", {"action": "accept", "id": id}, active))
	var restored := World.new()
	restored.load_dictionary(world.to_dictionary())
	assert(restored.player_coins == world.player_coins and restored.player_riverfish == world.player_riverfish and restored.trades.offers.is_empty())
	var balance := world.player_coins.duplicate()
	for reason in ["cancel", "range", "downed", "disconnect", "spent", "timeout", "reload"]:
		world.player_coins["a"] = 3
		world.positions["b"] = world.positions["a"] + Vector3(1, 0, 0)
		world.downed_players["b"] = false
		world.try_personal_trade("a", offer, active)
		var current: int = world.trades.for_player("a")["id"]
		assert(current != id)
		assert(not world.try_personal_trade("b", {"action": "accept", "id": id}, active))
		match reason:
			"cancel": world.try_personal_trade("b", {"action": "cancel", "id": current}, active)
			"range": world.positions["b"] += Vector3(10, 0, 0)
			"downed": world.downed_players["b"] = true
			"disconnect": world.trades.cancel_player("a")
			"spent": world.player_coins["a"] = 0
			"timeout": world.trades.tick(60, world.trade_context(active))
			"reload": world.load_dictionary(world.to_dictionary())
		world.trades.tick(0, world.trade_context(active))
		assert(world.trades.offers.is_empty())
		assert(world.player_coins["b"] == balance["b"] and world.player_riverfish["b"] == 2)
	world.player_coins["a"] = 5
	world.positions["b"] = world.positions["a"]
	world.downed_players["b"] = false
	for invalid: Dictionary in [{"give": "wood"}, {"give_count": -1}, {"give_count": 100}, {"give_count": 1.5}, {"to": "a"}, {"to": "offline"}]:
		var bad := offer.duplicate()
		bad.merge(invalid, true)
		assert(not world.try_personal_trade("a", bad, active))
		assert(world.trades.offers.is_empty())
	world.try_personal_trade("a", offer, active)
	assert(not world.trades.offers.is_empty())
	assert(not world.try_personal_trade("a", offer, active) and world.trades.offers.size() == 1)
	assert(world.player_mastery["a"]["trade"] == 0 and world.chronicle.is_empty())
	var main = Scene.instantiate()
	root.add_child(main)
	main.local_input_enabled = false
	main.local_token = "a"
	main.client_connected = true
	main.local_authority_player = true
	main.world_state = world
	main.peer_to_token[1] = "a"
	main.receive_snapshot(main._snapshot_for_clients())
	main.trade_panel.toggle_mode()
	assert(main._blocks_gameplay() and main.trade_panel.overlay.visible)
	var health: int = main.world_state.creature_health
	main._request_attack()
	main._request_craft()
	assert(main.world_state.creature_health == health)
	Input.action_press("move_forward")
	main._update_local_authority_input()
	Input.action_release("move_forward")
	assert(main.peer_inputs[1] == Vector2.ZERO)
	var snapshot := world.to_dictionary()
	snapshot["positions"] = world.positions
	snapshot["trades"] = world.trades.snapshot()
	main.trade_panel.update_view(snapshot, "b", true)
	assert(main.trade_panel.accept.visible and "YOU GIVE: 1 riverfish" in main.trade_panel.terms.text and "YOU RECEIVE: 2 coin" in main.trade_panel.terms.text)
	main.activity_journal.toggle_mode()
	assert(main.activity_journal.active and not main.trade_panel.active)
	for give: String in World.PersonalTrades.ITEMS:
		for take: String in World.PersonalTrades.ITEMS:
			if give == take:
				continue
			var exchange := World.new()
			exchange.register_player("a")
			exchange.register_player("b")
			var holdings: Dictionary = exchange.trade_context(["a", "b"])["holdings"]
			holdings[give]["a"] = 99
			holdings[take]["b"] = 99
			exchange.try_personal_trade("a", {"action": "propose", "to": "b", "give": give, "give_count": 99, "take": take, "take_count": 99}, ["a", "b"])
			var exchange_id: int = exchange.trades.for_player("a")["id"]
			assert(exchange.try_personal_trade("b", {"action": "accept", "id": exchange_id}, ["a", "b"]))
			assert(holdings[give]["a"] == 0 and holdings[give]["b"] == 99 and holdings[take]["a"] == 99 and holdings[take]["b"] == 0)
	main.local_authority_player = false
	main.client_connected = false
	print("PASS: exact-consent trades, atomic conserved balances, stale/replayed IDs, invalidation, save reset and modal trade presentation")
	quit()
