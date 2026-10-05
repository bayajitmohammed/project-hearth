class_name ReedbankHollow
extends Node3D

const State = preload("res://scripts/world_state.gd")
const Art = preload("res://scripts/graybox_world.gd")
var oren: Node3D
var sail: Node3D
var rotor: Node3D
var shelter_light: OmniLight3D
var marker: Node3D
var turning := false


func _ready() -> void:
	name = "ReedbankHollow"
	Art._add_box(self, "Meadow", Vector3(26, 0.25, 32), Vector3(31, -0.2, -33), Color("648574"))
	Art._add_box(self, "EasternTrail", Vector3(24, 0.03, 3), Vector3(29, -0.04, -23), Color("b7ab86"))
	Art._add_box(self, "MillPath", Vector3(3, 0.03, 18), Vector3(34, -0.03, -32), Color("b7ab86"))
	Art._add_box(self, "ReedPool", Vector3(6, 0.04, 10), Vector3(41, -0.02, -40), Color("588f96"))
	for index in range(18):
		var z := -46.0 + index * 1.35
		Art._add_cylinder(self, "Reed", 0.09, 1.5 + (index % 3) * 0.2, Vector3(39 + sin(index) * 1.0, 0.7, z), Color("c4b37b"), 5)
	for point: Vector3 in [Vector3(24, 0, -31), Vector3(26, 0, -43), Vector3(20, 0, -45), Vector3(40, 0, -21)]:
		Art._add_cylinder(self, "WillowTrunk", 0.3, 3.2, point + Vector3(0, 1.5, 0), Color("75664e"), 7)
		Art._add_cylinder(self, "WillowCrown", 2.4, 2.5, point + Vector3(0, 3.1, 0), Color("789e9a"), 9)
	Art._add_cylinder(self, "MillTower", 2.0, 5.5, Vector3(34, 2.6, -33), Color("d1c5a5"), 10)
	Art._add_cylinder(self, "MillRoof", 2.4, 0.7, Vector3(34, 5.6, -33), Color("587f7d"), 10)
	rotor = Node3D.new()
	rotor.position = Vector3(34, 4.3, -30.8)
	add_child(rotor)
	for angle in [0.0, PI / 2, PI, PI * 1.5]:
		var arm := Node3D.new()
		arm.rotation.z = angle
		rotor.add_child(arm)
		Art._add_box(arm, "SailFrame", Vector3(0.14, 3.5, 0.16), Vector3(0, 1.5, 0), Color("816447"))
		Art._add_box(arm, "LinenSail", Vector3(0.85, 2.2, 0.07), Vector3(0.35, 1.95, 0), Color("eee0b8"))
	Art._add_box(self, "RestAwning", Vector3(4, 0.18, 3), Vector3(29.5, 2.6, -33), Color("728e86"))
	Art._add_box(self, "RestBench", Vector3(2.8, 0.35, 0.7), Vector3(29.5, 0.4, -34), Color("92704d"))
	for x in [28.0, 31.0]:
		Art._add_cylinder(self, "AwningPost", 0.1, 2.6, Vector3(x, 1.2, -32), Color("92704d"), 6)
	shelter_light = OmniLight3D.new()
	shelter_light.position = Vector3(30, 2, -32)
	shelter_light.light_color = Color("ffcc87")
	shelter_light.omni_range = 9.0
	add_child(shelter_light)
	oren = Node3D.new()
	add_child(oren)
	Art._add_cylinder(oren, "ModestCloak", 0.42, 1.4, Vector3.ZERO, Color("bb976d"), 9)
	Art._add_cylinder(oren, "Hood", 0.31, 0.42, Vector3(0, 0.82, 0), Color("728e86"), 8)
	_label(oren, "Oren · Millkeeper", Vector3(0, 1.5, 0))
	sail = Node3D.new()
	sail.position = State.REEDBANK_SAIL_POSITION
	add_child(sail)
	Art._add_box(sail, "StormTornSail", Vector3(1.5, 0.2, 1), Vector3.ZERO, Color("eee0b8"))
	_label(self, "REEDBANK HOLLOW →", Vector3(15, 2.2, -23))
	_label(self, "OREN'S WINDMILL", Vector3(34, 7.8, -33))
	marker = Art._add_station_marker(self, "ReedbankObjective", State.OREN_TRAIL_POSITION, "OREN", Color("efd39c"))
	update_view({})


func _process(delta: float) -> void:
	if turning:
		rotor.rotation.z += delta * 0.45


func update_view(snapshot: Dictionary) -> void:
	var stage := str(snapshot.get("reedbank_stage", "meet_oren"))
	var unlocked := str(snapshot.get("nima_story_stage", "locked")) == "complete"
	turning = stage in ["return_oren", "complete"]
	rotor.visible = turning
	shelter_light.visible = stage == "complete"
	oren.visible = unlocked
	oren.position = State.OREN_MILL_POSITION if turning else State.OREN_TRAIL_POSITION
	sail.visible = unlocked and stage == "recover_sail"
	marker.visible = unlocked
	marker.position = target_position(stage)
	(marker.get_node("Label") as Label3D).text = action_text(stage)


static func target_position(stage: String) -> Vector3:
	match stage:
		"recover_sail": return State.REEDBANK_SAIL_POSITION
		"repair_mill": return State.REEDBANK_REPAIR_POSITION
		"return_oren": return State.OREN_MILL_POSITION
		"complete": return State.REEDBANK_REST_POSITION
	return State.OREN_TRAIL_POSITION


static func action_text(stage: String) -> String:
	return str({"meet_oren": "Speak to Oren", "recover_sail": "Recover the storm-torn sail", "repair_mill": "Fit sail and repair mill (2 wood)", "return_oren": "Tell Oren the mill is ready", "complete": "Rest at Reedbank shelter"}.get(stage, ""))


static func guidance(stage: String) -> String:
	return str({
		"meet_oren": "Nima's charts mark an eastern trail. Follow Northwood east to meet the millkeeper.",
		"recover_sail": "Oren: A storm carried our sail into the northern reed beds. Without it, this place has gone quiet.",
		"repair_mill": "The sail is safe with the group. Bring two shared wood to the mill's southern face; forest wood regrows each day.",
		"return_oren": "The sails are turning again. Oren has moved beside the mill — go show him your work.",
		"complete": "Oren: Hear that? A home again. Our shelter is yours whenever the road wears you down."
	}.get(stage, ""))


func _label(parent: Node3D, text: String, point: Vector3) -> void:
	var label := Label3D.new()
	label.text = text
	label.position = point
	label.font_size = 32
	label.outline_size = 8
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	parent.add_child(label)
