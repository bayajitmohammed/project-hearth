extends RefCounted

const CENTER := Vector3(10, 0.6, 18)
const RADIUS := 4.5
const JOIN_REACH := 1.8
const ATTACK_REACH := 2.0
const ATTACK_RECOVERY := 0.7
const GUARD_WINDOW := 0.5
const GUARD_RECOVERY := 2.0
var stage := "available"
var participants: Dictionary = {}
var attack_recovery: Dictionary = {}
var guards: Dictionary = {}
var guard_recovery: Dictionary = {}
var remaining := 0.0
var result := ""
var last_winner := ""
var ribbons: Dictionary = {}


static func inside(point: Vector3) -> bool:
	return point.distance_to(CENTER) <= RADIUS


func join(token: String, positions: Dictionary, downed: Dictionary, unlocked: bool) -> bool:
	if not unlocked or not positions.has(token) or bool(downed.get(token, false)) or positions[token].distance_to(CENTER) > JOIN_REACH:
		return false
	if stage not in ["available", "waiting", "results"]:
		return false
	if participants.has(token):
		cancel(token)
		return true
	if stage != "waiting":
		participants.clear()
		result = ""
	participants[token] = 3
	stage = "waiting"
	if participants.size() == 2:
		var index := 0
		for player: String in participants:
			positions[player] = CENTER + Vector3(-1.5 if index == 0 else 1.5, 0, 0)
			index += 1
		attack_recovery.clear()
		guards.clear()
		guard_recovery.clear()
		stage = "countdown"
		remaining = 3
	return true


func cancel(token: String) -> void:
	if not participants.has(token):
		return
	participants.clear()
	attack_recovery.clear()
	guards.clear()
	guard_recovery.clear()
	stage = "available"
	remaining = 0
	result = "Bout cancelled · no rewards or losses"


func tick(delta: float, positions: Dictionary, downed: Dictionary, active: Array) -> void:
	if stage not in ["waiting", "countdown", "active"]:
		return
	for token: String in participants:
		if token not in active or not positions.has(token) or bool(downed.get(token, false)) or not inside(positions[token]):
			cancel(token)
			return
	for timers: Dictionary in [attack_recovery, guards, guard_recovery]:
		for token: String in timers:
			timers[token] = maxf(0, float(timers[token]) - delta)
	if stage in ["countdown", "active"]:
		remaining = maxf(0, remaining - delta)
		if remaining <= 0:
			if stage == "countdown":
				stage = "active"
				remaining = 60
			else:
				stage = "results"
				result = "Draw · time expired · no ribbons awarded"
				participants.clear()


func attack(token: String, positions: Dictionary, downed: Dictionary) -> bool:
	if stage != "active" or not participants.has(token) or float(attack_recovery.get(token, 0)) > 0:
		return false
	if not positions.has(token) or bool(downed.get(token, false)) or not inside(positions[token]):
		return false
	for opponent: String in participants:
		if opponent == token or not positions.has(opponent) or bool(downed.get(opponent, false)) or not inside(positions[opponent]):
			continue
		if positions[token].distance_to(positions[opponent]) > ATTACK_REACH:
			return false
		attack_recovery[token] = ATTACK_RECOVERY
		if float(guards.get(opponent, 0)) > 0:
			guards[opponent] = 0
			return true
		participants[opponent] -= 1
		if participants[opponent] <= 0:
			last_winner = token
			for finisher: String in participants:
				ribbons[finisher] = int(ribbons.get(finisher, 0)) + 1
			participants.clear()
			stage = "results"
			remaining = 0
			result = "Decisive bout · both volunteers earned a sparring ribbon"
		return true
	return false


func brace(token: String) -> bool:
	if stage != "active" or not participants.has(token) or float(guard_recovery.get(token, 0)) > 0:
		return false
	guards[token] = GUARD_WINDOW
	guard_recovery[token] = GUARD_RECOVERY
	return true


func snapshot() -> Dictionary:
	return {"stage": stage, "participants": participants.duplicate(), "remaining": remaining, "guards": guards.duplicate(), "attack_recovery": attack_recovery.duplicate(), "guard_recovery": guard_recovery.duplicate(), "result": result, "last_winner": last_winner, "ribbons": ribbons.duplicate()}


func saved() -> Dictionary:
	return {"last_winner": last_winner, "ribbons": ribbons.duplicate()}


func load_saved(data: Dictionary) -> void:
	stage = "available"
	participants.clear()
	attack_recovery.clear()
	guards.clear()
	guard_recovery.clear()
	remaining = 0
	result = ""
	last_winner = str(data.get("last_winner", ""))
	ribbons.clear()
	var stored: Dictionary = data.get("ribbons", {})
	for token: String in stored:
		ribbons[token] = maxi(0, int(stored[token]))
