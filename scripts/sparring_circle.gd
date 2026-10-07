extends Node3D

const Rules = preload("res://scripts/sparring_rules.gd")
const Art = preload("res://scripts/graybox_world.gd")
var marker: Node3D
var status: Label


func _ready() -> void:
	Art._add_cylinder(self, "TrainingRing", Rules.RADIUS, 0.04, Rules.CENTER - Vector3(0, 0.55, 0), Color("ad9674"), 48)
	for index in range(12):
		var angle := TAU * index / 12
		Art._add_cylinder(self, "BoundaryStone", 0.16, 0.2, Rules.CENTER + Vector3(cos(angle) * Rules.RADIUS, -0.45, sin(angle) * Rules.RADIUS), Color("dcc6a0"), 6)
	marker = Art._add_station_marker(self, "SparringSign", Rules.CENTER, "SPARRING · TWO VOLUNTEERS", Color("c8b4e6"))
	var label := marker.get_node("Label") as Label3D
	label.fixed_size = true
	label.pixel_size = 0.0015
	var layer := CanvasLayer.new()
	add_child(layer)
	status = Label.new()
	status.set_anchors_and_offsets_preset(Control.PRESET_CENTER_BOTTOM)
	status.offset_left = -340
	status.offset_right = 340
	status.offset_top = -205
	status.offset_bottom = -145
	status.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	status.add_theme_font_size_override("font_size", 19)
	status.add_theme_color_override("font_color", Color("fff0cd"))
	status.add_theme_color_override("font_outline_color", Color("232833"))
	status.add_theme_constant_override("outline_size", 5)
	layer.add_child(status)
	update_view({}, "")


func update_view(snapshot: Dictionary, token: String) -> void:
	visible = bool(snapshot.get("produce_stall_open", false))
	marker.visible = visible
	var point: Vector3 = snapshot.get("positions", {}).get(token, Vector3.INF)
	status.visible = visible and point.distance_to(Rules.CENTER) <= Rules.RADIUS + 3
	var match_state: Dictionary = snapshot.get("sparring", {})
	var stage := str(match_state.get("stage", "available"))
	var players: Dictionary = match_state.get("participants", {})
	var joined := players.has(token)
	var title := "SPARRING · E TO VOLUNTEER"
	var text := "Two volunteers · equal training gear · world health is safe"
	if stage == "available" and not str(match_state.get("result", "")).is_empty():
		text = str(match_state["result"])
	match stage:
		"waiting":
			title = "SPARRING · ONE VOLUNTEER WAITING"
			text = "Waiting for a second volunteer · E at sign cancels" if joined else "E at sign joins the waiting volunteer"
		"countdown":
			title = "SPARRING · GET READY"
			text = "Starting in %.1fs · Space/R tap · F guard · leave circle to cancel" % float(match_state.get("remaining", 0))
		"active":
			title = "SPARRING IN PROGRESS · SPECTATORS SAFE"
			var opponent := 0
			for player: String in players:
				if player != token:
					opponent = int(players[player])
			text = "You %d / 3 · Opponent %d / 3 · %.0fs\nSpace/R tap · F guard · leave circle to cancel" % [int(players.get(token, 0)), opponent, float(match_state.get("remaining", 0))] if joined else "Two volunteers are sparring · spectators cannot be hit"
		"results":
			text = str(match_state.get("result", ""))
			if text.begins_with("Decisive"):
				text = ("You won · " if match_state.get("last_winner", "") == token else "Bout finished · ") + "Your cosmetic sparring ribbons: %d" % int(match_state.get("ribbons", {}).get(token, 0))
			text += "\nE at sign volunteers for a new bout"
	if stage in ["available", "waiting"]:
		text += "\nYour cosmetic sparring ribbons: %d" % int(match_state.get("ribbons", {}).get(token, 0))
	status.text = text
	(marker.get_node("Label") as Label3D).text = title
