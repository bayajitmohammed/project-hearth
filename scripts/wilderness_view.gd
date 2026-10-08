extends Node3D

const Layout = preload("res://scripts/wilderness_layout.gd")
const Art = preload("res://scripts/graybox_world.gd")
const State = preload("res://scripts/world_state.gd")
var sections: Dictionary = {}
var cache_markers: Dictionary = {}
var rendered_seed := -1
var outpost_root: Node3D
var outpost_markers: Dictionary = {}
var outpost_pieces: Dictionary = {}
var forage: Dictionary = {}
var claim_markers: Dictionary = {}
var guest_root: Node3D
var guest_marker: Node3D
var guest_awning: Node3D


func update_view(snapshot: Dictionary, token: String) -> void:
	var seed_value := int(snapshot.get("world_seed", 1))
	if seed_value != rendered_seed:
		for section: Node3D in sections.values():
			section.free()
		sections.clear()
		cache_markers.clear()
		claim_markers.clear()
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
			claim_markers.erase(section_id)
	if not is_instance_valid(outpost_root):
		outpost_markers.clear()
		outpost_pieces.clear()
	for source_id: String in forage.keys():
		if not is_instance_valid(forage[source_id]["growth"]):
			forage.erase(source_id)
	var claims: Dictionary = snapshot.get("player_wilderness_caches", {}).get(token, {})
	for section_id: String in needed:
		if not sections.has(section_id):
			_build_section(needed[section_id])
		var marker: Node3D = cache_markers[section_id]
		(marker.get_node("Label") as Label3D).text = "%s\n%s" % [Layout.title(needed[section_id]).to_upper(), "CACHE COLLECTED" if claims.has(section_id) else "TRAIL CACHE · E"]
		if claim_markers.has(section_id):
			var plot_claimed: bool = snapshot.get("wilderness_plots", {}).has(section_id)
			(claim_markers[section_id].get_node("Label") as Label3D).text = "%s HOMESTEAD\n%s" % [Layout.title(needed[section_id]).to_upper(), "SHARED PLOT · B TO BUILD" if plot_claimed else ("CLAIM · E · 2 WOOD" if snapshot.get("quest_stage", "") == "home_repaired" else "REPAIR THE COTTAGE FIRST")]
	for source_id: String in forage:
		var ready := int(snapshot.get("wilderness_forage_days", {}).get(source_id, 0)) < int(snapshot.get("world_day", 1))
		forage[source_id]["growth"].visible = ready
		(forage[source_id]["marker"].get_node("Label") as Label3D).text = "%s · %s" % [str(forage[source_id]["kind"]).to_upper(), "GATHER" if ready else "RETURNS TOMORROW"]
	if is_instance_valid(outpost_root):
		var parts: Dictionary = snapshot.get("outpost_parts", {})
		for part: String in outpost_pieces:
			outpost_pieces[part].visible = parts.has(part)
		for station: String in outpost_markers:
			outpost_markers[station].visible = (parts.size() == 3) if station in ["rest", "craft"] else (parts.size() < 3 and not parts.has(station))
	_update_guest(snapshot, token)


func _update_guest(snapshot: Dictionary, token: String) -> void:
	var guest: Dictionary = snapshot.get("homestead_guest", {})
	var plot := str(guest.get("plot", ""))
	if not sections.has(plot):
		if is_instance_valid(guest_root):
			guest_root.free()
		return
	if not is_instance_valid(guest_root):
		guest_root = Node3D.new()
		guest_root.name = "SeraCamp"
		sections[plot].add_child(guest_root)
		guest_root.position = State.homestead_guest_position(snapshot)
		Art._add_cylinder(guest_root, "ModestCloak", 0.4, 1.3, Vector3(-0.6, 0.1, 0), Color("8397a6"), 9)
		Art._add_cylinder(guest_root, "FeaturelessHood", 0.29, 0.4, Vector3(-0.6, 0.9, 0), Color("b5a991"), 9)
		Art._add_box(guest_root, "SeedSatchel", Vector3(0.4, 0.35, 0.35), Vector3(-0.05, -0.35, 0), Color("a28662"))
		guest_marker = Art._add_station_marker(guest_root, "SeraMarker", Vector3.ZERO, "SERA", Color("e7d39b"))
		var label := guest_marker.get_node("Label") as Label3D
		label.fixed_size = true
		label.pixel_size = 0.0015
		guest_awning = Node3D.new()
		guest_root.add_child(guest_awning)
		Art._add_box(guest_awning, "WelcomeCanopy", Vector3(2.5, 0.12, 2.2), Vector3(0, 1.9, -0.35), Color("a1b99e"))
		for x: float in [-1.1, 1.1]:
			Art._add_cylinder(guest_awning, "CanopyPost", 0.09, 2.4, Vector3(x, 0.6, -1.2), Color("927555"), 7)
		Art._add_box(guest_awning, "SeedTable", Vector3(1.1, 0.12, 0.65), Vector3(0.6, 0.15, -0.55), Color("9c805e"))
		for x: float in [0.3, 0.7]:
			Art._add_cylinder(guest_awning, "SeedJar", 0.14, 0.25, Vector3(x, 0.34, -0.55), Color("d3b876"), 8)
	guest_awning.visible = int(guest.get("meals", 0)) == 2
	(guest_marker.get_node("Label") as Label3D).text = "SERA · SEEDKEEPER\n" + State.homestead_guest_text(snapshot, token)


func _build_section(cell: Vector2i) -> void:
	var section := Node3D.new()
	section.name = "Wilderness_%d_%d" % [cell.x, cell.y]
	add_child(section)
	var biome := Layout.biome(rendered_seed, cell)
	var tint: Color = Layout.BIOMES[biome]["ground"].lightened(float(posmod(cell.x + cell.y, 3)) * 0.04)
	Art._add_box(section, "Terrain", Vector3(Layout.SIZE, 0.2, Layout.SIZE), Layout.center(cell) + Vector3(0, -0.1, 0), tint)
	for point: Vector3 in Layout.scenery(rendered_seed, cell):
		_add_biome_scenery(section, point, biome)
	var cache := Layout.cache_position(rendered_seed, cell)
	Art._add_cylinder(section, "TrailStone", 0.4, 1.5, cache, Color("a6bcac"), 6)
	Art._add_box(section, "Cache", Vector3(0.7, 0.4, 0.55), cache + Vector3(0.7, -0.3, 0), Color("9d8054"))
	var marker := Art._add_station_marker(section, "CacheMarker", cache, Layout.title(cell), Color("e9cf92"))
	sections[Layout.key(cell)] = section
	cache_markers[Layout.key(cell)] = marker
	if cell != Layout.outpost_cell(rendered_seed):
		var plot_origin := Layout.plot_origin(rendered_seed, cell)
		Art._add_box(section, "HomesteadClearing", Vector3(15, 0.02, 9), plot_origin + Vector3(6, 0.01, 3), Color("819475"))
		var post := Layout.claim_post(rendered_seed, cell)
		Art._add_box(section, "ClaimPost", Vector3(0.15, 1.3, 0.15), post, Color("937357"))
		claim_markers[Layout.key(cell)] = Art._add_station_marker(section, "ClaimMarker", post, "HOMESTEAD", Color("e5cf9c"))
	for source: Dictionary in Layout.forage_nodes(rendered_seed, cell):
		var growth := Node3D.new()
		growth.position = source["position"] - Vector3(0, 0.6, 0)
		section.add_child(growth)
		Art._add_cylinder(section, "ForageBase", 0.6, 0.08, source["position"] - Vector3(0, 0.56, 0), Color("786e4e"), 8)
		for offset in [-0.35, 0, 0.35]:
			if source["kind"] == "wood":
				Art._add_cylinder(growth, "FallenWood", 0.12, 1.3, Vector3(offset, 0.22, 0), Color("92734f"), 7).rotation.z = PI / 2
			else:
				Art._add_box(growth, "HerbLeaves", Vector3(0.25, 0.5, 0.25), Vector3(offset, 0.3, 0), Color("91c9ae"), Vector3(0, 0, offset * 45))
		var forage_marker := Art._add_station_marker(section, "ForageMarker", source["position"], "GATHER " + source["kind"], Color("b9dc9b"))
		forage[source["id"]] = {"growth": growth, "marker": forage_marker, "kind": source["kind"]}
	if cell == Layout.outpost_cell(rendered_seed):
		_build_outpost(section)


func _add_biome_scenery(section: Node3D, point: Vector3, biome: String) -> void:
	if biome == "woodland":
		Art._add_tree(section, "Tree", point)
		return
	var cluster := Node3D.new()
	cluster.name = "BiomeScenery"
	cluster.position = point
	section.add_child(cluster)
	if biome == "pinewood":
		Art._add_cylinder(cluster, "Trunk", 0.2, 3.2, Vector3(0, 1.6, 0), Color("77634e"), 8)
		for tier in range(3):
			var crown := Art._add_cylinder(cluster, "PineCrown", 1.6 - tier * 0.35, 2.5, Vector3(0, 2.4 + tier, 0), Color("436f60").lightened(tier * 0.06), 9)
			(crown.mesh as CylinderMesh).top_radius = 0
	elif biome == "meadow":
		for offset: float in [-0.55, 0, 0.55]:
			Art._add_cylinder(cluster, "Stem", 0.035, 0.65, Vector3(offset, 0.325, offset * 0.5), Color("577951"), 5)
			_add_round_canopy(cluster, Vector3(offset, 0.7, offset * 0.5), 0.22, Color("e4bbce") if offset == 0 else Color("eadca4"))
	else:
		Art._add_cylinder(cluster, "Trunk", 0.18, 3.2, Vector3(0, 1.6, 0), Color("a39caa"), 8)
		_add_round_canopy(cluster, Vector3(-0.6, 3, 0), 1.2, Color("899cbb"))
		_add_round_canopy(cluster, Vector3(0.6, 3.7, 0.2), 1.3, Color("a5a5c5"))


func _add_round_canopy(parent: Node3D, point: Vector3, radius: float, tint: Color) -> void:
	var crown := MeshInstance3D.new()
	var mesh := SphereMesh.new()
	mesh.radius = radius
	mesh.height = radius * 1.6
	mesh.radial_segments = 12
	mesh.rings = 6
	crown.mesh = mesh
	crown.position = point
	var material := StandardMaterial3D.new()
	material.albedo_color = tint
	crown.material_override = material
	parent.add_child(crown)


func _build_outpost(section: Node3D) -> void:
	outpost_root = Node3D.new()
	outpost_root.name = "FartrailOutpost"
	section.add_child(outpost_root)
	var site := Layout.outpost_position(rendered_seed)
	Art._add_box(outpost_root, "Clearing", Vector3(10, 0.05, 10), Vector3(site.x, 0.025, site.z), Color("92997a"))
	Art._add_station_marker(outpost_root, "OutpostSign", site + Vector3(0, 0, -4), "FARTRAIL OUTPOST", Color("efd4a4"))
	for part: String in ["shelter", "remedies", "meal"]:
		var piece := Node3D.new()
		piece.position = Layout.outpost_station(rendered_seed, part) - Vector3(0, 0.6, 0)
		outpost_root.add_child(piece)
		outpost_pieces[part] = piece
		match part:
			"shelter":
				Art._add_box(piece, "Roof", Vector3(4, 0.2, 4), Vector3(0, 2.8, 0), Color("8f7654"), Vector3(0, 0, -8))
				for x in [-1.6, 1.6]:
					for z in [-1.6, 1.6]:
						Art._add_box(piece, "Post", Vector3(0.18, 2.7, 0.18), Vector3(x, 1.35, z), Color("6b5844"))
				Art._add_box(piece, "Bedroll", Vector3(1.6, 0.25, 0.8), Vector3(0, 0.2, 0), Color("a2b6bd"))
			"remedies":
				Art._add_box(piece, "Workbench", Vector3(2, 0.9, 0.9), Vector3(0, 0.45, 0), Color("897254"))
				for x in [-0.6, 0, 0.6]:
					Art._add_cylinder(piece, "RemedyJar", 0.15, 0.35, Vector3(x, 1.05, 0), Color("82b59a"), 8)
			"meal":
				Art._add_cylinder(piece, "CookHearth", 0.7, 0.25, Vector3(0, 0.15, 0), Color("cf9d5b"), 8)
				Art._add_cylinder(piece, "MealPot", 0.35, 0.4, Vector3(0, 0.4, 0), Color("766866"), 10)
	for station: String in Layout.OUTPOST_OFFSETS:
		outpost_markers[station] = Art._add_station_marker(outpost_root, "Station_" + station, Layout.outpost_station(rendered_seed, station), station.to_upper(), Color("edd49d"))


static func outpost_targets(snapshot: Dictionary) -> Array[Dictionary]:
	var seed_value := int(snapshot.get("world_seed", 1))
	var parts: Dictionary = snapshot.get("outpost_parts", {})
	var titles := {"shelter": "Raise shelter · 3 shared wood", "remedies": "Stock remedies · 2 shared herbs", "meal": "Prepare field meal · 2 personal/creel fish", "rest": "Rest at Fartrail", "craft": "Trailcraft · 1 wood + 1 herb"}
	var result: Array[Dictionary] = []
	for station: String in Layout.OUTPOST_OFFSETS:
		if (station in ["rest", "craft"] and parts.size() == 3) or (station not in ["rest", "craft"] and parts.size() < 3 and not parts.has(station)):
			result.append({"id": station, "position": Layout.outpost_station(seed_value, station), "text": titles[station]})
	return result
