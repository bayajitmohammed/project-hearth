extends SceneTree

const MainScene = preload("res://main.tscn")
const STEP_SECONDS := 0.05
const TIMEOUT_SECONDS := 20.0

var main
var token := ""
var role := ""


func _init() -> void:
	token = _argument("--player-token=")
	role = _argument("--probe-role=")
	assert(token in ["survey-a", "survey-b"], "Use a daily-survey probe identity.")
	main = MainScene.instantiate()
	root.add_child(main)
	main.local_input_enabled = false
	assert(await _wait_until(_is_connected, "connect to the daily-survey room"))
	if role == "browser-observer":
		assert(token == "survey-a")
		assert(await _wait_until(func() -> bool: return _active_player_count() >= 2, "see the browser observer"))
		main._request_interaction()
		assert(await _wait_until(func() -> bool: return _survey_day("survey-a") == 1, "record the partner survey"))
		print("PASS: Browser daily-survey partner — personal survey recorded")
		quit()
		return
	assert(await _wait_until(_both_players_visible, "see both daily surveyors"))
	main._request_interaction()
	assert(await _wait_until(_both_surveys_recorded, "record both personal surveys"))
	assert(_survey_day("survey-a") == 1)
	assert(_survey_day("survey-b") == 1)
	assert(_exploration_mastery("survey-a") + _exploration_mastery("survey-b") == 4)
	print("PASS: Daily survey probe %s — shared marker kept both personal opportunities" % token)
	await create_timer(1.0).timeout
	quit()


func _wait_until(check: Callable, description: String) -> bool:
	var deadline := Time.get_ticks_msec() + int(TIMEOUT_SECONDS * 1000.0)
	while Time.get_ticks_msec() < deadline:
		if check.call():
			return true
		await create_timer(STEP_SECONDS).timeout
	push_error("Timed out waiting to %s." % description)
	return false


func _is_connected() -> bool:
	return main.client_connected and not main.latest_snapshot.is_empty()


func _both_players_visible() -> bool:
	var positions: Dictionary = main.latest_snapshot.get("positions", {})
	return positions.has("survey-a") and positions.has("survey-b")


func _active_player_count() -> int:
	return main.latest_snapshot.get("positions", {}).size()


func _both_surveys_recorded() -> bool:
	return _survey_day("survey-a") == 1 and _survey_day("survey-b") == 1


func _survey_day(player_token: String) -> int:
	return int(main.latest_snapshot.get("player_survey_day", {}).get(player_token, -1))


func _exploration_mastery(player_token: String) -> int:
	return int(
		main.latest_snapshot.get("player_mastery", {}).get(player_token, {}).get("exploration", -1)
	)


func _argument(prefix: String) -> String:
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with(prefix):
			return argument.trim_prefix(prefix)
	return ""
