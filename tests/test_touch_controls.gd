extends SceneTree

const MainScene = preload("res://main.tscn")
const WorldStateModel = preload("res://scripts/world_state.gd")


func _init() -> void:
	var main = MainScene.instantiate()
	root.add_child(main)
	await process_frame

	var touch_layer := CanvasLayer.new()
	main.add_child(touch_layer)
	main._build_touch_controls(touch_layer)
	await process_frame

	var controls: Control = touch_layer.get_node("TouchControls")
	var joystick: Control = controls.get_node("MovementJoystick")
	var crosshair: Label = controls.get_node("MobileCrosshair")
	var context_button: Button = controls.get_node("ContextAction")

	assert(is_equal_approx(joystick.size.x, controls.size.x * 0.5), "The entire left half must accept movement input.")
	assert(is_equal_approx(joystick.size.y, controls.size.y), "The movement zone must use the full screen height.")
	assert(absf(joystick.stick_center.y - controls.size.y * 0.5) < 1.0, "The idle stick must be vertically centered.")
	assert(absf(crosshair.position.x + crosshair.size.x * 0.5 - controls.size.x * 0.5) < 1.0)
	assert(absf(crosshair.position.y + crosshair.size.y * 0.5 - controls.size.y * 0.5) < 1.0)
	assert(not controls.has_node("AttackAction"), "Android attack must use direct world taps, not a fixed button.")
	assert(not controls.has_node("CraftAction"), "Android crafting must stay contextual, not occupy the play view.")
	assert(not controls.has_node("ViewAction"), "The right half must stay clear for camera movement.")
	assert(not context_button.visible, "The contextual action must remain hidden without a valid aimed target.")

	var normal_style: StyleBoxFlat = context_button.get_theme_stylebox("normal")
	assert(normal_style.bg_color.a <= 0.25, "Idle mobile controls must remain translucent over the world.")
	var pressed_style: StyleBoxFlat = context_button.get_theme_stylebox("pressed")
	assert(pressed_style.bg_color.a > normal_style.bg_color.a, "Pressed actions need visible touch feedback.")

	assert(main._touch_control_scale() >= 1.1, "The baseline mobile controls should be larger than the old fixed layout.")
	joystick.stick_center = Vector2(joystick.size.x * 0.35, joystick.size.y * 0.7)
	joystick._update_from_local_position(joystick.stick_center + Vector2(joystick._stick_radius(), 0.0))
	assert(main._touch_input_vector().is_equal_approx(Vector2.RIGHT), "The analog stick must produce continuous movement input.")
	joystick.reset()
	assert(main._touch_input_vector().is_zero_approx(), "Releasing the stick must stop movement.")

	var tap_candidates: Array[Dictionary] = [
		{"kind": "interact", "screen_position": Vector2(300.0, 300.0)},
		{"kind": "attack", "screen_position": Vector2(520.0, 300.0)},
	]
	var selected: Dictionary = main._select_mobile_target(tap_candidates, Vector2(500.0, 300.0), 80.0)
	assert(selected.get("kind") == "attack", "World taps must choose the target nearest the touched point.")
	main.local_token = "touch-player"
	main.latest_snapshot = {
		"player_health": {"touch-player": 2},
		"downed_players": {"touch-player": false},
		"player_provisions": {"touch-player": 1},
		"player_brace_time": {"touch-player": 0.0},
		"player_brace_cooldown": {"touch-player": 0.0},
	}
	assert(main._local_can_use_trail_provision(), "An injured touch player must qualify for the contextual provision action.")
	assert(main._local_can_brace(), "A standing touch player must qualify for the contextual brace action.")
	assert(main._local_can_attack(), "A standing touch player without recovery must qualify for Power Strike.")
	main.latest_snapshot["creature_attack_windup"] = WorldStateModel.ENEMY_ATTACK_WINDUP_SECONDS
	main.latest_snapshot["creature_attack_target"] = "touch-player"
	assert(main._local_is_targeted_by_attack(), "Touch targeting must reserve Brace for an incoming local attack.")
	main.latest_snapshot = {
		"positions": {
			"touch-player": WorldStateModel.CREATURE_SPAWN + Vector3(1.0, 0.0, 0.0),
			"companion": WorldStateModel.CREATURE_SPAWN,
		},
		"player_health": {"touch-player": 3, "companion": 3},
		"downed_players": {"touch-player": false, "companion": false},
		"player_outing_kits": {"touch-player": WorldStateModel.OUTING_KIT_GUARDIAN},
		"player_brace_time": {"touch-player": 0.0},
		"player_brace_cooldown": {"touch-player": 0.0},
		"creature_position": WorldStateModel.CREATURE_SPAWN,
		"creature_attack_windup": WorldStateModel.ENEMY_ATTACK_WINDUP_SECONDS,
		"creature_attack_target": "companion",
	}
	assert(main._local_has_guardian_intercept_opportunity(), "A nearby touch Guardian must receive the contextual Intercept action for a companion's incoming hit.")
	assert(InputMap.has_action("brace"), "Desktop, controller, and Web builds need one shared brace action.")
	assert(InputMap.has_action("power_strike"), "Desktop, controller, and Web builds need one shared Power Strike action.")
	var main_source := FileAccess.get_file_as_string("res://scripts/main.gd")
	assert(main_source.contains("request_brace"), "Remote clients need a server-authoritative brace request.")
	assert(main_source.contains("\"kind\": \"brace\""), "Touch combat targeting needs a contextual brace action.")
	assert(main_source.contains("request_power_strike"), "Remote clients need a server-authoritative Power Strike request.")
	assert(main_source.contains("\"kind\": \"power_strike\""), "Touch combat targeting needs a contextual Power Strike action.")
	assert(main_source.contains("_append_mobile_target(candidates, supply_marker, \"Buy\""), "Touch players need the contextual supply-basket purchase action.")
	assert(main_source.contains("_append_mobile_target(candidates, hearthbloom_marker, \"Contribute\""), "Touch players need the contextual shared-project contribution action.")
	assert(main_source.contains("_append_mobile_target(candidates, outing_kit_marker, \"Switch kit\""), "Touch players need the contextual home-loadout action.")
	assert(main_source.contains("_append_mobile_target(candidates, trailwork_bench, \"Craft provision\", \"craft\""), "Touch players need the contextual trailcraft action.")
	assert(main_source.contains("\"craft\":\n\t\t\t_request_craft()"), "Touch trailcraft must use the authoritative craft request.")
	assert(main_source.contains("_append_mobile_target(candidates, fishing_marker, fishing_action"), "Touch players need contextual Cast and Reel actions at Willowmere Pond.")
	assert(main_source.contains("_append_mobile_target(candidates, trail_survey_marker, \"Record survey\""), "Touch players need the contextual daily survey action.")
	assert(main_source.contains("_append_mobile_target(candidates, riverfish_creel, \"Store fish\""), "Touch players need a contextual shared-creel deposit action.")
	assert(main_source.contains("fishing_action = \"Reel now!\""), "The touch action must clearly expose the bite window.")
	assert(main_source.contains("\"Give provision\""), "Touch players need a contextual provision handoff for healthy friends.")

	print("PASS: Split-screen Minecraft-style Android touch controls")
	quit()
