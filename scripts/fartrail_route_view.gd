extends Node3D

const World = preload("res://scripts/world_state.gd")
const Art = preload("res://scripts/graybox_world.gd")
var posts: Array[Node3D] = []
var markers: Array[Node3D] = []
var lights: Array[Node3D] = []


func _ready() -> void:
	visible = false
	for index in range(2):
		var post := Node3D.new()
		add_child(post)
		posts.append(post)
		Art._add_cylinder(post, "TrailPost", 0.3, 1.5, Vector3(0, 0.15, 0), Color("857963"), 8)
		var light := Art._add_cylinder(post, "Waylight", 0.5, 0.3, Vector3(0, 1.05, 0), Color("9cd8d4"), 10)
		lights.append(light)
		markers.append(Art._add_station_marker(post, "RouteMarker", Vector3.ZERO, "FARTRAIL ROUTE", Color("d5e4b3")))


func update_view(snapshot: Dictionary, _token: String) -> void:
	var targets := World.fartrail_route_targets(snapshot)
	visible = not targets.is_empty()
	if not visible:
		return
	for index in range(2):
		posts[index].position = targets[index]["position"]
		lights[index].visible = snapshot.get("fartrail_route_parts", {}).size() == 2
		(markers[index].get_node("Label") as Label3D).text = "FARTRAIL ROUTE\n" + targets[index]["text"]
