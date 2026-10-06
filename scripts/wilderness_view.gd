extends Node3D

const Layout = preload("res://scripts/wilderness_layout.gd")
const Art = preload("res://scripts/graybox_world.gd")
var sections: Dictionary = {}
var cache_markers: Dictionary = {}
var rendered_seed := -1


func update_view(snapshot: Dictionary, token: String) -> void:
	var seed_value := int(snapshot.get("world_seed", 1))
	if seed_value != rendered_seed:
		for section: Node3D in sections.values():
			section.free()
		sections.clear()
		cache_markers.clear()
		rendered_seed = seed_value
	var point: Vector3 = snapshot.get("positions", {}).get(token, Vector3.ZERO)
	var local_cell := Layout.cell_at(point)
	var needed: Dictionary = {}
	for x in range(local_cell.x - 1, local_cell.x + 2):
		for z in range(local_cell.y - 1, local_cell.y + 2):
			var cell := Vector2i(x, z)
			if Layout.valid(cell):
				needed[Layout.key(cell)] = cell
	for section_id: String in sections.keys():
		if not needed.has(section_id):
			sections[section_id].free()
			sections.erase(section_id)
			cache_markers.erase(section_id)
	var claims: Dictionary = snapshot.get("player_wilderness_caches", {}).get(token, {})
	for section_id: String in needed:
		if not sections.has(section_id):
			_build_section(needed[section_id])
		var marker: Node3D = cache_markers[section_id]
		(marker.get_node("Label") as Label3D).text = "%s\n%s" % [Layout.title(needed[section_id]).to_upper(), "CACHE COLLECTED" if claims.has(section_id) else "TRAIL CACHE · E"]


func _build_section(cell: Vector2i) -> void:
	var section := Node3D.new()
	section.name = "Wilderness_%d_%d" % [cell.x, cell.y]
	add_child(section)
	var tint := Color("547a56").lightened(float(posmod(cell.x + cell.y, 3)) * 0.04)
	Art._add_box(section, "Terrain", Vector3(Layout.SIZE, 0.2, Layout.SIZE), Layout.center(cell) + Vector3(0, -0.1, 0), tint)
	for point: Vector3 in Layout.scenery(rendered_seed, cell):
		Art._add_tree(section, "Tree", point)
	var cache := Layout.cache_position(rendered_seed, cell)
	Art._add_cylinder(section, "TrailStone", 0.4, 1.5, cache, Color("a6bcac"), 6)
	Art._add_box(section, "Cache", Vector3(0.7, 0.4, 0.55), cache + Vector3(0.7, -0.3, 0), Color("9d8054"))
	var marker := Art._add_station_marker(section, "CacheMarker", cache, Layout.title(cell), Color("e9cf92"))
	sections[Layout.key(cell)] = section
	cache_markers[Layout.key(cell)] = marker
