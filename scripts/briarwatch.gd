extends Node3D

const State = preload("res://scripts/world_state.gd")
const Art = preload("res://scripts/graybox_world.gd")
var entry_marker: Node3D
var binding_markers: Dictionary = {}
var roots: Dictionary = {}
var beacon_marker: Node3D
var beacon_light: OmniLight3D
var beacon_beam: MeshInstance3D
var spirit: MeshInstance3D
var pulses: Array[MeshInstance3D] = []
var warning: Label


func _ready() -> void:
	name = "Briarwatch"
	Art._add_box(self, "WatchClearing", Vector3(36, 0.25, 28), Vector3(0, -0.2, -61), Color("536d68"))
	Art._add_box(self, "WatchTrail", Vector3(3, 0.04, 20), Vector3(0, -0.03, -55), Color("9caa8f"))
	for x in [-4.0, 4.0]:
		Art._add_cylinder(self, "GatePillar", 0.65, 3.5, Vector3(x, 1.7, -52), Color("7e9390"), 7)
	for index in range(12):
		var angle := TAU * index / 12.0
		var point := Vector3(sin(angle) * 14, 1.1, -64 + cos(angle) * 9)
		Art._add_cylinder(self, "WatchStone", 0.7, 2.4, point, Color("70877f"), 6)
	Art._add_cylinder(self, "WatchBeacon", 1.0, 1.5, State.BRIARWATCH_BEACON, Color("93a49a"), 8)
	beacon_beam = Art._add_cylinder(self, "RekindledBeam", 0.22, 8, State.BRIARWATCH_BEACON + Vector3(0, 4, 0), Color("f3d991"), 10)
	var beam_material := beacon_beam.material_override as StandardMaterial3D
	beam_material.emission_enabled = true
	beam_material.emission = Color("f3d991")
	beacon_light = OmniLight3D.new()
	beacon_light.position = State.BRIARWATCH_BEACON + Vector3(0, 2, 0)
	beacon_light.light_color = Color("ffd694")
	beacon_light.omni_range = 15
	add_child(beacon_light)
	spirit = MeshInstance3D.new()
	var spirit_mesh := SphereMesh.new()
	spirit_mesh.radius = 0.75
	spirit_mesh.height = 1.8
	spirit.mesh = spirit_mesh
	spirit.position = State.BRIARWATCH_BEACON + Vector3(0, 3, 0)
	var spirit_material := StandardMaterial3D.new()
	spirit_material.albedo_color = Color("bc98dd")
	spirit_material.emission_enabled = true
	spirit_material.emission = Color("8c68b2")
	spirit.material_override = spirit_material
	add_child(spirit)
	entry_marker = Art._add_station_marker(self, "WatchInvitation", State.BRIARWATCH_ENTRANCE, "BRIARWATCH · BEGIN OUTING", Color("ccb8ec"))
	for binding_id: String in State.BRIARWATCH_BINDINGS:
		var point: Vector3 = State.BRIARWATCH_BINDINGS[binding_id]
		var root := Node3D.new()
		root.position = point
		add_child(root)
		for offset in [-0.45, 0.0, 0.45]:
			Art._add_box(root, "SpiritBinding", Vector3(0.18, 1.6, 0.18), Vector3(offset, 0.2, 0), Color("8d678c"), Vector3(0, 0, offset * 40))
		roots[binding_id] = root
		binding_markers[binding_id] = Art._add_station_marker(self, "BindingMarker", point, "BREAK %s BINDING" % binding_id.to_upper(), Color("d6b1df"))
	beacon_marker = Art._add_station_marker(self, "BeaconMarker", State.BRIARWATCH_BEACON, "REKINDLE WATCH BEACON", Color("efcf86"))
	for index in range(3):
		var pulse := Art._add_cylinder(self, "SpiritPulseWarning%d" % index, State.BRIARWATCH_PULSE_RADIUS, 0.05, Vector3.ZERO, Color(0.95, 0.35, 0.55, 0.7), 40)
		var pulse_material := pulse.material_override as StandardMaterial3D
		pulse_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		pulse_material.emission_enabled = true
		pulse_material.emission = Color("bc547c")
		pulses.append(pulse)
	var layer := CanvasLayer.new()
	add_child(layer)
	warning = Label.new()
	warning.set_anchors_and_offsets_preset(Control.PRESET_CENTER_BOTTOM)
	warning.offset_left = -300
	warning.offset_right = 300
	warning.offset_top = -160
	warning.offset_bottom = -120
	warning.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	warning.add_theme_font_size_override("font_size", 22)
	warning.add_theme_color_override("font_color", Color("ffd2b0"))
	layer.add_child(warning)
	update_view({}, "")


func update_view(snapshot: Dictionary, token: String) -> void:
	var unlocked := bool(snapshot.get("ruin_waystone_activated", false))
	var stage := str(snapshot.get("briarwatch_stage", "rumor"))
	var broken: Dictionary = snapshot.get("broken_briarwatch_bindings", {})
	entry_marker.visible = unlocked and stage == "rumor"
	for binding_id: String in roots:
		roots[binding_id].visible = not bool(broken.get(binding_id, false))
		binding_markers[binding_id].visible = unlocked and stage == "bindings" and roots[binding_id].visible
	spirit.visible = stage in ["rumor", "bindings"]
	beacon_beam.visible = stage == "complete"
	beacon_light.visible = stage == "complete"
	beacon_marker.visible = unlocked and stage in ["rekindle", "complete"]
	(beacon_marker.get_node("Label") as Label3D).text = "RETURN HOME" if stage == "complete" else "REKINDLE WATCH BEACON"
	var windup := float(snapshot.get("briarwatch_windup", 0.0))
	var marks: Array = snapshot.get("briarwatch_pulse_positions", [])
	var local_position: Vector3 = snapshot.get("positions", {}).get(token, Vector3.INF)
	var threatened := false
	for index in range(pulses.size()):
		pulses[index].visible = windup > 0.0 and index < marks.size()
		if index < marks.size():
			var target: Vector3 = marks[index]
			pulses[index].position = Vector3(target.x, 0.07, target.z)
			threatened = threatened or local_position.distance_to(target) <= State.BRIARWATCH_PULSE_RADIUS
	warning.visible = windup > 0.0 and not marks.is_empty() and local_position.is_finite() and absf(local_position.x) <= 12 and local_position.z <= -55 and local_position.z >= State.WORLD_MIN_Z
	warning.text = "%s · %d marks · %.1fs" % ["LEAVE THE MARK OR BRACE" if threatened else "SPIRIT GROUND MARKED", marks.size(), windup]


static func targets(snapshot: Dictionary) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	if not bool(snapshot.get("ruin_waystone_activated", false)):
		return result
	match str(snapshot.get("briarwatch_stage", "rumor")):
		"rumor":
			result.append({"position": State.BRIARWATCH_ENTRANCE, "text": "Begin the Briarwatch outing", "id": "entrance"})
		"bindings":
			for binding_id: String in State.BRIARWATCH_BINDINGS:
				if not bool(snapshot.get("broken_briarwatch_bindings", {}).get(binding_id, false)):
					result.append({"position": State.BRIARWATCH_BINDINGS[binding_id], "text": "Break the %s spirit binding" % binding_id, "id": binding_id})
		"rekindle", "complete":
			result.append({"position": State.BRIARWATCH_BEACON, "text": "Return home through the beacon" if snapshot["briarwatch_stage"] == "complete" else "Rekindle the watch beacon", "id": "beacon"})
	return result
