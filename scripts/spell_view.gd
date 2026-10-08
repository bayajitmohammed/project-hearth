extends Node3D

const Kits = preload("res://scripts/outing_kits.gd")
var beams: Dictionary = {}
var hint: Label


func _ready() -> void:
	var layer := CanvasLayer.new()
	add_child(layer)
	hint = Label.new()
	layer.add_child(hint)
	hint.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_RIGHT)
	hint.offset_left = -680
	hint.offset_right = -20
	hint.offset_top = -170
	hint.offset_bottom = -115
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint.add_theme_font_size_override("font_size", 18)
	hint.add_theme_color_override("font_color", Color("c8fbff"))
	hint.add_theme_color_override("font_outline_color", Color("172539"))
	hint.add_theme_constant_override("outline_size", 5)
	hint.visible = false


func update_view(snapshot: Dictionary, token: String) -> void:
	var traces: Dictionary = snapshot.get("spell_traces", {})
	for caster: String in beams.keys():
		if not traces.has(caster):
			beams[caster].queue_free()
			beams.erase(caster)
	for caster: String in traces:
		var trace: Dictionary = traces[caster]
		var start: Vector3 = trace["from"]
		var finish: Vector3 = trace["to"]
		if start.distance_to(finish) < 0.001:
			continue
		# Keep the near end in front of the caster, outside the first-person near plane.
		start = start.move_toward(finish, minf(0.45, start.distance_to(finish) / 3))
		if not beams.has(caster):
			var beam := MeshInstance3D.new()
			beam.name = "Moonthread"
			beam.mesh = BoxMesh.new()
			var material := StandardMaterial3D.new()
			material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
			material.albedo_color = Color("edb8ff") if bool(trace["heavy"]) else Color("98f8f2")
			beam.material_override = material
			beam.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
			add_child(beam)
			beams[caster] = beam
		var beam: MeshInstance3D = beams[caster]
		(beam.material_override as StandardMaterial3D).albedo_color = Color("edb8ff") if bool(trace["heavy"]) else Color("98f8f2")
		var width := 0.12 if bool(trace["heavy"]) else 0.055
		(beam.mesh as BoxMesh).size = Vector3(width, width, start.distance_to(finish))
		beam.position = (start + finish) / 2
		var direction := (finish - start).normalized()
		beam.look_at(finish, Vector3.RIGHT if absf(direction.dot(Vector3.UP)) > 0.99 else Vector3.UP)
	var point: Vector3 = snapshot.get("positions", {}).get(token, Vector3.INF)
	var near_enemy := (not bool(snapshot.get("creature_defeated", true)) and point.distance_to(snapshot.get("creature_position", Vector3.INF)) < 8) or (str(snapshot.get("exploration_stage", "")) == "defeat_guardian" and point.distance_to(snapshot.get("ruin_guardian_position", Vector3.INF)) < 8)
	hint.visible = str(snapshot.get("player_outing_kits", {}).get(token, "")) == Kits.MOONWEAVER and near_enemy and not bool(snapshot.get("downed_players", {}).get(token, false)) and not snapshot.get("sparring", {}).get("participants", {}).has(token)
	var recovery := float(snapshot.get("player_attack_recovery", {}).get(token, 0))
	hint.text = "MOONWEAVER · Space: Moonthread · R: Woven Burst · F: short brace\nReach 5.5m · %s" % ("ready" if recovery <= 0 else "recovering %.1fs" % recovery)
