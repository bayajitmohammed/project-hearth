extends Node3D

const Rules = preload("res://scripts/neighborhood_visits.gd")
const Art = preload("res://scripts/graybox_world.gd")
var markers: Array[Node3D] = []
var visitors: Node3D
var canopy: Node3D
var planter: Node3D
var board: Node3D
var status: Label


func _ready() -> void:
	board = Art._add_station_marker(self, "VisitBoard", Rules.BOARD, "THE MARKET GREEN", Color("e9c788"))
	for index in range(2):
		markers.append(Art._add_station_marker(self, "VisitJob%d" % index, Rules.JOB_POSITIONS[index], "Visit job", Color("b9d3a9")))
	visitors = Node3D.new()
	visitors.name = "Visitors"
	add_child(visitors)
	for index in range(2):
		var point := Vector3(16, 0, 1 - index * 3)
		Art._add_cylinder(visitors, "Cloak", 0.32, 1.1, point + Vector3(0, 0.55, 0), Color("628c87") if index == 0 else Color("9a819f"), 7)
		Art._add_cylinder(visitors, "Hood", 0.23, 0.4, point + Vector3(0, 1.25, 0), Color("d7cfb4"), 6)
	canopy = Node3D.new()
	canopy.name = "TravelersCanopy"
	add_child(canopy)
	for z in [-3.5, 3.5]:
		Art._add_box(canopy, "Post", Vector3(0.12, 2.5, 0.12), Vector3(16.6, 1.25, z), Color("765b45"))
	Art._add_box(canopy, "Cloth", Vector3(2.5, 0.12, 7.4), Vector3(15.5, 2.55, 0), Color("bba579"))
	planter = Node3D.new()
	planter.name = "SeedGarden"
	add_child(planter)
	Art._add_box(planter, "Bed", Vector3(1.7, 0.25, 0.8), Vector3(15, 0.125, -4.5), Color("826a4b"))
	for index in range(4):
		Art._add_cylinder(planter, "Seedling", 0.15, 0.5, Vector3(14.4 + index * 0.4, 0.45, -4.5), Color("9bbc92"), 5)
	var layer := CanvasLayer.new()
	add_child(layer)
	status = Label.new()
	layer.add_child(status)
	status.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_RIGHT)
	status.offset_left = -680
	status.offset_right = -20
	status.offset_top = -245
	status.offset_bottom = -145
	status.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	status.add_theme_font_size_override("font_size", 18)
	status.add_theme_color_override("font_outline_color", Color("18262c"))
	status.add_theme_constant_override("outline_size", 6)
	update_view({}, "")


func update_view(snapshot: Dictionary, token: String) -> void:
	var visit: Dictionary = snapshot.get("neighborhood_visits", {})
	var kind := str(visit.get("active", ""))
	var jobs := Rules.targets(snapshot)
	visible = bool(snapshot.get("produce_stall_open", false)) or not visit.get("completed", {}).is_empty() or not kind.is_empty()
	visitors.visible = not kind.is_empty()
	canopy.visible = int(visit.get("completed", {}).get("travelers", 0)) > 0
	planter.visible = int(visit.get("completed", {}).get("seeds", 0)) > 0
	for index in range(2):
		markers[index].visible = index < jobs.size()
		if index < jobs.size():
			(markers[index].get_node("Label") as Label3D).text = "%s · %d/2" % [Rules.TEMPLATES[kind]["jobs"][index], int(visit["jobs"][index])]
	var point: Vector3 = snapshot.get("positions", {}).get(token, Vector3.INF)
	status.visible = visible and point.distance_to(Vector3(15, 0.6, 2)) < 7
	status.text = Rules.summary(snapshot)
	if not kind.is_empty():
		status.text += "\n" + Rules.TEMPLATES[kind]["reason"]
		status.text += "\n" + jobs[0]["text"] + "\n" + jobs[1]["text"]
	else:
		status.text += "\nNo deadlines or upkeep · visit progress survives your absence"
